---
name: MobiFund
description: A calm, trust-first workspace for East-African chama savings groups.
colors:
  primary: "#0D7168"
  primary-deep: "#094943"
  primary-light: "#38B2A3"
  accent: "#D9AE4A"
  accent-mint: "#8AD7AE"
  surface: "#F4F7F3"
  surface-elevated: "#FCFDFB"
  surface-card: "#FFFFFF"
  surface-border: "#D9E4DD"
  brand-ink: "#102A26"
  text-primary: "#17312D"
  text-secondary: "#5A6964"
  text-muted: "#8A9792"
  success: "#169A6A"
  danger: "#E25555"
  warning: "#E3A61B"
  info: "#2F80ED"
  dark-card: "#12302B"
typography:
  display:
    fontFamily: "system-ui, -apple-system, Roboto, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.6px"
  headline:
    fontFamily: "system-ui, -apple-system, Roboto, sans-serif"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.15px"
  title:
    fontFamily: "system-ui, -apple-system, Roboto, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "system-ui, -apple-system, Roboto, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
  caption:
    fontFamily: "system-ui, -apple-system, Roboto, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    letterSpacing: "0.3px"
rounded:
  sm: "14px"
  md: "18px"
  lg: "24px"
  xl: "28px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xxl: "32px"
  xxxl: "48px"
  xxxxl: "64px"
  pagePadding: "20px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: "14px 24px"
    height: "48px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "10px 16px"
  fab-extended:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.lg}"
    padding: "16px 20px"
  card-surface:
    backgroundColor: "{colors.surface-elevated}"
    rounded: "{rounded.lg}"
    border: "1px solid {colors.surface-border}"
    padding: "16px 20px"
  input-filled:
    backgroundColor: "{colors.surface-elevated}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: "14px 16px"
  alert-dialog:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.lg}"
    padding: "20px 24px"
  status-chip:
    backgroundColor: "{colors.success}1A"
    textColor: "{colors.success}"
    rounded: "{rounded.pill}"
    padding: "4px 10px"
  hero-card:
    backgroundColor: "linear-gradient(135deg, {colors.primary}, {colors.primary-deep})"
    textColor: "#FFFFFF"
    rounded: "{rounded.xl}"
    padding: "20px 22px"
---

# Design System: MobiFund

## 1. Overview

**Creative North Star: "The senior accountant's notebook."**

Clean ruled pages, calm authority, the trust of a ledger that has been right for twenty years. Every pixel in MobiFund is asked the same question a senior accountant would ask an entry: *is this earning its line on the page?* If the answer is no, the entry is cut. The interface is dense where density serves accuracy (the ledger, the reconciliation table) and spacious where space serves focus (the dashboard's primary balance, the empty states).

The system explicitly rejects the **template-y SaaS dashboard** — the AI-generated reflex of purple gradients, hero-metric templates, identical card grids, and the uppercased eyebrow kicker that now appears on 55-95% of AI-generated marketing surfaces regardless of brief. The Mobifund teal-and-warm-brass palette is a deliberate counter to that reflex: deep forest teal as the dominant surface, warm brass as the earned accent, soft mint for life, and a near-paper neutral for content. There is no second accent, no tertiary, no purple-to-blue gradient. The visual identity is the restraint, not the palette.

**Key Characteristics:**
- **One family throughout.** System sans (Roboto on Android, San Francisco on iOS) carries display, headlines, body, labels, and data. No display font, no mono for content. The product reads as one instrument, not a collection of typefaces.
- **Calm, not clever.** No playful motion, no celebratory microcopy, no confetti. A 60ms stagger on the dashboard's three quick-stat tiles is the loudest motion in the app. Money is serious.
- **The balance is the answer.** The dashboard's primary job is to answer "what is the group at right now?" in under three seconds. Everything else (analytics, reports, modules) is downstream.
- **Real data, real names, real currency.** No placeholder copy anywhere. The dashboard's "Recent Activity" feeds the actual ledger. Member names, not "John Doe".
- **One source of truth per concept.** The same stat (balance, growth, top contributor) renders the same way everywhere. No duplicate counters, no conflicting values across screens.

## 2. Colors

The palette is grounded in two colors — deep forest teal and warm brass — and a near-paper neutral. Accents (warm brass, soft mint) are earned through use, never decoration.

### Primary
- **Deep Forest Teal** (`#0D7168`): The dominant brand color. Used for primary CTAs, top-level navigation, brand surfaces, and the gradient hero on the dashboard. Calmer than the AI-default teals; reads as institutional, not playful.
- **Forest Deep** (`#094943`): The dark stop of the primary gradient. Used as the lower bound of `heroGradient` and the header bar in dark mode. Not a standalone surface color.
- **Lichen** (`#38B2A3`): The light stop of the primary family. Used in dark mode as the active-state color, and as a 10–20% tint behind teal-accented icon tiles. Never as text on white (insufficient contrast).

### Secondary
- **Warm Brass** (`#D9AE4A`): The earned accent. Used for status indicators, premium-feature flags, the merry-go-round accent, and moments of celebration. Never as a default CTA. **Rarity is the point.**
- **Soft Mint** (`#8AD7AE`): The success-adjacent. Used in 16%-tint chips on the hero for "Online" status, and as the data-viz secondary color. Not a standalone surface color.

### Tertiary
- *(None by design.)* Three colors is the upper limit. Adding a third named role dilutes the trust signal.

### Neutral
- **Paper** (`#F4F7F3`): The body background. A near-white with the faintest teal tint (chroma ≈ 0.01 toward 165°). Distinctly not a flat white. Reads as paper, not as a screen.
- **Linen** (`#FCFDFB`): The elevated surface for cards and list items. One step up from Paper, used wherever content needs to read as "above the page".
- **Bone** (`#EAF2EC`): The sunken surface. Used for filled input fields, the "AppSpacing" zero-state bg, and FABs against elevated surfaces.
- **Edge** (`#D9E4DD`): The border. Used at 70-80% opacity for card edges, dividers, and input borders. The default border is *not* pure grey; it carries the brand's hue.
- **Ink** (`#17312D`): The primary text. A near-black with a teal undertone. Not pure black; not grey.
- **Ash** (`#5A6964`): The secondary text. Used for descriptions, sub-labels, supporting copy. ≥ 4.5:1 on Paper.
- **Mist** (`#8A9792`): The muted text. Used for placeholders, tertiary metadata, empty-state icons. ≥ 4.5:1 on Paper.

### Named Rules
- **The Brass Is Earned Rule.** Warm Brass appears on ≤ 10% of any given screen. Its rarity is the point. If brass appears on a button label, the rest of the page must not.
- **The Never-Purple Rule.** No purple. No blue-purple. No gradient between teal and purple. The teal is the teal; the brass is the brass; nothing in between.
- **The Edge Is Not Grey Rule.** All borders are `Edge` (`#D9E4DD`) tinted with a 0.005-0.015 chroma shift toward teal. Pure grey borders are a tell of unbranded template UI.

## 3. Typography

**Display Font:** System sans (Roboto on Android, San Francisco on iOS)
**Body Font:** System sans (same family)
**Label/Mono Font:** System sans (same family)

**Character:** One family throughout. Weight contrast does the work that a display/body pairing would otherwise do. The system reads as one instrument, calibrated in five weights (regular / medium / semibold / bold / extrabold) rather than three competing typefaces. This is product-UI orthodoxy: the tool should disappear into the task.

### Hierarchy
- **Display** (700, 32-34px, line-height 1.1, letter-spacing -0.6px): Hero numbers — the dashboard balance, the contribution amount on a confirmation. One per screen.
- **Headline** (600-800, 18-22px, line-height 1.25, letter-spacing -0.15px): Card titles, section headers, the org name in the hero. The structural top of any container.
- **Title** (700, 14-15px, line-height 1.3): Tile labels, action-tile titles, button text. The dominant weight in lists.
- **Body** (400, 13-14px, line-height 1.4-1.5): Descriptions, member names in lists, supporting copy. Never below 13px (a11y floor for body on Android).
- **Caption** (500-600, 10-12px, letter-spacing 0.3-0.5px): Status badges, timestamps, "Live" pills, the "Online/Offline" chip. May be uppercase; never full sentences in uppercase.

### Named Rules
- **The One-Family Rule.** Display, headline, title, body, caption, and label are all system sans. Adding a display font is a tell of marketing-style thinking in a product surface.
- **The No-All-Caps-Body Rule.** All-caps is reserved for short labels (≤ 4 words), status badges, and the "LIVE"/"OFFLINE" pill. Never for sentences.
- **The Line-Length Rule.** Prose blocks (login screen body copy, About / Terms screens) cap at 65-75ch. Data and compact UI can run denser; tables at 120ch+ are fine.

## 4. Elevation

MobiFund uses a hybrid elevation model: tonal layering as the default (Paper → Linen → Bone) and low-alpha shadows as the response to state (hover, focus, raised card on scroll). Shadows are never the primary affordance for "this is a card" — that's the job of the border + surface color. Shadows earn their place when a surface needs to feel physically above its container (the hero card on the dashboard, the FAB).

### Shadow Vocabulary
- **Card Ambient** (`box-shadow: 0 8px 18px rgba(13, 113, 104, 0.05)`): The default on cards above the body. Almost imperceptible — it lifts the card off Paper without making it look lifted.
- **Card Lifted** (`box-shadow: 0 10px 18px rgba(13, 113, 104, 0.06)`): The card on hover or when it's the focal element. Slightly stronger ambient; still calm.
- **Hero Glow** (`box-shadow: 0 14px 28px rgba(13, 113, 104, 0.16)`): The dashboard's hero header and balance card. A deeper drop in the brand's own hue. This is the only shadow in the system that uses the primary color, and only the hero gets it.
- **Focus Ring** (`outline: 2px solid {colors.primary}`): Keyboard focus, never mouse focus. Always a ring around the focusable element, never a glow.

### Named Rules
- **The Flat-By-Default Rule.** Surfaces are flat at rest. Shadows appear only as a response to state (hover, raised, focus). If a card looks "lifted" at rest, the shadow is too strong.
- **The Brand-Colored-Shadow Rule.** The only shadow that carries a colored tint is the hero glow, and it is the brand's teal at 16% alpha. Every other shadow is brand-ink at ≤ 6% alpha.
- **The No-Drop-Shadow Rule.** No large blur with high offset and low alpha. That is the 2014 SaaS drop shadow. If it looks like a 2014 app, the shadow is too dark and the blur is too small.

## 5. Components

### Buttons
- **Shape:** Rounded corners (`radiusMd`, 18px). Same radius on every variant.
- **Primary:** `Deep Forest Teal` background, white text, 14px vertical / 24px horizontal padding, semibold weight, 0.3px letter-spacing. The loudest thing on the screen; one per surface area. Min height 48px (a11y).
- **Secondary:** Transparent bg, Deep Forest Teal text, 1px `Edge` border. Used for "Cancel" and other non-destructive paired actions.
- **Danger:** The same shape and padding as Primary, but with `danger` red. Used for destructive actions (delete member, sign out). Always paired with a confirmation.
- **Ghost / Text:** Transparent bg, Deep Forest Teal text, no border. Used inline next to other text (the "Add Members" snackbar action, the "Reports →" section header).
- **FAB Extended:** `Deep Forest Teal` rounded (`radiusLg`, 24px), white text, icon + label. The primary add action per screen. Always labeled.
- **State coverage:** Default, hover, focus, active, disabled, loading (spinner inside button). The disabled state reduces opacity to 60% and removes shadow.

### Chips
- **Status chip:** Pill (`pill`, 999px), 10% tint of semantic color, semantic-color text, 1px border at 30% semantic color. Used for "PAID", "OVERDUE", "PENDING", "ONLINE", "LIVE".
- **Filter chip:** Pill, transparent bg, `text-secondary` text, 1px `Edge` border. Active state: 10% primary tint bg, primary text.
- **Hero status chip (dashboard only):** Pill on the hero's teal background. 10% white tint bg, 92% white text. Used for "X members", "+23% growth", "ADMIN".

### Cards / Containers
- **Corner Style:** `radiusLg` (24px) on dashboard cards and list cards. `radiusMd` (18px) on smaller tiles. `radiusXl` (28px) on the hero only.
- **Background:** `Linen` (`surface-elevated`, `#FCFDFB`) on cards. `Paper` is the body; cards always sit one step above.
- **Shadow Strategy:** Card Ambient on default; Card Lifted on hover. No card has a stronger shadow than Card Lifted, except the hero (Hero Glow).
- **Border:** 1px `Edge` at 72-82% alpha. The border is structural, not decorative.
- **Internal Padding:** 16-20px on standard cards. 22-24px on the hero. 12-16px on tight tiles.

### Inputs / Fields
- **Style:** Filled, 1px no-stroke (the fill IS the boundary), `Bone` fill on `Linen` surface. `radiusMd` (18px). 14-15px vertical / 16px horizontal padding.
- **Focus:** 1.4px `Deep Forest Teal` border on focus. No glow. No scale. The cursor and the focus ring are the only feedback.
- **Error / Disabled:** Error: 1.4px `danger` border + helper text below. Disabled: 60% opacity, no shadow, `Bone` fill.
- **Label:** Caption-weight text *above* the field, not floating. Predictable position, predictable focus order for screen readers.

### Navigation
- **Bottom nav:** Fixed at 4 destinations. `Linen` background, primary color on selected icon, `Mist` on unselected. No labels in the icon-only mode; the 4 destinations are short enough to read as icons.
- **Top app bar:** `Paper` background, `text-primary` title, 20px semibold. No shadow. CenterTitle: false (titles are left-aligned and read as section headers).
- **Side nav (platform shell only):** `dark-card` surface, white text, 12% white-tint active item. Used only on the platform-admin role; never appears on member surfaces.

### State widgets
- **AppEmptyState:** 80px icon tile in a 10% tint of an accent color, 24px headline, optional 14px body, optional CTA. Centered. Wrapped in a single `Semantics` block so TalkBack reads it as one coherent announcement.
- **AppErrorState:** Same shape as AppEmptyState, tinted with `danger`, default copy "Something went wrong. We couldn't load this. Check your connection and try again." Retry CTA uses `AppHaptics.medium()` on press.
- **AppOfflineState:** Same shape, tinted with `text-secondary`, copy "You're offline. Showing your last saved data. Reconnect to sync this group." Outlined retry CTA.
- **Loading skeletons:** `shimmer` effect on `Edge` at 50% alpha → `Bone` at 50% alpha. Used at the dashboard level (full `DashboardSkeleton`) and at the list level (`ListSkeleton`). Never spinners in the middle of content.

## 6. Do's and Don'ts

PRODUCT.md names these explicitly. The visual system enforces them.

### Do
- **Do** answer "what is the group at right now?" within three seconds of opening the dashboard. The balance card is the first focusable element after the FAB.
- **Do** use real member names, real currency, real dates. No "John Doe", no "$1,234", no "Lorem ipsum".
- **Do** render the same stat the same way everywhere. The balance is always the same shape, the same font, the same color, in the same hierarchy position. If it appears on two screens, it looks identical.
- **Do** use skeletons for loading, not spinners in the middle of content.
- **Do** use a real, focused empty state on every list. "No contributions yet — record your first one to start tracking." (Linear/Stripe tone, not apologetic.)
- **Do** include the offline state explicitly. Every screen should render a meaningful state when offline; the network is an enhancement, not a requirement.
- **Do** read currency as "KES 1,234" (group separator, no decimal). Always respect locale, never show raw double precision.

### Don't
- **Don't** use the template-y SaaS dashboard. No purple gradients. No hero-metric template. No identical card grids. No "01 / 02 / 03" eyebrows on every section. This is the primary anti-reference named in PRODUCT.md.
- **Don't** use a display font. System sans throughout. Adding a display font is a tell of marketing-style thinking in a product surface.
- **Don't** use all-caps for body copy. Reserved for short labels and status badges only.
- **Don't** animate layout properties (height, width, padding) for state changes. Animate `opacity`, `transform`, and a small set of properties that the GPU can composite cheaply. Use the motion tokens: `AppDuration.micro` (120ms), `fast` (200ms), `base` (280ms), `slow` (420ms).
- **Don't** use side-stripe colored borders (border-left > 1px) on cards, list items, callouts, or alerts. Rewrite with full borders, background tints, leading numbers/icons, or nothing.
- **Don't** use gradient text. `background-clip: text` combined with a gradient background is decorative, never meaningful. Use a single solid color.
- **Don't** use glassmorphism as a default. Blurs and glass cards are rare and purposeful, or nothing.
- **Don't** use Warm Brass on more than 10% of any screen. Brass is earned, not decorative.
- **Don't** use Stripe / Linear / Notion / Revolut visual grammar. Cold, "tech bro" SaaS. The user is a community treasurer, not a startup CFO.
- **Don't** gate content visibility on a class-triggered transition. The reveal animation must enhance an already-visible default. If the animation doesn't fire, the page must still work.
- **Don't** ship without reduced-motion support. Every animation needs a `prefers-reduced-motion: reduce` alternative. Default: instant transition.
- **Don't** rely on color alone for status. Success/danger must use shape + text + color, never color alone.
