# Mobifund - Fully Modular Chama Management System

## 📋 Architecture Overview

### Current State (Base Module)
Your app currently has a solid foundation with:
- ✅ **Members Management** - Add, view, remove members
- ✅ **Contributions Tracking** - Record and monitor member contributions
- ✅ **Expenses Management** - Track group expenses by category
- ✅ **Offline-First** - SQLite local storage with sync capability
- ✅ **Clean UI** - Modern Material Design 3 interface

---

## 🏗️ Enhanced Architecture

### 1. Multi-Tenancy System

Each chama/organization has isolated data:

```
┌─────────────────────────────────────────────────────────┐
│                    Mobifund Platform                     │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Chama A    │  │  Chama B    │  │  Chama C    │     │
│  │  (Org 1)    │  │  (Org 2)    │  │  (Org 3)    │     │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤     │
│  │ Members     │  │ Members     │  │ Members     │     │
│  │ Contributions│ │ Contributions│ │ Contributions│     │
│  │ Expenses    │  │ Expenses    │  │ Expenses    │     │
│  │ [Modules]   │  │ [Modules]   │  │ [Modules]   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

**Database Tables:**
- `organizations` - Chama/Group information
- `org_members` - User-Organization relationship with roles
- `org_modules` - Activated modules per organization
- `members`, `contributions`, `expenses` - Enhanced with `org_id`

---

### 2. Role-Based Access Control (RBAC)

```
┌──────────────────────────────────────────────────────┐
│                    User Roles                         │
├──────────────────────────────────────────────────────┤
│  👑 Admin         | Full access to everything        │
│  💰 Treasurer     | Manage finances, loans, expenses │
│  📝 Secretary     | Manage members, communications   │
│  👤 Member        | View own data, contribute        │
└──────────────────────────────────────────────────────┘
```

**Permissions Matrix:**

| Feature          | Admin | Treasurer | Secretary | Member |
|-----------------|-------|-----------|-----------|--------|
| View Dashboard  | ✅    | ✅        | ✅        | ✅     |
| Add Member      | ✅    | ❌        | ✅        | ❌     |
| Remove Member   | ✅    | ❌        | ❌        | ❌     |
| Record Contribution | ✅ | ✅        | ❌        | ❌     |
| Record Expense  | ✅    | ✅        | ❌        | ❌     |
| Manage Loans    | ✅    | ✅        | ❌        | ❌     |
| Send SMS        | ✅    | ✅        | ✅        | ❌     |
| Activate Modules| ✅    | ❌        | ❌        | ❌     |
| Switch Org      | ✅    | ✅        | ✅        | ✅     |

---

### 3. Modular Feature System

**Base Module (Always Active):**
- Contributions
- Expenses
- Members
- Dashboard

**Optional Modules:**

```
┌─────────────────────────────────────────────────────────┐
│              Available Modules                           │
├─────────────────────────────────────────────────────────┤
│  💰 Loans Module                                         │
│     ├─ Soft Loans (payable within 1 month)              │
│     └─ Normal Loans (custom repayment period)           │
│                                                          │
│  🔄 Merry-Go-Round Module                               │
│     ├─ Rotational savings                               │
│     └─ Automated distribution scheduling                │
│                                                          │
│  📈 Shares & Savings Module                             │
│     ├─ Track member shares                              │
│     └─ Share-based loan eligibility                     │
│                                                          │
│  🎯 Goals & Investment Module                           │
│     ├─ Group investment goals                           │
│     └─ Progress tracking per member                     │
│                                                          │
│  ❤️ Welfare Module                                      │
│     ├─ Member support fund                              │
│     └─ Contribution tracking for members in need        │
└─────────────────────────────────────────────────────────┘
```

**Module Activation Flow:**
```
Organization → Settings → Modules → Toggle On/Off → Configure
```

---

### 4. SMS Integration (Mobiwave API)

**Use Cases:**
- ✅ Contribution received notifications
- ✅ Expense alerts
- ✅ Loan approval/disbursement notifications
- ✅ Merry-Go-Round payout alerts
- ✅ Meeting reminders
- ✅ M-Pesa payment confirmations
- ✅ Welfare contribution acknowledgments
- ✅ Low balance warnings

**API Endpoints:**
```
POST /api/v3/sms/send          - Send single/bulk SMS
POST /api/v3/sms/campaign      - Send to contact lists
GET  /api/v3/sms/{uid}         - Get SMS status
GET  /api/v3/sms/              - List all messages
```

**Configuration:**
```dart
// In production, store these securely
SmsService.updateCredentials(
  apiKey: 'your_api_key',
  senderId: 'Mobifund', // Max 11 chars
);
```

---

### 5. M-Pesa Integration (Planned)

**Features:**
- Paybill/Till number integration
- Automatic payment reconciliation
- Transaction notifications
- Balance inquiries

**Flow:**
```
Member → M-Pesa → Paybill → Callback → Mobifund → Record Contribution
```

---

## 📱 User Interface Structure

### Organization Switcher
```
┌─────────────────────────────────────┐
│  Mobifund                    [👤]  │
├─────────────────────────────────────┤
│  Current: Nairobi Chama      [▼]  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🏢 Nairobi Chama           │   │
│  │ 🏢 Mombasa Chama           │   │
│  │ 🏢 Kisumu Chama            │   │
│  │                             │   │
│  │ + Create New Organization  │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Module Selection (Onboarding)
```
┌─────────────────────────────────────┐
│  Choose Modules for Your Chama      │
├─────────────────────────────────────┤
│  ☑️ Base Module                     │
│     Contributions & Expenses        │
│                                     │
│  ☐ Loans Module                     │
│     Soft & Normal loans             │
│                                     │
│  ☐ Merry-Go-Round                   │
│     Rotational savings              │
│                                     │
│  ☐ Shares & Savings                 │
│     Track member stakes             │
│                                     │
│  ☐ Goals & Investment               │
│     Group investment tracking       │
│                                     │
│  ☐ Welfare                          │
│     Member support fund             │
│                                     │
│         [Continue]                  │
└─────────────────────────────────────┘
```

---

## 🗄️ Database Schema

### Organizations Table
```sql
CREATE TABLE organizations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  created_at TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  synced INTEGER DEFAULT 0
);
```

### Org Members Table (RBAC)
```sql
CREATE TABLE org_members (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  role TEXT NOT NULL DEFAULT 'member', -- admin, treasurer, secretary, member
  joined_at TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  synced INTEGER DEFAULT 0,
  FOREIGN KEY (org_id) REFERENCES organizations(id)
);
```

### Org Modules Table
```sql
CREATE TABLE org_modules (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  module_type TEXT NOT NULL, -- base, loans, merry_go_round, shares, goals, welfare
  is_active INTEGER DEFAULT 1,
  config TEXT, -- JSON configuration
  activated_at TEXT NOT NULL,
  synced INTEGER DEFAULT 0,
  FOREIGN KEY (org_id) REFERENCES organizations(id)
);
```

### Enhanced Members/Contributions/Expenses
All include `org_id TEXT NOT NULL` for data isolation.

---

## 🔄 Migration Strategy

### From Current → Multi-Tenant

1. **Backward Compatible:**
   - Existing data assigned to "default" organization
   - Current users become "admin" of default org

2. **Database Migration:**
   ```sql
   -- Add org_id to existing tables
   ALTER TABLE members ADD COLUMN org_id TEXT DEFAULT "default";
   ALTER TABLE contributions ADD COLUMN org_id TEXT DEFAULT "default";
   ALTER TABLE expenses ADD COLUMN org_id TEXT DEFAULT "default";
   
   -- Create new tables
   CREATE TABLE organizations (...);
   CREATE TABLE org_members (...);
   CREATE TABLE org_modules (...);
   ```

3. **UI Updates:**
   - Add organization switcher in app bar
   - Add module settings in settings screen
   - Add role management in members screen

---

## 📊 Implementation Priority

### Phase 1: Core Foundation ✅ (COMPLETED)
- [x] Multi-tenancy models
- [x] RBAC system
- [x] Module activation system
- [x] LocalDB updates
- [x] SMS service integration

### Phase 2: Additional Modules (NEXT)
- [ ] Loans module (Soft & Normal)
- [ ] Merry-Go-Round module
- [ ] Shares & Savings module
- [ ] Goals & Investment module
- [ ] Welfare module

### Phase 3: Integrations
- [ ] M-Pesa API integration
- [ ] SMS notifications for transactions
- [ ] Bulk SMS for member communication

### Phase 4: UI/UX
- [ ] Organization switcher
- [ ] Module settings UI
- [ ] Role management UI
- [ ] Onboarding flow updates

---

## 🔐 Security Considerations

1. **API Keys:**
   - Store in flutter_secure_storage
   - Never hardcode in production

2. **Data Isolation:**
   - All queries filtered by org_id
   - Users can only access their organization's data

3. **Role Enforcement:**
   - Check permissions before sensitive operations
   - Server-side validation (Supabase RLS)

---

## 🚀 Getting Started

### For Developers:
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Current features:
- Base module (Contributions, Expenses, Members)
- Multi-tenancy ready
- SMS service integrated
```

### For Organizations:
1. Download Mobifund
2. Create Organization
3. Select Modules
4. Invite Members
5. Start Managing!

---

## 📞 Support

**Mobiwave Innovations Limited**
- SMS API: https://sms.mobiwave.co.ke
- Documentation: Available in app

---

*Built with ❤️ for Chamas and SACCOs in Kenya*
