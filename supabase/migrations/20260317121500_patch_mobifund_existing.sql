-- Patch migration for pre-existing projects
-- Ensures required columns/constraints exist even if tables already existed.

-- organizations.tier
ALTER TABLE IF EXISTS public.organizations
  ADD COLUMN IF NOT EXISTS tier TEXT NOT NULL DEFAULT 'free';
DO $$
BEGIN
  -- Ensure allowed values (best-effort; avoids failure if already present)
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'organizations_tier_check'
  ) THEN
    BEGIN
      ALTER TABLE public.organizations
        ADD CONSTRAINT organizations_tier_check CHECK (tier IN ('free','pro','enterprise'));
    EXCEPTION WHEN others THEN
      -- ignore if cannot add (e.g., existing conflicting constraint)
      NULL;
    END;
  END IF;
END $$;

-- org_members: add profile columns; ensure user_id references auth.users
ALTER TABLE IF EXISTS public.org_members
  ADD COLUMN IF NOT EXISTS name TEXT,
  ADD COLUMN IF NOT EXISTS phone TEXT,
  ADD COLUMN IF NOT EXISTS email TEXT;

DO $$
DECLARE
  fk_name text;
  fk_def text;
BEGIN
  -- If org_members.user_id currently references public.users(id), switch to auth.users(id)
  SELECT c.conname, pg_get_constraintdef(c.oid)
    INTO fk_name, fk_def
  FROM pg_constraint c
  JOIN pg_class t ON t.oid = c.conrelid
  WHERE c.contype = 'f'
    AND t.relname = 'org_members'
    AND pg_get_constraintdef(c.oid) ILIKE '%(user_id)%REFERENCES users%';

  IF fk_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.org_members DROP CONSTRAINT %I', fk_name);
    BEGIN
      ALTER TABLE public.org_members
        ADD CONSTRAINT org_members_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
    EXCEPTION WHEN others THEN
      -- ignore if already exists / cannot add
      NULL;
    END;
  END IF;
END $$;

-- contributions: payment metadata
ALTER TABLE IF EXISTS public.contributions
  ADD COLUMN IF NOT EXISTS payment_method TEXT,
  ADD COLUMN IF NOT EXISTS transaction_code TEXT;
CREATE INDEX IF NOT EXISTS idx_contributions_tx_code ON public.contributions(transaction_code);

-- expenses: soft delete flag
ALTER TABLE IF EXISTS public.expenses
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- mpesa_transactions: richer fields + idempotency
ALTER TABLE IF EXISTS public.mpesa_transactions
  ADD COLUMN IF NOT EXISTS result_code INTEGER,
  ADD COLUMN IF NOT EXISTS result_desc TEXT,
  ADD COLUMN IF NOT EXISTS raw_payload JSONB;

-- Ensure column names expected by Edge Functions exist
ALTER TABLE IF EXISTS public.mpesa_transactions
  ADD COLUMN IF NOT EXISTS mpesa_receipt_number TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mpesa_checkout_unique
  ON public.mpesa_transactions(checkout_request_id)
  WHERE checkout_request_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_mpesa_receipt_unique
  ON public.mpesa_transactions(mpesa_receipt_number)
  WHERE mpesa_receipt_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mpesa_org_created ON public.mpesa_transactions(org_id, created_at DESC);

-- RLS enable (idempotent)
ALTER TABLE IF EXISTS public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.mpesa_transactions ENABLE ROW LEVEL SECURITY;

-- Policies (safe to reapply)
DROP POLICY IF EXISTS org_select ON public.organizations;
CREATE POLICY org_select ON public.organizations
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.org_members
    WHERE public.org_members.org_id = public.organizations.id
      AND public.org_members.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS org_insert ON public.organizations;
CREATE POLICY org_insert ON public.organizations
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS org_update ON public.organizations;
CREATE POLICY org_update ON public.organizations
  FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM public.org_members
    WHERE public.org_members.org_id = public.organizations.id
      AND public.org_members.user_id = auth.uid()
      AND public.org_members.role = 'admin'
      AND public.org_members.is_active = true
  ))
  WITH CHECK (true);

DROP POLICY IF EXISTS org_members_select ON public.org_members;
CREATE POLICY org_members_select ON public.org_members
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.org_members om
    WHERE om.org_id = public.org_members.org_id
      AND om.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS members_select ON public.members;
CREATE POLICY members_select ON public.members
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.org_members
    WHERE public.org_members.org_id = public.members.org_id
      AND public.org_members.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS contributions_select ON public.contributions;
CREATE POLICY contributions_select ON public.contributions
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.org_members
    WHERE public.org_members.org_id = public.contributions.org_id
      AND public.org_members.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS expenses_select ON public.expenses;
CREATE POLICY expenses_select ON public.expenses
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.org_members
    WHERE public.org_members.org_id = public.expenses.org_id
      AND public.org_members.user_id = auth.uid()
  ));

DROP POLICY IF EXISTS mpesa_select ON public.mpesa_transactions;
CREATE POLICY mpesa_select ON public.mpesa_transactions
  FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.org_members
    WHERE public.org_members.org_id = public.mpesa_transactions.org_id
      AND public.org_members.user_id = auth.uid()
      AND public.org_members.is_active = true
  ));

