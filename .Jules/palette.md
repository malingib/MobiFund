## 2026-04-20 - [Accessibility & Feedback for Icon-Only Buttons]
**Learning:** Icon-only buttons (like password visibility toggles and refresh buttons) lack inherent semantic meaning for screen readers and tactile feedback for mobile users. Dynamic tooltips ("Show password" vs "Hide password") and haptic feedback significantly improve the accessibility and perceived quality of the app.
**Action:** Always provide dynamic `tooltip` properties to `IconButton` and include `AppHaptics.selection()` or `AppHaptics.light()` in `onPressed` or `onTap` handlers for interactive elements.
