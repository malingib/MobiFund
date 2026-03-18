# Chama Tracker — Build Guide
## Get Your APK in ~15 Minutes (No local Flutter needed)

---

## STEP 1 — Set Up Supabase (5 min)

1. Go to **https://supabase.com** → Sign in → Open your project
2. Click **SQL Editor** in the left sidebar
3. Paste the entire contents of `supabase_schema.sql` and click **Run**
4. Go to **Settings → API** and copy:
   - **Project URL** (looks like `https://xxxxxxxxxxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

---

## STEP 2 — Add Your Credentials to the App

Open `lib/main.dart` and replace lines 15–16:

```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';       // ← paste here
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // ← paste here
```

Example:
```dart
const String supabaseUrl = 'https://abcdefgh.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## STEP 3 — Build the APK on FlutLab (Free, No install needed)

### 3a. Create a ZIP of the project
Zip the entire `chama_tracker` folder. The ZIP should contain:
```
chama_tracker/
  lib/
  android/
  pubspec.yaml
  supabase_schema.sql
  ...
```

### 3b. Upload to FlutLab
1. Go to **https://flutlab.io** → Sign up free
2. Click **New Project** → **Import from ZIP**
3. Upload your `chama_tracker.zip`
4. Wait for it to process (~1 min)
5. Click **Build** → **Android APK (Release)**
6. Wait 3–5 minutes for the build
7. Download your `.apk` file

---

## STEP 4 — Install the APK on Your Android Phone

1. **Send the APK to your phone** (WhatsApp, email, Google Drive, USB cable)
2. Open it on your phone
3. Android will ask: *"Allow install from unknown sources"* → tap **Settings** → enable it → go back and install
4. App opens — you're done! 🎉

---

## Alternative: Build with Codemagic (also free)

1. Push the project to **GitHub** (free private repo)
2. Go to **https://codemagic.io** → Connect GitHub
3. Select the repo → **Flutter App** workflow
4. Build → Download APK from artifacts

---

## Alternative: Build Locally (Fastest if you have Flutter)

```bash
# Install Flutter: https://docs.flutter.dev/get-started/install
flutter pub get
flutter build apk --release
# APK is at: build/app/outputs/flutter-apk/app-release.apk
```

---

## App Features

| Feature | Description |
|---------|-------------|
| **Offline-first** | All data saved locally on device (SQLite) |
| **Auto-sync** | Syncs to Supabase automatically when online |
| **Manual sync** | Tap the sync icon in the top-right corner |
| **Members** | Add/remove members with name, phone, notes |
| **Contributions** | Record per-member contributions with date & note |
| **Expenses** | Track expenses by type (preset + custom types) |
| **Dashboard** | Net balance, member contribution bars, activity feed |
| **Filter** | Filter contributions by member, expenses by type |

---

## File Structure

```
lib/
  main.dart                    ← Entry point + Supabase init + navigation
  theme/
    app_theme.dart             ← Dark gold theme (matches HTML design)
  models/
    models.dart                ← Member, Contribution, Expense classes
  services/
    local_db.dart              ← SQLite local storage
    sync_service.dart          ← Supabase push/pull sync
    app_state.dart             ← State management (Provider)
  screens/

    members_screen.dart        ← Add/view/remove members
    contributions_screen.dart  ← Record + filter contributions
    expenses_screen.dart       ← Record + filter expenses
  widgets/
    shared_widgets.dart        ← Reusable UI components
```

---

## Troubleshooting

**Build fails on FlutLab?**
- Make sure `pubspec.yaml` is at the root of the ZIP, not nested
- Confirm Flutter SDK version is set to 3.24+ in FlutLab settings

**Supabase sync not working?**
- Double-check URL and anon key in `main.dart`
- Make sure the SQL schema was run successfully
- Check that RLS policies were created (the SQL includes them)

**"Install blocked" on Android?**
- Go to Settings → Security → Install unknown apps → enable for your file manager or browser

---

*Built with Flutter 3.24 · Supabase · SQLite · Provider*
