# Palette's Journal

## 2026-04-25 - [Consistent Haptic Feedback & Touch Targets]
**Learning:** For a premium mobile feel, navigation-triggering links should use `AppHaptics.light()` while UI toggles use `AppHaptics.selection()`. Consistent padding (e.g., 12x8) on `InkWell` links ensures adequate touch targets for accessibility.
**Action:** Always apply `AppHaptics.selection()` to icon-only toggles and ensure `InkWell` links have generous, consistent padding.
