## 2026-04-26 - [Interactive Feedback & Accessibility]
**Learning:** Combining haptic feedback with visual ink splash (InkWell) and tooltips significantly improves the perceived quality and accessibility of auth screens. Use `selection()` for toggles and `light()` for links/buttons. Adding `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` to `InkWell` links ensures adequate touch targets.
**Action:** Always replace `GestureDetector` links with `InkWell` + padding, and ensure all icon-only toggles have descriptive `tooltip` and haptic feedback.
