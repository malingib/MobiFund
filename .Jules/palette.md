## 2025-05-15 - [Tactile & Accessible Auth]
**Learning:** Auth screens are the first touchpoint; adding haptics and tooltips to password toggles significantly improves the "feel" and accessibility. Replacing GestureDetector with InkWell for links ensures proper interactive feedback (ripples).
**Action:** Always prefer InkWell with generous padding over GestureDetector for interactive text links. Always include tooltips for icon-only toggles.
