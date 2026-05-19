## 2026-04-10 - [Enhanced Auth Accessibility & Feedback]
**Learning:** Icon-only buttons (like password visibility toggles) lack context for screen readers if tooltips are missing, and interactive text links using `GestureDetector` don't provide the visual or haptic feedback users expect from modern mobile apps.
**Action:** Always add descriptive tooltips and `AppHaptics` to icon-only buttons, and prefer `InkWell` with adequate padding for text-based navigation links.
## 2025-05-15 - [Tactile & Accessible Auth]
**Learning:** Auth screens are the first touchpoint; adding haptics and tooltips to password toggles significantly improves the "feel" and accessibility. Replacing GestureDetector with InkWell for links ensures proper interactive feedback (ripples).
**Action:** Always prefer InkWell with generous padding over GestureDetector for interactive text links. Always include tooltips for icon-only toggles.
## 2024-05-24 - [Micro-UX: Interactive Feedback & Accessibility]
**Learning:** Icon-only buttons (like password visibility toggles) lack context for accessibility without tooltips. Additionally, using `GestureDetector` for navigation links misses out on standard Material feedback (ink ripples) and haptic engagement, which can be easily provided with `InkWell` and `AppHaptics`.
**Action:** Always include tooltips for icon buttons and prefer `InkWell` with adequate padding for text-based navigation links to improve tap targets and visual/haptic feedback.
## 2026-04-26 - [Interactive Feedback & Accessibility]
**Learning:** Combining haptic feedback with visual ink splash (InkWell) and tooltips significantly improves the perceived quality and accessibility of auth screens. Use `selection()` for toggles and `light()` for links/buttons. Adding `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` to `InkWell` links ensures adequate touch targets.
**Action:** Always replace `GestureDetector` links with `InkWell` + padding, and ensure all icon-only toggles have descriptive `tooltip` and haptic feedback.
