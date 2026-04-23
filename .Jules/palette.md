## 2025-05-14 - [Password Visibility Toggles]
**Learning:** Icon-only buttons (like password visibility toggles) should always include descriptive tooltips and haptic feedback to improve accessibility and user experience.
**Action:** Always add `tooltip` and call `AppHaptics.selection()` on password toggle `IconButton`s.

## 2025-05-14 - [Authentication Links]
**Learning:** Using `GestureDetector` for text-based navigation links often lacks adequate touch targets and visual feedback. `InkWell` with generous padding and haptics provides a much better experience.
**Action:** Use `InkWell` with `EdgeInsets.symmetric(horizontal: 8, vertical: 4)` and `AppHaptics.selection()` for interactive text links.
