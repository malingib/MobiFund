-- Option B: Controlled support override + platform aggregated KPIs
-- Date: 2026-03-17

-- ─────────────────────────────────────────
-- SUPPORT SESSIONS (time-bound override)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.support_sessions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  platform_admin_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  reason text NOT NULL,
  started_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  ended_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_support_sessions_org_active
  ON public.support_sessions(org_id, expires_at)
  WHERE ended_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_support_sessions_admin_active
  ON public.support_sessions(platform_admin_user_id, expires_at)
  WHERE ended_at IS NULL;

ALTER TABLE public.support_sessions ENABLE ROW LEVEL SECURITY;

-- Platform admins can view their sessions; writes happen via Edge Functions (service role).
DROP POLICY IF EXISTS support_sessions_select_self ON public.support_sessions;
CREATE POLICY support_sessions_select_self ON public.support_sessions
  FOR SELECT
  USING (platform_admin_user_id = auth.uid());

-- ─────────────────────────────────────────
-- SUPPORT AUDIT LOGS
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.support_audit_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id uuid REFERENCES public.support_sessions(id) ON DELETE SET NULL,
  actor_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  org_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  table_name text NOT NULL,
  action text NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  record_id uuid,
  before jsonb,
  after jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_support_audit_logs_org_created
  ON public.support_audit_logs(org_id, created_at DESC);

ALTER TABLE public.support_audit_logs ENABLE ROW LEVEL SECURITY;

-- Only platform admins can read logs; nobody writes directly (triggers / service role).
DROP POLICY IF EXISTS support_audit_logs_select_admin ON public.support_audit_logs;
CREATE POLICY support_audit_logs_select_admin ON public.support_audit_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.platform_admins pa
      WHERE pa.user_id = auth.uid()
    )
  );

-- ─────────────────────────────────────────
-- HELPER FUNCTIONS (avoid RLS recursion)
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_platform_admin(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT EXISTS (SELECT 1 FROM public.platform_admins pa WHERE pa.user_id = p_user_id);
$$;

CREATE OR REPLACE FUNCTION public.active_support_session_id(p_org_id uuid)
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT ss.id
  FROM public.support_sessions ss
  WHERE ss.org_id = p_org_id
    AND ss.platform_admin_user_id = auth.uid()
    AND ss.ended_at IS NULL
    AND ss.expires_at > now()
  ORDER BY ss.started_at DESC
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.has_active_support_session(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT public.active_support_session_id(p_org_id) IS NOT NULL;
$$;

-- ─────────────────────────────────────────
-- AUDIT TRIGGER (logs any write done in support mode)
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.log_support_audit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  v_org_id uuid;
  v_session_id uuid;
  v_actor uuid;
  v_record_id uuid;
BEGIN
  v_actor := auth.uid();
  IF v_actor IS NULL THEN
    RETURN COALESCE(NEW, OLD);
  END IF;

  -- Only log when actor is platform admin and a valid support session is active for that org.
  IF NOT public.is_platform_admin(v_actor) THEN
    RETURN COALESCE(NEW, OLD);
  END IF;

  -- Determine org_id and record id from row.
  IF (TG_OP = 'DELETE') THEN
    v_org_id := (to_jsonb(OLD)->>'org_id')::uuid;
    v_record_id := (to_jsonb(OLD)->>'id')::uuid;
  ELSE
    v_org_id := (to_jsonb(NEW)->>'org_id')::uuid;
    v_record_id := (to_jsonb(NEW)->>'id')::uuid;
  END IF;

  IF v_org_id IS NULL THEN
    RETURN COALESCE(NEW, OLD);
  END IF;

  v_session_id := public.active_support_session_id(v_org_id);
  IF v_session_id IS NULL THEN
    RETURN COALESCE(NEW, OLD);
  END IF;

  INSERT INTO public.support_audit_logs(
    session_id,
    actor_user_id,
    org_id,
    table_name,
    action,
    record_id,
    before,
    after
  ) VALUES (
    v_session_id,
    v_actor,
    v_org_id,
    TG_TABLE_NAME,
    TG_OP,
    v_record_id,
    CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) ELSE NULL END
  );

  RETURN COALESCE(NEW, OLD);
EXCEPTION WHEN others THEN
  -- Never block the original write on audit failure.
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Attach triggers to core org-scoped tables (best-effort, idempotent)
DO $$
BEGIN
  -- organizations has id but no org_id; skip (platform audits are mainly for org-scoped tables)
  -- org_members
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_support_audit_org_members') THEN
    CREATE TRIGGER trg_support_audit_org_members
    AFTER INSERT OR UPDATE OR DELETE ON public.org_members
    FOR EACH ROW EXECUTE FUNCTION public.log_support_audit();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_support_audit_members') THEN
    CREATE TRIGGER trg_support_audit_members
    AFTER INSERT OR UPDATE OR DELETE ON public.members
    FOR EACH ROW EXECUTE FUNCTION public.log_support_audit();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_support_audit_contributions') THEN
    CREATE TRIGGER trg_support_audit_contributions
    AFTER INSERT OR UPDATE OR DELETE ON public.contributions
    FOR EACH ROW EXECUTE FUNCTION public.log_support_audit();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_support_audit_expenses') THEN
    CREATE TRIGGER trg_support_audit_expenses
    AFTER INSERT OR UPDATE OR DELETE ON public.expenses
    FOR EACH ROW EXECUTE FUNCTION public.log_support_audit();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_support_audit_loans') THEN
    CREATE TRIGGER trg_support_audit_loans
    AFTER INSERT OR UPDATE OR DELETE ON public.loans
    FOR EACH ROW EXECUTE FUNCTION public.log_support_audit();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_support_audit_mpesa_transactions') THEN
    CREATE TRIGGER trg_support_audit_mpesa_transactions
    AFTER INSERT OR UPDATE OR DELETE ON public.mpesa_transactions
    FOR EACH ROW EXECUTE FUNCTION public.log_support_audit();
  END IF;
END $$;

-- ─────────────────────────────────────────
-- PLATFORM AGGREGATED KPIS (table + recompute fn)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.platform_org_kpis (
  org_id uuid PRIMARY KEY REFERENCES public.organizations(id) ON DELETE CASCADE,
  member_count integer NOT NULL DEFAULT 0,
  total_contributions numeric(12,2) NOT NULL DEFAULT 0,
  total_expenses numeric(12,2) NOT NULL DEFAULT 0,
  loan_count integer NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.platform_org_kpis ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS platform_org_kpis_select_admin ON public.platform_org_kpis;
CREATE POLICY platform_org_kpis_select_admin ON public.platform_org_kpis
  FOR SELECT
  USING (public.is_platform_admin(auth.uid()));

CREATE OR REPLACE FUNCTION public.recompute_platform_org_kpis(p_org_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  v_member_count integer;
  v_total_contrib numeric(12,2);
  v_total_exp numeric(12,2);
  v_loan_count integer;
BEGIN
  SELECT count(*) INTO v_member_count
  FROM public.members m
  WHERE m.org_id = p_org_id
    AND m.is_active = true;

  SELECT COALESCE(sum(c.amount), 0) INTO v_total_contrib
  FROM public.contributions c
  WHERE c.org_id = p_org_id;

  SELECT COALESCE(sum(e.amount), 0) INTO v_total_exp
  FROM public.expenses e
  WHERE e.org_id = p_org_id
    AND e.is_active = true;

  SELECT count(*) INTO v_loan_count
  FROM public.loans l
  WHERE l.org_id = p_org_id;

  INSERT INTO public.platform_org_kpis(org_id, member_count, total_contributions, total_expenses, loan_count, updated_at)
  VALUES (p_org_id, v_member_count, v_total_contrib, v_total_exp, v_loan_count, now())
  ON CONFLICT (org_id) DO UPDATE SET
    member_count = excluded.member_count,
    total_contributions = excluded.total_contributions,
    total_expenses = excluded.total_expenses,
    loan_count = excluded.loan_count,
    updated_at = now();
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_recompute_platform_org_kpis()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  v_org_id uuid;
BEGIN
  v_org_id := COALESCE(
    (to_jsonb(NEW)->>'org_id')::uuid,
    (to_jsonb(OLD)->>'org_id')::uuid
  );
  IF v_org_id IS NOT NULL THEN
    PERFORM public.recompute_platform_org_kpis(v_org_id);
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_kpis_members') THEN
    CREATE TRIGGER trg_kpis_members
    AFTER INSERT OR UPDATE OR DELETE ON public.members
    FOR EACH ROW EXECUTE FUNCTION public.trg_recompute_platform_org_kpis();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_kpis_contributions') THEN
    CREATE TRIGGER trg_kpis_contributions
    AFTER INSERT OR UPDATE OR DELETE ON public.contributions
    FOR EACH ROW EXECUTE FUNCTION public.trg_recompute_platform_org_kpis();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_kpis_expenses') THEN
    CREATE TRIGGER trg_kpis_expenses
    AFTER INSERT OR UPDATE OR DELETE ON public.expenses
    FOR EACH ROW EXECUTE FUNCTION public.trg_recompute_platform_org_kpis();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_kpis_loans') THEN
    CREATE TRIGGER trg_kpis_loans
    AFTER INSERT OR UPDATE OR DELETE ON public.loans
    FOR EACH ROW EXECUTE FUNCTION public.trg_recompute_platform_org_kpis();
  END IF;
END $$;

