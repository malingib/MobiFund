import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

function b64ToBytes(b64: string): Uint8Array {
  const bin = atob(b64)
  const bytes = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i)
  return bytes
}

function bytesToB64(bytes: Uint8Array): string {
  let bin = ''
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i])
  return btoa(bin)
}

async function encryptJson(payload: unknown, keyB64: string): Promise<string> {
  const keyBytes = b64ToBytes(keyB64)
  const key = await crypto.subtle.importKey('raw', keyBytes, 'AES-GCM', false, [
    'encrypt',
  ])
  const iv = crypto.getRandomValues(new Uint8Array(12))
  const pt = new TextEncoder().encode(JSON.stringify(payload))
  const ct = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, pt))
  // store iv + ct
  const out = new Uint8Array(iv.length + ct.length)
  out.set(iv, 0)
  out.set(ct, iv.length)
  return bytesToB64(out)
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const configKey = Deno.env.get('MOBIFUND_CONFIG_KEY') // base64 32 bytes

    if (!configKey) {
      return json(
        {
          error:
            'Missing MOBIFUND_CONFIG_KEY secret (base64 32 bytes). Set it in Supabase secrets.',
        },
        500,
      )
    }

    const authHeader = req.headers.get('Authorization') ?? ''
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })

    const {
      data: { user },
      error: userErr,
    } = await userClient.auth.getUser()
    if (userErr || !user) return json({ error: 'Unauthorized' }, 401)

    // Verify platform admin via RLS-enabled table
    const { data: pa, error: paErr } = await userClient
      .from('platform_admins')
      .select('user_id')
      .eq('user_id', user.id)
      .maybeSingle()
    if (paErr || !pa) return json({ error: 'Forbidden' }, 403)

    const body = await req.json()
    const env = (body.mpesa_env || 'sandbox').toString()
    const consumerKey = (body.consumer_key || '').toString().trim()
    const consumerSecret = (body.consumer_secret || '').toString().trim()
    const passkey = (body.passkey || '').toString().trim()
    const shortcode = (body.shortcode || '').toString().trim()

    if (!consumerKey || !consumerSecret || !passkey || !shortcode) {
      return json({ error: 'Missing required fields' }, 400)
    }

    const encrypted = await encryptJson(
      {
        mpesa_env: env,
        consumer_key: consumerKey,
        consumer_secret: consumerSecret,
        passkey,
        shortcode,
        updated_at: new Date().toISOString(),
      },
      configKey,
    )

    const serviceClient = createClient(supabaseUrl, serviceKey)
    const { error: upsertErr } = await serviceClient.from('platform_configs').upsert({
      key: 'mpesa',
      value_encrypted: encrypted,
      updated_by: user.id,
      updated_at: new Date().toISOString(),
    })
    if (upsertErr) throw upsertErr

    return json({ success: true })
  } catch (e) {
    console.error('platform-set-mpesa-config error', e)
    return json({ error: e?.message || 'Unknown error' }, 500)
  }
})

