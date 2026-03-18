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
    const sessionId = (body.session_id || '').toString()
    if (!sessionId) return json({ error: 'Missing session_id' }, 400)

    const serviceClient = createClient(supabaseUrl, serviceKey)
    const { data, error } = await serviceClient
      .from('support_sessions')
      .update({ ended_at: new Date().toISOString() })
      .eq('id', sessionId)
      .eq('platform_admin_user_id', user.id)
      .select()
      .maybeSingle()
    if (error) throw error
    if (!data) return json({ error: 'Session not found' }, 404)

    return json({ success: true })
  } catch (e) {
    console.error('support-end-session error', e)
    return json({ error: e?.message || 'Unknown error' }, 500)
  }
})

