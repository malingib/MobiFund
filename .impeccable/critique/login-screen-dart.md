# Critique: login_screen.dart

**Date:** 2026-06-06
**Target:** `lib/screens/login_screen.dart` (838 lines: 1 main screen + password reset dialog)
**Register:** product
**Slug:** `login-screen-dart`
**Score:** 26/40 — Acceptable

## Design Health Score

| # | Heuristic | Score |
|---|---|---|
| 1 | Visibility of System Status | 3 |
| 2 | Match System / Real World | 3 |
| 3 | User Control and Freedom | 3 |
| 4 | Consistency and Standards | 2 |
| 5 | Error Prevention | 3 |
| 6 | Recognition Rather Than Recall | 3 |
| 7 | Flexibility and Efficiency of Use | 2 |
| 8 | Aesthetic and Minimalist Design | 2 |
| 9 | Help Users Recognize, Diagnose, and Recover from Errors | 3 |
| 10 | Help and Documentation | 2 |
| **Total** | | **26/40** |

## Anti-Patterns Verdict

**Pass with reservations.** No purple gradient, no glassmorphism, no identical card grids, no hero-metric template. The Mobifund teal + warm brass palette is committed and the typography uses the system family. Tells:
- ⚠️ Marketing copy on a task surface (the hero chips and mini-metrics push the form below the fold on small phones)
- ⚠️ Hero card has no `Semantics(header: true)` — TalkBack reads 7 unrelated fragments

## Priority Issues

- **[P0]** "Reset Password" final step doesn't actually reset — `login_screen.dart:675-710`. The user types a new password and is told to contact support. Trust failure. Fix: implement the reset, or shorten the flow to a 1-step contact-support dialog.
- **[P1]** Marketing content dominates the task surface — `login_screen.dart:152-280`. The hero card is ~480px on a 720px Android viewport; the form is below the fold. Fix: compress the hero to a single horizontal row (logo + name + tagline, ~80px), or move marketing to a `/welcome` route.
- **[P1]** No `prefers-reduced-motion` support on the page transition. WCAG 2.3.3. Fix: in `_AppPageTransitionsBuilder.buildTransitions`, check `MediaQuery.of(context).disableAnimations` and return `child` directly if true.
- **[P2]** Reset dialog's `barrierDismissible: false` — `login_screen.dart:85`. The user cannot abandon the OTP step if SMS doesn't arrive. Fix: keep non-dismissible only during OTP entry; allow dismissal on the phone step.
- **[P2]** Reset dialog uses bare `TextField` instead of `TextFormField` — `login_screen.dart:737, 752, 768, 778`. Inconsistent with main form's validation style. Fix: convert to `TextFormField` with shared `AppFormError` widget.

## Persona Red Flags

- **Wanjiku (Member, primary)**: "The form needs to be the first thing I see" — the hero pushes the form below the fold on small Android phones.
- **Kamau (Treasurer)**: "I tap 'Forgot Password', enter my phone, get the OTP, type a new password, and the app says 'Contact support.' I uninstall." — the P0 trust bug.
- **Sam (Screen reader)**: The hero card has no `Semantics(header: true, label: ...)`; TalkBack reads 7 unrelated fragments. Add a wrapper.
- **Riley (Stress tester)**: The password validator runs `isEmpty` before `length < 6`. A user who types a 5-char password then clears it sees "Password is required" instead of the more specific length error. Run all checks, report the most specific.

## Minor Observations

- Password field has no `AutofillHints.password` — password managers won't offer to save.
- "Sign Up" `InkWell` uses `BorderRadius.circular(8)` — off-scale (8 isn't `radiusSm` which is 14). The recent token sweep missed it.
- Hero chips use hard-coded `BorderRadius.circular(999)` — should be `AppTheme.radiusPill` constant.
- "Sign Up" `InkWell` has no `Semantics(button: true)` or `link: true`.
- `_MiniMetric` uses `fontSize: 11` — same Material 12sp floor issue flagged in the dashboard audit.
- The screen does not handle "user is already authenticated" — an authenticated user landing on `/login` sees the form instead of being routed to `/home`.

## Questions to Consider

- What if the login form were the entire screen? Strip the hero to a wordmark + tagline at the top.
- What if the "Reset Password" final step were honest from the start? A 1-step "Contact support" dialog is 10× faster than a 3-step flow that goes nowhere.
- What if the "Sign Up" link were part of the form's footer, not a separate row below?
- What would the "first phone, no email, no password manager" user see? They hit "Sign In" with a phone number they never registered, get "Incorrect email or password", and the "Sign Up" link is 100px below. Stuck.
