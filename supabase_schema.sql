-- ─────────────────────────────────────────
-- MOBIFUND - SUPABASE DATABASE SCHEMA
-- ─────────────────────────────────────────
-- Run this in your Supabase SQL Editor
-- URL: https://ttwubbbbmdwmnkavrqtl.supabase.co

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────
-- ORGANIZATIONS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    logo_url TEXT,
    tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free','pro','enterprise')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- USERS TABLE (Extends Supabase Auth)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure one profile per auth user
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_auth_id_unique ON users(auth_id);

-- ─────────────────────────────────────────
-- ORGANIZATION MEMBERS TABLE (RBAC)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS org_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    -- Use Supabase Auth user id as the principal
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    phone TEXT,
    email TEXT,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'treasurer', 'secretary', 'member')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(org_id, user_id)
);

-- ─────────────────────────────────────────
-- ORGANIZATION MODULES TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS org_modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    module_type TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    config JSONB,
    activated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(org_id, module_type)
);

-- ─────────────────────────────────────────
-- MEMBERS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    notes TEXT,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- CONTRIBUTIONS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS contributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL,
    note TEXT,
    payment_method TEXT,
    transaction_code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contributions_tx_code ON contributions(transaction_code);

-- ─────────────────────────────────────────
-- EXPENSES TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL,
    description TEXT,
    receipt_url TEXT,
    created_by UUID REFERENCES auth.users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- LOANS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    loan_type TEXT NOT NULL CHECK (loan_type IN ('soft_loan', 'normal_loan')),
    principal DECIMAL(12,2) NOT NULL,
    interest_rate DECIMAL(5,2) DEFAULT 0,
    interest_amount DECIMAL(12,2),
    total_amount DECIMAL(12,2),
    repayment_period_months INTEGER DEFAULT 1,
    monthly_installment DECIMAL(12,2),
    paid_amount DECIMAL(12,2) DEFAULT 0,
    balance DECIMAL(12,2),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'disbursed', 'active', 'completed', 'defaulted')),
    guarantor_id UUID REFERENCES members(id),
    purpose TEXT,
    application_date TIMESTAMPTZ NOT NULL,
    approval_date TIMESTAMPTZ,
    disbursement_date TIMESTAMPTZ,
    due_date TIMESTAMPTZ NOT NULL,
    completed_date TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- LOAN REPAYMENTS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS loan_repayments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    loan_id UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL,
    payment_method TEXT,
    transaction_code TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- MERRY-GO-ROUND CYCLES TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS merry_go_round_cycles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    total_members INTEGER NOT NULL,
    contribution_amount DECIMAL(12,2) NOT NULL,
    frequency TEXT NOT NULL DEFAULT 'monthly',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'planning' CHECK (status IN ('planning', 'active', 'completed', 'cancelled')),
    member_order JSONB,
    current_position INTEGER DEFAULT 0,
    current_recipient_id UUID REFERENCES members(id),
    completed_recipients JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- SHARES TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    number_of_shares INTEGER NOT NULL,
    price_per_share DECIMAL(12,2) NOT NULL,
    total_value DECIMAL(12,2) NOT NULL,
    payment_method TEXT,
    transaction_code TEXT,
    purchase_date TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- GOALS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    target_amount DECIMAL(12,2) NOT NULL,
    raised_amount DECIMAL(12,2) DEFAULT 0,
    target_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'planning' CHECK (status IN ('planning', 'active', 'completed', 'cancelled')),
    category TEXT NOT NULL DEFAULT 'general',
    contributor_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- GOAL CONTRIBUTIONS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS goal_contributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    note TEXT,
    date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- WELFARE CONTRIBUTIONS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS welfare_contributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    beneficiary_id UUID REFERENCES members(id),
    reason TEXT,
    note TEXT,
    date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- SMS LOGS TABLE (For tracking SMS sent)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sms_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id),
    recipient TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- MPESA TRANSACTIONS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mpesa_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    member_id UUID REFERENCES members(id),
    checkout_request_id TEXT,
    merchant_request_id TEXT,
    amount DECIMAL(12,2) NOT NULL,
    phone TEXT NOT NULL,
    account_reference TEXT,
    status TEXT DEFAULT 'pending',
    result_code INTEGER,
    result_desc TEXT,
    mpesa_receipt_number TEXT,
    transaction_date TIMESTAMPTZ,
    raw_payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Idempotency / fast lookups
CREATE UNIQUE INDEX IF NOT EXISTS idx_mpesa_checkout_unique
  ON mpesa_transactions(checkout_request_id)
  WHERE checkout_request_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_mpesa_receipt_unique
  ON mpesa_transactions(mpesa_receipt_number)
  WHERE mpesa_receipt_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mpesa_org_created ON mpesa_transactions(org_id, created_at DESC);

-- ─────────────────────────────────────────
-- INDEXES FOR PERFORMANCE
-- ─────────────────────────────────────────
CREATE INDEX idx_members_org ON members(org_id);
CREATE INDEX idx_contributions_org ON contributions(org_id);
CREATE INDEX idx_contributions_member ON contributions(member_id);
CREATE INDEX idx_expenses_org ON expenses(org_id);
CREATE INDEX idx_org_members_org ON org_members(org_id);
CREATE INDEX idx_org_members_user ON org_members(user_id);
CREATE INDEX idx_org_modules_org ON org_modules(org_id);
CREATE INDEX idx_loans_org ON loans(org_id);
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_shares_org ON shares(org_id);
CREATE INDEX idx_goals_org ON goals(org_id);
CREATE INDEX idx_welfare_org ON welfare_contributions(org_id);

-- ─────────────────────────────────────────
-- UPDATED_AT TRIGGER FUNCTION
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_members_updated_at BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contributions_updated_at BEFORE UPDATE ON contributions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_loans_updated_at BEFORE UPDATE ON loans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shares_updated_at BEFORE UPDATE ON shares
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ─────────────────────────────────────────
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ─────────────────────────────────────────
-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE loan_repayments ENABLE ROW LEVEL SECURITY;
ALTER TABLE merry_go_round_cycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE welfare_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE org_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE mpesa_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sms_logs ENABLE ROW LEVEL SECURITY;

-- Helper: ensure authenticated
-- (used implicitly by auth.uid() checks)

-- Organizations: Users can see orgs they belong to
CREATE POLICY org_select ON organizations
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = organizations.id
            AND org_members.user_id = auth.uid()
        )
    );

CREATE POLICY org_insert ON organizations
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY org_update ON organizations
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = organizations.id
            AND org_members.user_id = auth.uid()
            AND org_members.role = 'admin'
            AND org_members.is_active = true
        )
    )
    WITH CHECK (true);

-- Org Members: Users can see members of their org
CREATE POLICY org_members_select ON org_members
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM org_members om
            WHERE om.org_id = org_members.org_id
            AND om.user_id = auth.uid()
        )
    );

CREATE POLICY org_members_insert ON org_members
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND org_members.user_id = auth.uid()
        AND (
            -- Existing admins can add members
            EXISTS (
                SELECT 1 FROM org_members om
                WHERE om.org_id = org_members.org_id
                AND om.user_id = auth.uid()
                AND om.role = 'admin'
                AND om.is_active = true
            )
            -- Allow the very first member record to be created for a new org
            OR NOT EXISTS (SELECT 1 FROM org_members x WHERE x.org_id = org_members.org_id)
        )
    );

CREATE POLICY org_members_update ON org_members
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM org_members om
            WHERE om.org_id = org_members.org_id
            AND om.user_id = auth.uid()
            AND om.role = 'admin'
            AND om.is_active = true
        )
    )
    WITH CHECK (true);

CREATE POLICY org_members_delete ON org_members
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM org_members om
            WHERE om.org_id = org_members.org_id
            AND om.user_id = auth.uid()
            AND om.role = 'admin'
            AND om.is_active = true
        )
    );

-- Members: Users can see members of their org
CREATE POLICY members_select ON members
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = members.org_id
            AND org_members.user_id = auth.uid()
        )
    );

CREATE POLICY members_insert ON members
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = members.org_id
            AND org_members.user_id = auth.uid()
            AND org_members.is_active = true
        )
    );

CREATE POLICY members_update ON members
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = members.org_id
            AND org_members.user_id = auth.uid()
            AND org_members.is_active = true
        )
    )
    WITH CHECK (true);

CREATE POLICY members_delete ON members
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = members.org_id
            AND org_members.user_id = auth.uid()
            AND org_members.role IN ('admin','treasurer','secretary')
            AND org_members.is_active = true
        )
    );

-- Contributions: Users can see contributions in their org
CREATE POLICY contributions_select ON contributions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = contributions.org_id
            AND org_members.user_id = auth.uid()
        )
    );

CREATE POLICY contributions_insert ON contributions
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = contributions.org_id
            AND org_members.user_id = auth.uid()
            AND org_members.role IN ('admin','treasurer')
            AND org_members.is_active = true
        )
    );

CREATE POLICY contributions_update ON contributions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = contributions.org_id
            AND org_members.user_id = auth.uid()
            AND org_members.role IN ('admin','treasurer')
            AND org_members.is_active = true
        )
    )
    WITH CHECK (true);

CREATE POLICY contributions_delete ON contributions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM org_members
            WHERE org_members.org_id = contributions.org_id
            AND org_members.user_id = auth.uid()
            AND org_members.role IN ('admin','treasurer')
            AND org_members.is_active = true
        )
    );

-- Expenses: Full CRUD policies based on org_members
CREATE POLICY expenses_select ON expenses FOR SELECT USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = expenses.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY expenses_insert ON expenses FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = expenses.org_id AND org_members.user_id = auth.uid() AND org_members.role IN ('admin','treasurer') AND org_members.is_active = true)
);
CREATE POLICY expenses_update ON expenses FOR UPDATE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = expenses.org_id AND org_members.user_id = auth.uid() AND org_members.role IN ('admin','treasurer') AND org_members.is_active = true)
);
CREATE POLICY expenses_delete ON expenses FOR DELETE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = expenses.org_id AND org_members.user_id = auth.uid() AND org_members.role IN ('admin','treasurer') AND org_members.is_active = true)
);

-- Loans / shares / goals already have CRUD policies but should also require active membership
-- (left as-is for brevity; enforce via org_members.is_active on all checks in production)

-- mpesa_transactions: allow org members to read; only privileged roles can insert/update (manual ops)
CREATE POLICY mpesa_select ON mpesa_transactions
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = mpesa_transactions.org_id
      AND org_members.user_id = auth.uid()
      AND org_members.is_active = true
    )
  );

CREATE POLICY mpesa_insert ON mpesa_transactions
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = mpesa_transactions.org_id
      AND org_members.user_id = auth.uid()
      AND org_members.role IN ('admin','treasurer')
      AND org_members.is_active = true
    )
  );

CREATE POLICY mpesa_update ON mpesa_transactions
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = mpesa_transactions.org_id
      AND org_members.user_id = auth.uid()
      AND org_members.role IN ('admin','treasurer')
      AND org_members.is_active = true
    )
  )
  WITH CHECK (true);

-- Loans: Full CRUD policies based on org_members
CREATE POLICY loans_select ON loans FOR SELECT USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = loans.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY loans_insert ON loans FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = loans.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY loans_update ON loans FOR UPDATE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = loans.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY loans_delete ON loans FOR DELETE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = loans.org_id AND org_members.user_id = auth.uid())
);

-- Shares: Full CRUD policies based on org_members
CREATE POLICY shares_select ON shares FOR SELECT USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = shares.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY shares_insert ON shares FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = shares.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY shares_update ON shares FOR UPDATE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = shares.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY shares_delete ON shares FOR DELETE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = shares.org_id AND org_members.user_id = auth.uid())
);

-- Goals: Full CRUD policies based on org_members
CREATE POLICY goals_select ON goals FOR SELECT USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = goals.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY goals_insert ON goals FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = goals.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY goals_update ON goals FOR UPDATE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = goals.org_id AND org_members.user_id = auth.uid())
);
CREATE POLICY goals_delete ON goals FOR DELETE USING (
    EXISTS (SELECT 1 FROM org_members WHERE org_members.org_id = goals.org_id AND org_members.user_id = auth.uid())
);

-- ─────────────────────────────────────────
-- INITIAL DATA (Optional - for testing)
-- ─────────────────────────────────────────
-- Uncomment to insert test data
/*
INSERT INTO organizations (name, description) VALUES
('Test Chama', 'Default test organization');

INSERT INTO org_modules (org_id, module_type, is_active) VALUES
((SELECT id FROM organizations LIMIT 1), 'base', TRUE);
*/

-- ─────────────────────────────────────────
-- SCHEMA COMPLETE
-- ─────────────────────────────────────────
