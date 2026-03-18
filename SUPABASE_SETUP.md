# Supabase Configuration Guide

## Overview
This document explains how the MobiFund app uses Supabase for backend data synchronization while maintaining offline-first capabilities with SQLite.

## Security Notes

### ⚠️ IMPORTANT: Environment Variables
The app now uses environment variables for Supabase credentials. The `.env` file contains:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Public anon key (safe for client-side)
- `SUPABASE_SERVICE_ROLE_KEY`: **SERVER-SIDE ONLY** - Never expose in client code
- `JWT_SECRET`: **SERVER-SIDE ONLY** - For server-side JWT verification

### Key Security Principles

1. **Anon Key (Client-Side)**: Safe to include in the app. Works with Row Level Security (RLS) policies.

2. **Service Role Key (Server-Side ONLY)**: 
   - **NEVER** use in mobile app code
   - Only use in Supabase Edge Functions
   - Bypasses all RLS policies
   - Full database access

3. **.env File**: 
   - Already added to `.gitignore`
   - Never commit to version control
   - Share securely with team members

## Architecture

### Data Flow

```
┌─────────────────┐     Online      ┌──────────────┐
│   Flutter App   │ ──────────────> │   Supabase   │
│                 │ <────────────── │   Backend    │
│  (SQLite Local) │     Sync        │  (PostgreSQL)│
└─────────────────┘                 └──────────────┘
        │
        │ Offline
        │
        └─────────────> Local Operations Only
```

### How It Works

1. **App Initialization**:
   - Loads `.env` file with `flutter_dotenv`
   - Initializes Supabase with credentials from environment
   - Checks connectivity status

2. **Data Loading** (Online Mode):
   - Fetches data from Supabase first
   - Syncs to local SQLite database
   - Updates UI with fresh data

3. **Data Loading** (Offline Mode):
   - Uses local SQLite database only
   - All CRUD operations work locally
   - Queues changes for later sync

4. **Sync Process**:
   - Pushes local changes to Supabase
   - Pulls remote changes from Supabase
   - Resolves conflicts (last-write-wins)

## Database Tables

The app uses the following tables in Supabase:

### Core Tables
- `organizations` - Chama/groups
- `org_members` - Member roles and permissions
- `org_modules` - Activated features per org

### Data Tables
- `members` - Regular members
- `contributions` - Member contributions
- `expenses` - Organization expenses
- `loans` - Loan applications
- `loan_repayments` - Loan repayment records
- `merry_go_round_cycles` - Rotating savings cycles
- `shares` - Member shares
- `goals` - Organization goals
- `goal_contributions` - Contributions to goals
- `welfare_contributions` - Welfare fund contributions

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment
Copy the `.env` file and update with your credentials:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key  # For Edge Functions only
```

### 3. Set Up Supabase Database

Run the following SQL in your Supabase SQL Editor:

```sql
-- Enable Row Level Security
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE loan_repayments ENABLE ROW LEVEL SECURITY;
ALTER TABLE merry_go_round_cycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE welfare_contributions ENABLE ROW LEVEL SECURITY;

-- Create policies (example for organizations)
CREATE POLICY "Users can view their organizations"
  ON organizations FOR SELECT
  USING (auth.uid() IN (
    SELECT user_id FROM org_members WHERE org_id = id
  ));

-- Add more policies for other tables...
```

### 4. Run the App
```bash
flutter run
```

## Files Modified

1. **`.env`** - Environment variables (new file)
2. **`.gitignore`** - Added `.env` exclusion
3. **`pubspec.yaml`** - Added `flutter_dotenv` dependency
4. **`lib/main.dart`** - Initialize dotenv and Supabase
5. **`lib/services/supabase_service.dart`** - Load credentials from env
6. **`lib/services/app_state.dart`** - Fetch from Supabase when online
7. **`lib/services/local_db.dart`** - Added V4 migration for missing tables
8. **`lib/widgets/org_switcher.dart`** - Fixed UI overflow bug

## Troubleshooting

### Database Tables Missing
If you see "no such table" errors:
1. The app will auto-migrate the local database
2. For Supabase, ensure tables are created in your Supabase project

### Sync Not Working
1. Check internet connectivity
2. Verify Supabase credentials in `.env`
3. Check RLS policies in Supabase
4. Review logs for specific errors

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Best Practices

1. **Never commit `.env`** - Already in `.gitignore`
2. **Use RLS policies** - Secure your data at database level
3. **Test offline mode** - Ensure app works without connectivity
4. **Handle sync conflicts** - Implement proper conflict resolution
5. **Monitor API usage** - Keep track of Supabase usage limits

## Support

For issues or questions:
1. Check Flutter logs: `flutter logs`
2. Review Supabase dashboard for API errors
3. Inspect local database with DevTools
