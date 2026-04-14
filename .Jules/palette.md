## 2026-04-14 - [Interactive Link Feedback]
**Learning:** Using `InkWell` instead of `GestureDetector` for text links provides critical visual feedback (material ripple) that helps users confirm their interaction. Adding generous padding (8px horizontal, 4px vertical) significantly improves the touch target for accessibility without bloating the UI.
**Action:** Always prefer `InkWell` with `borderRadius` and `Padding` over `GestureDetector` for navigation links in Flutter.

## 2026-04-14 - [Password Visibility Accessibility]
**Learning:** Icon-only buttons for password visibility need explicit tooltips for screen readers and haptic feedback to feel "mechanical" and responsive.
**Action:** Include `tooltip` and `AppHaptics.selection()` on all visibility toggle buttons.
