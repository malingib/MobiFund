-- Fix RLS recursion on org_members
-- Error observed: "infinite recursion detected in policy for relation org_members" (42P17)
-- Date: 2026-03-17

-- Helper functions must bypass RLS to avoid self-referential policies.
CREATE OR REPLACE FUNCTION public.org_has_any_members(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.org_members om
    WHERE om.org_id = p_org_id
  );
$$;

CREATE OR REPLACE FUNCTION public.is_org_member(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.org_members om
    WHERE om.org_id = p_org_id
      AND om.user_id = auth.uid()
      AND om.is_active = true
  );
$$;

CREATE OR REPLACE FUNCTION public.is_org_admin(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.org_members om
    WHERE om.org_id = p_org_id
      AND om.user_id = auth.uid()
      AND om.role = 'admin'
      AND om.is_active = true
  );
$$;

-- Ensure RLS is enabled (idempotent)
ALTER TABLE IF EXISTS public.org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.mpesa_transactions ENABLE ROW LEVEL SECURITY;

-- Recreate policies using helper functions (no direct org_members self-queries in policies)

-- org_members
DROP POLICY IF EXISTS org_members_select ON public.org_members;
CREATE POLICY org_members_select ON public.org_members
  FOR SELECT
  USING (public.is_org_member(org_id));

DROP POLICY IF EXISTS org_members_insert ON public.org_members;
CREATE POLICY org_members_insert ON public.org_members
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND user_id = auth.uid()
    AND (
      public.is_org_admin(org_id)
      OR NOT public.org_has_any_members(org_id)
    )
  );

DROP POLICY IF EXISTS org_members_update ON public.org_members;
CREATE POLICY org_members_update ON public.org_members
  FOR UPDATE
  USING (public.is_org_admin(org_id))
  WITH CHECK (true);

DROP POLICY IF EXISTS org_members_delete ON public.org_members;
CREATE POLICY org_members_delete ON public.org_members
  FOR DELETE
  USING (public.is_org_admin(org_id));

-- organizations
DROP POLICY IF EXISTS org_select ON public.organizations;
CREATE POLICY org_select ON public.organizations
  FOR SELECT
  USING (public.is_org_member(id));

DROP POLICY IF EXISTS org_update ON public.organizations;
CREATE POLICY org_update ON public.organizations
  FOR UPDATE
  USING (public.is_org_admin(id))
  WITH CHECK (true);

-- members
DROP POLICY IF EXISTS members_select ON public.members;
CREATE POLICY members_select ON public.members
  FOR SELECT
  USING (public.is_org_member(org_id));

DROP POLICY IF EXISTS members_insert ON public.members;
CREATE POLICY members_insert ON public.members
  FOR INSERT
  WITH CHECK (public.is_org_member(org_id));

DROP POLICY IF EXISTS members_update ON public.members;
CREATE POLICY members_update ON public.members
  FOR UPDATE
  USING (public.is_org_member(org_id))
  WITH CHECK (true);

DROP POLICY IF EXISTS members_delete ON public.members;
CREATE POLICY members_delete ON public.members
  FOR DELETE
  USING (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.members.org_id
        AND om.user_id = auth.uid()
        AND om.role IN ('treasurer','secretary')
        AND om.is_active = true
    )
  );

-- contributions
DROP POLICY IF EXISTS contributions_select ON public.contributions;
CREATE POLICY contributions_select ON public.contributions
  FOR SELECT
  USING (public.is_org_member(org_id));

DROP POLICY IF EXISTS contributions_insert ON public.contributions;
CREATE POLICY contributions_insert ON public.contributions
  FOR INSERT
  WITH CHECK (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.contributions.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

DROP POLICY IF EXISTS contributions_update ON public.contributions;
CREATE POLICY contributions_update ON public.contributions
  FOR UPDATE
  USING (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.contributions.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  )
  WITH CHECK (true);

DROP POLICY IF EXISTS contributions_delete ON public.contributions;
CREATE POLICY contributions_delete ON public.contributions
  FOR DELETE
  USING (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.contributions.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

-- expenses
DROP POLICY IF EXISTS expenses_select ON public.expenses;
CREATE POLICY expenses_select ON public.expenses
  FOR SELECT
  USING (public.is_org_member(org_id));

DROP POLICY IF EXISTS expenses_insert ON public.expenses;
CREATE POLICY expenses_insert ON public.expenses
  FOR INSERT
  WITH CHECK (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.expenses.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

DROP POLICY IF EXISTS expenses_update ON public.expenses;
CREATE POLICY expenses_update ON public.expenses
  FOR UPDATE
  USING (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.expenses.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  )
  WITH CHECK (true);

DROP POLICY IF EXISTS expenses_delete ON public.expenses;
CREATE POLICY expenses_delete ON public.expenses
  FOR DELETE
  USING (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.expenses.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

-- mpesa_transactions
DROP POLICY IF EXISTS mpesa_select ON public.mpesa_transactions;
CREATE POLICY mpesa_select ON public.mpesa_transactions
  FOR SELECT
  USING (public.is_org_member(org_id));

DROP POLICY IF EXISTS mpesa_insert ON public.mpesa_transactions;
CREATE POLICY mpesa_insert ON public.mpesa_transactions
  FOR INSERT
  WITH CHECK (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.mpesa_transactions.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

DROP POLICY IF EXISTS mpesa_update ON public.mpesa_transactions;
CREATE POLICY mpesa_update ON public.mpesa_transactions
  FOR UPDATE
  USING (
    public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.mpesa_transactions.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  )
  WITH CHECK (true);

