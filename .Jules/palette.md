## 2024-05-24 - [Micro-UX: Interactive Feedback & Accessibility]
**Learning:** Icon-only buttons (like password visibility toggles) lack context for accessibility without tooltips. Additionally, using `GestureDetector` for navigation links misses out on standard Material feedback (ink ripples) and haptic engagement, which can be easily provided with `InkWell` and `AppHaptics`.
**Action:** Always include tooltips for icon buttons and prefer `InkWell` with adequate padding for text-based navigation links to improve tap targets and visual/haptic feedback.
