## 2025-05-15 - [Haptic Feedback & Accessibility]
**Learning:** Icon-only buttons (e.g., password visibility toggles, refresh buttons) should always include descriptive tooltips for screen readers and provide haptic feedback to confirm the interaction.
**Action:** Use `AppHaptics.selection()` for lightweight feedback on selections and toggles, and ensure every `IconButton` has a `tooltip` property set.
