## 2025-05-14 - Interactive Link Accessibility
**Learning:** Using `GestureDetector` for text links misses out on critical visual and accessibility feedback. `InkWell` provides an immediate visual ripple (delight) and, when paired with generous padding, ensures a compliant touch target.
**Action:** Favor `InkWell` over `GestureDetector` for interactive text or links. Apply `borderRadius: BorderRadius.circular(8)` and `EdgeInsets.symmetric(horizontal: 8, vertical: 4)` to ensure the touch area is both visible and accessible.

## 2025-05-14 - Haptic & Tooltip Standards
**Learning:** Icon-only buttons (like password toggles) are accessibility gaps if they lack tooltips. Adding `AppHaptics.selection()` provides tactile confirmation that is especially valuable on mobile.
**Action:** All icon-only buttons must include descriptive tooltips. Integrate `AppHaptics.selection()` in `onPressed` handlers for tactile feedback in Flutter applications.
