-- Platform reporting views (safe, aggregated)
-- Date: 2026-03-17

-- Lightweight org directory for platform dashboard (non-PII).
-- This is a view over organizations only; access is controlled via org_select policy that allows platform admins.
CREATE OR REPLACE VIEW public.platform_org_directory AS
SELECT
  o.id AS org_id,
  o.name AS org_name,
  o.tier,
  o.created_at,
  o.is_active,
  k.member_count,
  k.total_contributions,
  k.total_expenses,
  k.loan_count,
  k.updated_at AS kpis_updated_at
FROM public.organizations o
LEFT JOIN public.platform_org_kpis k
  ON k.org_id = o.id
WHERE o.is_active = true;

