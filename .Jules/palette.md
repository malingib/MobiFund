## 2025-05-14 - [Interactive Link Feedback & Accessibility]
**Learning:** In Flutter, `GestureDetector` on text provides no visual feedback for touch, making the interface feel unresponsive. Using `InkWell` with a `BorderRadius` and `Padding` provides both a ripple effect and a larger touch target.
**Action:** Favor `InkWell` over `GestureDetector` for links. Use a standard `BorderRadius.circular(8)` and `EdgeInsets.symmetric(horizontal: 8, vertical: 4)` for a consistent, accessible experience.

## 2025-05-14 - [Icon-Only Button Context]
**Learning:** Icon-only buttons (like password visibility toggles) are inaccessible to screen readers without a `tooltip`. Dynamic tooltips that change state (e.g., "Show password" vs "Hide password") provide essential context.
**Action:** Always provide specific, dynamic tooltips for icon-only buttons. Combine with `AppHaptics.selection()` for tactile reinforcement.
