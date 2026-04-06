# Project Debug Rules (Non-Obvious Only)

- App uses Provider state management: check `AppState` in [`lib/services/app_state.dart`](lib/services/app_state.dart) for all state
- Offline-first: app works without network but syncs when online - check `_isOnline` and `_isSyncing` flags
- Supabase credentials fallback to hardcoded values if `.env` missing - check [`supabase_service.dart:22-27`](lib/services/supabase_service.dart:22-27)
- Phone auth uses `${normalized_phone}@mobifund.local` - check [`supabase_service.dart:80`](lib/services/supabase_service.dart:80) for auth flow
- Use `debugPrint()` for logging (standard Flutter debugging)
- Check `.env` file exists in project root for Supabase config
- Support mode allows platform admins to view any org temporarily - see [`app_state.dart:187-208`](lib/services/app_state.dart:187-208)
