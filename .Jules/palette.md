## 2026-04-23 - [Interactive Element Feedback & Accessibility]
**Learning:** Icon-only buttons lacking tooltips and generic `GestureDetector` links without visual feedback (ink ripples) or haptics create a less accessible and less responsive feel.
**Action:** Always use `IconButton` with a descriptive `tooltip` and haptic feedback. Favor `InkWell` over `GestureDetector` for text links to provide visual feedback and larger touch targets.
