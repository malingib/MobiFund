# Product

## Register

product

## Users

Three concentric user roles, member-first:

- **Members (primary)**: individual savers in a chama or merry-go-round. Most numerous. They open the app to record their own contribution, see their balance, and check the cycle they're in. They are often passing one phone between several group members in a single sitting.
- **Treasurers (chama admins)**: the group's accountable officer. They approve loans, reconcile M-Pesa deposits against the group ledger, record expenses, and call meetings. They need a calm, trust-first workspace — money is serious.
- **Platform owners**: SaaS operators. They manage organizations, billing tiers, module activation, and platform-wide M-Pesa reconciliation across many chamas. The super_admin_mpesa and modules_hub surfaces serve this role.

All three share an East-African / Kenyan chama context: SMS-first, low-bandwidth, intermittent connectivity, and M-Pesa as the dominant payment rail.

## Product Purpose

MobiFund is a group-finance workspace for chama and savings-circle communities. It replaces paper ledgers and ad-hoc WhatsApp tallies with a single source of truth for contributions, loans, expenses, welfare, shares, merry-go-round cycles, and savings goals.

Success looks like a treasurer closing a month knowing that every shilling is reconciled, and a member opening the app to see their balance, contribution history, and the next merry-go-round payout — without having to ask anyone.

## Brand Personality

- **Voice**: Calm, descriptive, not apologetic. Linear/Stripe tone — never salesy.
- **Personality in three words**: trustworthy, focused, human.
- **Energy**: Quiet competence. The product should feel like a senior accountant's notebook, not a marketing brochure.

## Anti-references

- Generic AI dashboards (purple gradients, hero-metric templates, identical card grids, eyebrow kickers on every section). The Mobifund teal `#0D7168` + warm gold `#D9AE4A` palette is a deliberate counter to that reflex.
- Stripe / Linear / Notion / Revolut visual grammar. Cold, "tech bro" SaaS. The user is a community treasurer, not a startup CFO.
- Saturated consumer-app look (Cash App yellow, etc.). Money is serious; playfulness erodes trust.
- "World-class / seamless / empower / streamline" copy. Mobifund says specifically what it does.

## Design Principles

1. **Members first, treasurers second, platform owners third.** The default surface, default copy, and default density are tuned for a member opening the app on a small Android phone over a 3G connection. Treasurer surfaces add power; platform surfaces add scale — they never displace the member experience.
2. **The balance is the answer.** The dashboard's primary job is to answer "what's the group at right now?" in under three seconds. Everything else (analytics, reports, modules) is downstream.
3. **Calm, not clever.** No playful motion, no decorative gradients, no celebratory microcopy. Money is serious; the interface should not perform.
4. **Show, don't tell.** Real data, real currency, real dates, real member names. No placeholder copy. The dashboard's "Recent Activity" feeds the actual ledger.
5. **One source of truth per concept.** The same stat (e.g. balance, growth %, top contributor) renders the same way everywhere. No duplicate counters, no conflicting values across screens.

## Accessibility & Inclusion

- **Offline-first**: every screen must render a meaningful state when offline. The ledger is local SQLite; the network is an enhancement, not a requirement. New `AppOfflineState` widget is the canonical pattern.
- **Low-bandwidth**: minimize image weight, defer non-critical assets, prefer text + icon over illustration. Existing shimmer skeletons give the user feedback without blocking on data.
- **Shared devices**: tap targets ≥ 48dp, large focus rings, no gestures that require precision (pinch, multi-finger). One phone may be passed between five group members in a session.
- **Screen reader tested**: every state (loading, empty, error, offline, ready) and every action (icon-only buttons, FABs) must announce a coherent label. New `Semantics` / `MergeSemantics` / `ExcludeSemantics` work in the dashboard is the standard for the rest of the app.
- **Color is never the only signal**: success/danger status uses shape + text + color, never color alone.
- **WCAG AA contrast** for body text; ≥ 4.5:1 for normal text, ≥ 3:1 for large text.
