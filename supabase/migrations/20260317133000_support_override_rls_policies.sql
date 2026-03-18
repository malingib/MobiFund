-- Extend org-scoped RLS to allow controlled support override.
-- Date: 2026-03-17

-- These policies assume helper functions exist:
-- - public.is_org_member(uuid)
-- - public.is_org_admin(uuid)
-- - public.has_active_support_session(uuid)
--
-- NOTE: For support override we allow platform admin writes ONLY when a valid
-- support session is active for that org. Writes are audited by triggers.

-- ORG MEMBERS
DROP POLICY IF EXISTS org_members_select ON public.org_members;
CREATE POLICY org_members_select ON public.org_members
  FOR SELECT
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS org_members_insert ON public.org_members;
CREATE POLICY org_members_insert ON public.org_members
  FOR INSERT
  WITH CHECK (
    -- normal membership path
    (
      auth.uid() IS NOT NULL
      AND user_id = auth.uid()
      AND (
        public.is_org_admin(org_id)
        OR NOT public.org_has_any_members(org_id)
      )
    )
    -- support override path
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS org_members_update ON public.org_members;
CREATE POLICY org_members_update ON public.org_members
  FOR UPDATE
  USING (
    public.is_org_admin(org_id)
    OR public.has_active_support_session(org_id)
  )
  WITH CHECK (true);

DROP POLICY IF EXISTS org_members_delete ON public.org_members;
CREATE POLICY org_members_delete ON public.org_members
  FOR DELETE
  USING (
    public.is_org_admin(org_id)
    OR public.has_active_support_session(org_id)
  );

-- ORGANIZATIONS
DROP POLICY IF EXISTS org_select ON public.organizations;
CREATE POLICY org_select ON public.organizations
  FOR SELECT
  USING (
    public.is_org_member(id)
    OR public.has_active_support_session(id)
    OR public.is_platform_admin(auth.uid())
  );

DROP POLICY IF EXISTS org_update ON public.organizations;
CREATE POLICY org_update ON public.organizations
  FOR UPDATE
  USING (
    public.is_org_admin(id)
    OR public.has_active_support_session(id)
  )
  WITH CHECK (true);

-- MEMBERS
DROP POLICY IF EXISTS members_select ON public.members;
CREATE POLICY members_select ON public.members
  FOR SELECT
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS members_insert ON public.members;
CREATE POLICY members_insert ON public.members
  FOR INSERT
  WITH CHECK (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS members_update ON public.members;
CREATE POLICY members_update ON public.members
  FOR UPDATE
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  )
  WITH CHECK (true);

DROP POLICY IF EXISTS members_delete ON public.members;
CREATE POLICY members_delete ON public.members
  FOR DELETE
  USING (
    public.is_org_admin(org_id)
    OR public.has_active_support_session(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.members.org_id
        AND om.user_id = auth.uid()
        AND om.role IN ('treasurer','secretary')
        AND om.is_active = true
    )
  );

-- CONTRIBUTIONS
DROP POLICY IF EXISTS contributions_select ON public.contributions;
CREATE POLICY contributions_select ON public.contributions
  FOR SELECT
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS contributions_insert ON public.contributions;
CREATE POLICY contributions_insert ON public.contributions
  FOR INSERT
  WITH CHECK (
    public.has_active_support_session(org_id)
    OR public.is_org_admin(org_id)
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
    public.has_active_support_session(org_id)
    OR public.is_org_admin(org_id)
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
    public.has_active_support_session(org_id)
    OR public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.contributions.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

-- EXPENSES
DROP POLICY IF EXISTS expenses_select ON public.expenses;
CREATE POLICY expenses_select ON public.expenses
  FOR SELECT
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS expenses_insert ON public.expenses;
CREATE POLICY expenses_insert ON public.expenses
  FOR INSERT
  WITH CHECK (
    public.has_active_support_session(org_id)
    OR public.is_org_admin(org_id)
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
    public.has_active_support_session(org_id)
    OR public.is_org_admin(org_id)
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
    public.has_active_support_session(org_id)
    OR public.is_org_admin(org_id)
    OR EXISTS (
      SELECT 1
      FROM public.org_members om
      WHERE om.org_id = public.expenses.org_id
        AND om.user_id = auth.uid()
        AND om.role = 'treasurer'
        AND om.is_active = true
    )
  );

-- LOANS
DROP POLICY IF EXISTS loans_select ON public.loans;
CREATE POLICY loans_select ON public.loans
  FOR SELECT
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS loans_insert ON public.loans;
CREATE POLICY loans_insert ON public.loans
  FOR INSERT
  WITH CHECK (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

DROP POLICY IF EXISTS loans_update ON public.loans;
CREATE POLICY loans_update ON public.loans
  FOR UPDATE
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  )
  WITH CHECK (true);

DROP POLICY IF EXISTS loans_delete ON public.loans;
CREATE POLICY loans_delete ON public.loans
  FOR DELETE
  USING (
    public.is_org_admin(org_id)
    OR public.has_active_support_session(org_id)
  );

-- MPESA TRANSACTIONS (org scoped, sensitive)
-- keep platform admin access via support session only
DROP POLICY IF EXISTS mpesa_select ON public.mpesa_transactions;
CREATE POLICY mpesa_select ON public.mpesa_transactions
  FOR SELECT
  USING (
    public.is_org_member(org_id)
    OR public.has_active_support_session(org_id)
  );

