## 2026-04-21 - Interactive Polish for Auth Screens
**Learning:** Icon-only buttons (like password toggles) should always have dynamic tooltips and haptic feedback to provide clear context and tactile confirmation. Interactive text links (like "Sign Up") are better implemented with `InkWell` and generous padding rather than `GestureDetector` to ensure a comfortable touch target and standard ripple feedback.
**Action:** Use `AppHaptics.selection()` for toggles and `AppHaptics.light()` for navigation links. Prefer `InkWell` with `borderRadius` and `Padding` for text-based interactive elements.
