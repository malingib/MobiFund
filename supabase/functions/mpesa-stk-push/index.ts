import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

type StkPushRequest = {
  org_id: string
  phone: string
  amount: number
  account_reference: string
  transaction_desc?: string
  member_id?: string | null
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

function normalizePhone(input: string): string {
  const clean = input.replace(/[\s\-\+]/g, '')
  if (clean.startsWith('254') && clean.length === 12) return clean
  if (clean.startsWith('0') && clean.length === 10) return `254${clean.slice(1)}`
  if (clean.length === 9) return `254${clean}`
  return clean
}

function timestamp(dt = new Date()): string {
  const pad = (n: number) => n.toString().padStart(2, '0')
  return `${dt.getFullYear()}${pad(dt.getMonth() + 1)}${pad(dt.getDate())}${pad(dt.getHours())}${pad(dt.getMinutes())}${pad(dt.getSeconds())}`
}

async function getAccessToken(baseUrl: string, consumerKey: string, consumerSecret: string): Promise<string> {
  const basic = btoa(`${consumerKey}:${consumerSecret}`)
  const res = await fetch(`${baseUrl}/oauth/v1/generate?grant_type=client_credentials`, {
    headers: { Authorization: `Basic ${basic}` },
  })
  if (!res.ok) {
    const t = await res.text()
    throw new Error(`Failed to get access token: ${t}`)
  }
  const data = await res.json()
  if (!data.access_token) throw new Error('No access_token returned')
  return data.access_token
}

function b64ToBytes(b64: string): Uint8Array {
  const bin = atob(b64)
  const bytes = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i)
  return bytes
}

async function decryptJson<T>(blobB64: string, keyB64: string): Promise<T> {
  const raw = b64ToBytes(blobB64)
  const iv = raw.slice(0, 12)
  const ct = raw.slice(12)
  const keyBytes = b64ToBytes(keyB64)
  const key = await crypto.subtle.importKey('raw', keyBytes, 'AES-GCM', false, [
    'decrypt',
  ])
  const pt = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, ct)
  const txt = new TextDecoder().decode(pt)
  return JSON.parse(txt) as T
}

type MpesaConfig = {
  mpesa_env: string
  consumer_key: string
  consumer_secret: string
  passkey: string
  shortcode: string
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    // Prefer platform-configured creds (set by Super Admin), fallback to env vars
    let mpesaEnv = (Deno.env.get('MPESA_ENV') || '').toLowerCase()
    let consumerKey = Deno.env.get('MPESA_CONSUMER_KEY') || ''
    let consumerSecret = Deno.env.get('MPESA_CONSUMER_SECRET') || ''
    let passkey = Deno.env.get('MPESA_PASSKEY') || ''
    let shortcode = Deno.env.get('MPESA_SHORTCODE') || ''

    const configKey = Deno.env.get('MOBIFUND_CONFIG_KEY') || ''
    const supabase = createClient(supabaseUrl, serviceKey)

    if (!consumerKey || !consumerSecret || !passkey || !shortcode) {
      const { data } = await supabase
        .from('platform_configs')
        .select('value_encrypted')
        .eq('key', 'mpesa')
        .maybeSingle()

      if (!data?.value_encrypted) {
        return json({ error: 'M-Pesa is not configured' }, 400)
      }
      if (!configKey) {
        return json(
          { error: 'Missing MOBIFUND_CONFIG_KEY secret for decrypting config' },
          500,
        )
      }

      const cfg = await decryptJson<MpesaConfig>(data.value_encrypted, configKey)
      mpesaEnv = (cfg.mpesa_env || 'sandbox').toLowerCase()
      consumerKey = cfg.consumer_key
      consumerSecret = cfg.consumer_secret
      passkey = cfg.passkey
      shortcode = cfg.shortcode
    }

    const isProd = (mpesaEnv || 'sandbox') === 'production'
    const baseUrl = isProd
      ? 'https://api.safaricom.co.ke'
      : 'https://sandbox.safaricom.co.ke'

    const payload = (await req.json()) as Partial<StkPushRequest>
    const orgId = payload.org_id?.trim()
    const amount = Number(payload.amount)
    const phone = payload.phone ? normalizePhone(payload.phone) : ''
    const accountReference = payload.account_reference?.trim()
    const desc = (payload.transaction_desc || 'Mobifund Payment').slice(0, 40)
    const memberId = payload.member_id ?? null

    if (!orgId) return json({ error: 'org_id is required' }, 400)
    if (!accountReference) return json({ error: 'account_reference is required' }, 400)
    if (!phone || phone.length < 10) return json({ error: 'phone is invalid' }, 400)
    if (!Number.isFinite(amount) || amount <= 0) return json({ error: 'amount is invalid' }, 400)

    const token = await getAccessToken(baseUrl, consumerKey, consumerSecret)
    const ts = timestamp()
    const password = btoa(`${shortcode}${passkey}${ts}`)
    const callbackUrl = `${supabaseUrl}/functions/v1/mpesa-callback`

    const res = await fetch(`${baseUrl}/mpesa/stkpush/v1/processrequest`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        BusinessShortCode: shortcode,
        Password: password,
        Timestamp: ts,
        TransactionType: 'CustomerPayBillOnline',
        Amount: Math.round(amount).toString(),
        PartyA: phone,
        PartyB: shortcode,
        PhoneNumber: phone,
        CallBackURL: callbackUrl,
        AccountReference: accountReference,
        TransactionDesc: desc,
      }),
    })

    const data = await res.json().catch(async () => ({ raw: await res.text() }))
    if (!res.ok) {
      return json({ error: 'STK push failed', details: data }, 400)
    }

    const checkoutRequestId = data.CheckoutRequestID
    const merchantRequestId = data.MerchantRequestID
    const responseCode = data.ResponseCode
    const responseDesc = data.ResponseDescription

    if (responseCode !== '0' || !checkoutRequestId) {
      return json({ error: 'STK push rejected', details: data }, 400)
    }

    // Create/Update transaction row with org_id so callback can resolve org reliably
    const { error: upsertErr } = await supabase.from('mpesa_transactions').upsert({
      org_id: orgId,
      member_id: memberId,
      checkout_request_id: checkoutRequestId,
      merchant_request_id: merchantRequestId,
      amount: amount,
      phone: phone,
      account_reference: accountReference,
      status: 'pending',
      result_code: null,
      result_desc: responseDesc || null,
      raw_payload: { request: payload, response: data },
      updated_at: new Date().toISOString(),
    })

    if (upsertErr) throw upsertErr

    return json({
      success: true,
      checkoutRequestId,
      merchantRequestId,
      message: data.CustomerMessage || 'STK Push sent. Enter PIN on phone.',
    })
  } catch (e) {
    console.error('mpesa-stk-push error', e)
    return json({ error: e?.message || 'Unknown error' }, 500)
  }
})

