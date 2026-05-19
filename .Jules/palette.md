## 2024-04-18 - [Dynamic Accessibility Tooltips for Toggles]
**Learning:** Toggle buttons (like password visibility) should have dynamic tooltips that reflect the current state (e.g., "Show" vs "Hide") to provide accurate context for screen readers and users.
**Action:** When implementing any toggle interaction, ensure the ARIA label or tooltip updates based on the widget's state.
## 2025-05-14 - Interactive Link Accessibility
**Learning:** Using `GestureDetector` for text links misses out on critical visual and accessibility feedback. `InkWell` provides an immediate visual ripple (delight) and, when paired with generous padding, ensures a compliant touch target.
**Action:** Favor `InkWell` over `GestureDetector` for interactive text or links. Apply `borderRadius: BorderRadius.circular(8)` and `EdgeInsets.symmetric(horizontal: 8, vertical: 4)` to ensure the touch area is both visible and accessible.

## 2025-05-14 - Haptic & Tooltip Standards
**Learning:** Icon-only buttons (like password toggles) are accessibility gaps if they lack tooltips. Adding `AppHaptics.selection()` provides tactile confirmation that is especially valuable on mobile.
**Action:** All icon-only buttons must include descriptive tooltips. Integrate `AppHaptics.selection()` in `onPressed` handlers for tactile feedback in Flutter applications.
## 2025-01-24 - [Accessible Links and Feedback]
**Learning:** Using `InkWell` instead of `GestureDetector` for text links provides critical visual feedback (ink splash) that informs users their interaction was registered. Adding `AppHaptics.selection()` to these interactions and descriptive tooltips to icon-only buttons significantly improves accessibility for screen readers and touch users.
**Action:** Always favor `InkWell` for interactive text/links and ensure all icon buttons have context-specific tooltips and haptic feedback.
## 2026-04-14 - [Interactive Link Feedback]
**Learning:** Using `InkWell` instead of `GestureDetector` for text links provides critical visual feedback (material ripple) that helps users confirm their interaction. Adding generous padding (8px horizontal, 4px vertical) significantly improves the touch target for accessibility without bloating the UI.
**Action:** Always prefer `InkWell` with `borderRadius` and `Padding` over `GestureDetector` for navigation links in Flutter.

## 2026-04-14 - [Password Visibility Accessibility]
**Learning:** Icon-only buttons for password visibility need explicit tooltips for screen readers and haptic feedback to feel "mechanical" and responsive.
**Action:** Include `tooltip` and `AppHaptics.selection()` on all visibility toggle buttons.
## 2025-05-14 - [Password Visibility Toggles]
**Learning:** Icon-only buttons (like password visibility toggles) should always include descriptive tooltips and haptic feedback to improve accessibility and user experience.
**Action:** Always add `tooltip` and call `AppHaptics.selection()` on password toggle `IconButton`s.

## 2025-05-14 - [Authentication Links]
**Learning:** Using `GestureDetector` for text-based navigation links often lacks adequate touch targets and visual feedback. `InkWell` with generous padding and haptics provides a much better experience.
**Action:** Use `InkWell` with `EdgeInsets.symmetric(horizontal: 8, vertical: 4)` and `AppHaptics.selection()` for interactive text links.
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
