import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

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

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const authHeader = req.headers.get('Authorization') ?? ''
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })

    const {
      data: { user },
      error: userErr,
    } = await userClient.auth.getUser()
    if (userErr || !user) return json({ error: 'Unauthorized' }, 401)

    const { data: pa, error: paErr } = await userClient
      .from('platform_admins')
      .select('user_id')
      .eq('user_id', user.id)
      .maybeSingle()
    if (paErr || !pa) return json({ error: 'Forbidden' }, 403)

    const body = await req.json()
    const orgId = (body.org_id || '').toString()
    const reason = (body.reason || '').toString().trim()
    const ttlMinutes = Number(body.ttl_minutes ?? 30)

    if (!orgId) return json({ error: 'Missing org_id' }, 400)
    if (!reason) return json({ error: 'Missing reason' }, 400)
    if (!Number.isFinite(ttlMinutes) || ttlMinutes < 5 || ttlMinutes > 240) {
      return json({ error: 'ttl_minutes must be between 5 and 240' }, 400)
    }

    const expiresAt = new Date(Date.now() + ttlMinutes * 60 * 1000).toISOString()

    const serviceClient = createClient(supabaseUrl, serviceKey)

    const { data: org, error: orgErr } = await serviceClient
      .from('organizations')
      .select('*')
      .eq('id', orgId)
      .maybeSingle()
    if (orgErr || !org) return json({ error: 'Organization not found' }, 404)

    // End any existing active sessions for this admin+org (best-effort)
    await serviceClient
      .from('support_sessions')
      .update({ ended_at: new Date().toISOString() })
      .eq('platform_admin_user_id', user.id)
      .eq('org_id', orgId)
      .is('ended_at', null)

    const { data: session, error: insErr } = await serviceClient
      .from('support_sessions')
      .insert({
        platform_admin_user_id: user.id,
        org_id: orgId,
        reason,
        expires_at: expiresAt,
      })
      .select()
      .single()
    if (insErr) throw insErr

    // Precompute KPIs so platform screen gets fresh numbers quickly
    await serviceClient.rpc('recompute_platform_org_kpis', { p_org_id: orgId })

    return json({
      success: true,
      session: {
        id: session.id,
        org_id: session.org_id,
        expires_at: session.expires_at,
        reason: session.reason,
      },
      organization: org,
    })
  } catch (e) {
    console.error('support-start-session error', e)
    return json({ error: e?.message || 'Unknown error' }, 500)
  }
})

