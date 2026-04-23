## 2025-01-24 - [Accessible Links and Feedback]
**Learning:** Using `InkWell` instead of `GestureDetector` for text links provides critical visual feedback (ink splash) that informs users their interaction was registered. Adding `AppHaptics.selection()` to these interactions and descriptive tooltips to icon-only buttons significantly improves accessibility for screen readers and touch users.
**Action:** Always favor `InkWell` for interactive text/links and ensure all icon buttons have context-specific tooltips and haptic feedback.
