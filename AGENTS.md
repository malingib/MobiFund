# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Build & Test Commands
```bash
flutter pub get              # Install dependencies
flutter build apk --release  # Build Android APK
flutter analyze              # Run linter
flutter test                 # Run tests
```

## Project Stack
- **Flutter** (Dart) + **Supabase** (backend) + **SQLite** (local storage)
- **Provider** for state management
- **M-Pesa** and **SMS** integrations (Mobiwave API)

## Non-Obvious Patterns

### Authentication
- Phone auth uses `${normalized_phone}@mobifund.local` format (see [`supabase_service.dart:80`](lib/services/supabase_service.dart:80))
- Login also accepts legacy email formats for backward compatibility

### Data Sync
- **Offline-first**: Data loads from local SQLite first, then syncs to Supabase when online
- All data models include `orgId` for multi-tenancy isolation
- `synced` flag (0/1) tracks sync status in local DB

### Module System
- Modules defined as enum [`ModuleType`](lib/models/models.dart:281) with `code` property for DB storage
- Base module always active; optional: loans, merry_go_round, shares, goals, welfare

### Roles & Permissions
- [`UserRole`](lib/models/models.dart:130) enum: admin, treasurer, secretary, member
- Role stored as `code` string in DB (not numeric)

### Platform Admin Support
- Platform admins can enter "support mode" to temporarily view any organization's data
- Support sessions expire after 30 minutes (configurable)

### Credentials
- Supabase credentials in `.env` file (optional - falls back to hardcoded values in [`supabase_service.dart:22-27`](lib/services/supabase_service.dart:22-27))
- Never commit `.env` to version control (already in .gitignore)

## Code Style
- Uses standard Flutter lints (`package:flutter_lints/flutter.yaml`)
- No custom lints defined in [`analysis_options.yaml`](analysis_options.yaml)
- Model classes use `toMap()`, `fromMap()`, `toSupabase()`, `copyWith()` patterns
