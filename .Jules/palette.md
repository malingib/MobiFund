## 2026-04-24 - [Icon Button Accessibility & Haptics]
**Learning:** Icon-only buttons in the application often lack tooltips and consistent haptic feedback. This makes the interface less accessible for screen reader users and less satisfying for those who value tactile response. Specifically, toggles like password visibility should provide dynamic tooltips to reflect their current state.
**Action:** Always include a descriptive, dynamic `tooltip` and call `AppHaptics.selection()` for `IconButton` toggles and state changes. Ensure all `IconButton`s have at least a static `tooltip`.
