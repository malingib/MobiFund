# Baseline Profile — Follow-up

## Status: NOT IMPLEMENTED (multi-day, requires physical device)

## Why it matters

A baseline profile tells the AOT compiler which Dart methods are "hot" on
cold start. Without one, the runtime has to JIT-compile these methods on
first launch → visible jank + slower startup. With a profile baked into
the APK, those methods ship pre-compiled.

**Expected impact:** 30–50% reduction in startup time and frame jank.
This is the single biggest perf win available without a code rewrite.

## What it requires

1. A **physical Android device** (ARM64 preferred). Emulator is too
   noisy — timings are unreliable for profile collection.
2. `profile_collector` dev dep + a small `lib/main_profile_collector.dart`
   that walks the actual user flows.
3. Run on device in profile mode, collect traces, convert to a
   baseline profile, ship as `assets/baseline_profile.json`.
4. Rebuild APK. Done.

## How to implement

```yaml
# pubspec.yaml dev_dependencies
dev_dependencies:
  profile_collector: ^0.4.0
```

```dart
// lib/main_profile_collector.dart  — separate entry point
import 'package:profile_collector/profile_collector.dart';
// walk: splash → welcome → login → register → dashboard tab switch
//        → members list → contributions add → reports
// record each step with ProfileCollector.sample(...)
```

Build & collect:
```bash
flutter build apk --profile --target=lib/main_profile_collector.dart
flutter run --profile --target=lib/main/main_profile_collector.dart \
  --observe-profile-startup=false
# In DevTools → Performance → Record profile
# Export → save as android/app/src/main/baseline-profile.txt
# Convert: dart run --package-dir=... -- lib/main.dart -> .json
```

Then in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/baseline_profile.json
```

## Hot paths to profile in Mobifund

1. `BootstrapApp` → first frame of `SplashScreen`
2. `WelcomeScreen` first render
3. `LoginScreen` form mount
4. `MainShell` → `EnhancedDashboardScreen` first render
5. Bottom-nav tab switch (`MembersScreen`, `ModulesHubScreen`, `ReportCenterScreen`)
6. `Quick Actions` sheet open
7. Notification panel open

## Reference

- https://docs.flutter.dev/perf/baseline-profile
- https://github.com/flutter/samples/tree/main/baseline_profile
