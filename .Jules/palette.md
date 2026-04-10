## 2026-04-10 - [Enhanced Auth Accessibility & Feedback]
**Learning:** Icon-only buttons (like password visibility toggles) lack context for screen readers if tooltips are missing, and interactive text links using `GestureDetector` don't provide the visual or haptic feedback users expect from modern mobile apps.
**Action:** Always add descriptive tooltips and `AppHaptics` to icon-only buttons, and prefer `InkWell` with adequate padding for text-based navigation links.
