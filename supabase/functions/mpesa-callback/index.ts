import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS gracefully
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const defaultOrgId = Deno.env.get('MOBIFUND_DEFAULT_ORG_ID') || null
    
    // Safely parse incoming Daraja API request
    const payload = await req.json()
    console.log("M-Pesa Callback Payload:", JSON.stringify(payload))
    
    // Validate Daraja Structure exists
    if (!payload.Body?.stkCallback) {
       return new Response(JSON.stringify({ error: "Invalid payload structure" }), { 
         headers: { ...corsHeaders, 'Content-Type': 'application/json' }, 
         status: 400 
       })
    }

    const callback = payload.Body.stkCallback
    const resultCode = callback.ResultCode
    const resultDesc = callback.ResultDesc
    const checkoutRequestID = callback.CheckoutRequestID
    const merchantRequestID = callback.MerchantRequestID

    // Connect to Supabase to update transaction state
    const supabase = createClient(supabaseUrl, supabaseKey)

    if (resultCode === 0) {
      // It was successful -> Parse Item Array for exact details
      const items = callback.CallbackMetadata?.Item || []
      const getVal = (name: string) => items.find((i: any) => i.Name === name)?.Value

      const amount = getVal('Amount')
      const mpesaReceipt = getVal('MpesaReceiptNumber')
      const phone = getVal('PhoneNumber')
      const txDate = getVal('TransactionDate')

      console.log(`Successful STK Push: Receipt ${mpesaReceipt} | Amount: ${amount}`)

      // Best-effort org resolution:
      // - Prefer existing record's org_id (created at STK initiation)
      // - Fallback to MOBIFUND_DEFAULT_ORG_ID if provided
      const { data: existing } = await supabase
        .from('mpesa_transactions')
        .select('org_id, account_reference, member_id')
        .eq('checkout_request_id', checkoutRequestID)
        .maybeSingle()

      const orgId = existing?.org_id ?? defaultOrgId
      if (!orgId) {
        console.error('Missing org_id: set during STK initiation or provide MOBIFUND_DEFAULT_ORG_ID')
        return new Response(JSON.stringify({ error: 'Missing org_id for transaction' }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        })
      }

      const { error } = await supabase.from('mpesa_transactions').upsert({
        org_id: orgId,
        checkout_request_id: checkoutRequestID,
        merchant_request_id: merchantRequestID,
        amount: amount,
        phone: phone?.toString(),
        status: 'completed',
        result_code: resultCode,
        result_desc: resultDesc,
        mpesa_receipt_number: mpesaReceipt?.toString(),
        transaction_date: txDate ? new Date(txDate.toString()).toISOString() : null,
        raw_payload: payload,
        updated_at: new Date().toISOString(),
      })

      if (error) throw error

    } else {
      // It failed or was cancelled by user
      console.log(`Failed STK Push: ${resultDesc}`)

      const { data: existing } = await supabase
        .from('mpesa_transactions')
        .select('org_id')
        .eq('checkout_request_id', checkoutRequestID)
        .maybeSingle()

      const orgId = existing?.org_id ?? defaultOrgId
      if (!orgId) {
        console.error('Missing org_id for failed transaction; set during initiation or provide MOBIFUND_DEFAULT_ORG_ID')
      }

      await supabase.from('mpesa_transactions').upsert({
        org_id: orgId,
        checkout_request_id: checkoutRequestID,
        merchant_request_id: merchantRequestID,
        status: 'failed',
        result_code: resultCode,
        result_desc: resultDesc,
        raw_payload: payload,
        updated_at: new Date().toISOString(),
      })
    }

    // Always acknowledge cleanly to Daraja API bridging timeouts
    return new Response(JSON.stringify({ ResultCode: 0, ResultDesc: "Accepted" }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error("Webhook processing error:", error.message)
    return new Response(JSON.stringify({ ResultCode: 1, ResultDesc: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
