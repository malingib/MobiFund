-- Migration to refactor members and users tables
-- Date: 2026-03-19

-- Step 1: Add user_id columns to tables that reference members

ALTER TABLE contributions ADD COLUMN user_id UUID;
ALTER TABLE loans ADD COLUMN user_id UUID;
ALTER TABLE loan_repayments ADD COLUMN user_id UUID;
ALTER TABLE shares ADD COLUMN user_id UUID;
ALTER TABLE goals ADD COLUMN user_id UUID;
ALTER TABLE goal_contributions ADD COLUMN user_id UUID;
ALTER TABLE welfare_contributions ADD COLUMN user_id UUID;

-- Step 2: Populate the new user_id columns

-- Populate contributions
UPDATE contributions c
SET user_id = (
    SELECT om.user_id
    FROM members m
    JOIN org_members om ON m.phone = om.phone
    WHERE m.id = c.member_id
    AND m.org_id = c.org_id
    AND om.org_id = c.org_id
    LIMIT 1
);

-- Populate loans
UPDATE loans l
SET user_id = (
    SELECT om.user_id
    FROM members m
    JOIN org_members om ON m.phone = om.phone
    WHERE m.id = l.member_id
    AND m.org_id = l.org_id
    AND om.org_id = l.org_id
    LIMIT 1
);

-- Populate loan_repayments
UPDATE loan_repayments lr
SET user_id = (
    SELECT om.user_id
    FROM members m
    JOIN org_members om ON m.phone = om.phone
    WHERE m.id = lr.member_id
    AND m.org_id = lr.org_id
    AND om.org_id = lr.org_id
    LIMIT 1
);

-- Populate shares
UPDATE shares s
SET user_id = (
    SELECT om.user_id
    FROM members m
    JOIN org_members om ON m.phone = om.phone
    WHERE m.id = s.member_id
    AND m.org_id = s.org_id
    AND om.org_id = s.org_id
    LIMIT 1
);

-- Populate goals
-- Note: goals table does not have a member_id, so we skip it.

-- Populate goal_contributions
UPDATE goal_contributions gc
SET user_id = (
    SELECT om.user_id
    FROM members m
    JOIN org_members om ON m.phone = om.phone
    WHERE m.id = gc.member_id
    AND m.org_id = gc.org_id
    AND om.org_id = gc.org_id
    LIMIT 1
);

-- Populate welfare_contributions
UPDATE welfare_contributions wc
SET user_id = (
    SELECT om.user_id
    FROM members m
    JOIN org_members om ON m.phone = om.phone
    WHERE m.id = wc.member_id
    AND m.org_id = wc.org_id
    AND om.org_id = wc.org_id
    LIMIT 1
);

-- Step 3: Add foreign key constraints to the new user_id columns

ALTER TABLE contributions ADD CONSTRAINT fk_contributions_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE loan_repayments ADD CONSTRAINT fk_loan_repayments_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE shares ADD CONSTRAINT fk_shares_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE goal_contributions ADD CONSTRAINT fk_goal_contributions_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE welfare_contributions ADD CONSTRAINT fk_welfare_contributions_user_id FOREIGN KEY (user_id) REFERENCES users(id);

-- Step 4: Drop the old member_id columns

ALTER TABLE contributions DROP COLUMN member_id;
ALTER TABLE loans DROP COLUMN member_id;
ALTER TABLE loan_repayments DROP COLUMN member_id;
ALTER TABLE shares DROP COLUMN member_id;
ALTER TABLE goal_contributions DROP COLUMN member_id;
ALTER TABLE welfare_contributions DROP COLUMN member_id;

-- Step 5: Drop the members table

DROP TABLE members;

-- Step 6: Update RLS policies

-- No changes needed for contributions, loans, etc. as the policies are based on org_id, not member_id.
-- The policies for these tables already correctly check if the user is a member of the organization.

-- Add RLS policy for users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_select ON users;
CREATE POLICY users_select ON users
    FOR SELECT
    USING (
        auth.uid() = id
    );

DROP POLICY IF EXISTS users_update ON users;
CREATE POLICY users_update ON users
    FOR UPDATE
    USING (
        auth.uid() = id
    );
