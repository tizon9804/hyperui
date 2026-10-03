---
name: design
description: "Build standout, production-grade frontends end to end: brief → visual direction → design tokens → components → motion → QA. Use when asked to design or build a landing page, marketing site, dashboard, app UI, component or redesign, or to make an existing UI look premium. Orchestrates ui-ux-pro-max, frontend-design, 21st.dev and motion when they are installed."
---

# hyperui:design — standout frontends, end to end

Work as the design lead who owns the result, not as a template filler. Every page gets a point
of view, a typographic identity and one thing people remember.

## 1. Preflight

Check which helpers exist and adapt — never block on a missing one:
- `ui-ux-pro-max`: `.claude/skills/ui-ux-pro-max/` or `~/.claude/skills/ui-ux-pro-max/` (styles, palettes, font pairings, UX rules, chart types).
- `frontend-design` (Anthropic plugin skill) for aesthetic direction; 21st.dev MCP tools (`mcp__21st__*`) for component candidates; `motion` in `package.json` for animation.
- If the key ones are missing, suggest `/hyperui:setup` once, then proceed with what is available.

## 2. Process

1. **Brief (5 lines, write it down before any code).** Product and what it does · audience · the ONE job
   of this page (sign up, download, understand, decide) · 3 tone words · constraints (stack, brand
   assets, i18n, existing tokens). If the brief lacks the product, infer it from the repo and confirm.
2. **Direction (the only mandatory checkpoint).** Use `frontend-design` for the point of view and
   `ui-ux-pro-max` to search styles, palettes and font pairings for the product category. Propose
   2–3 directions as short cards: name · type pairing · palette (3 colors + accent) · signature move
   (the one memorable element). Ask the user to pick. Do not build before the pick.
3. **Tokens before components.** Write CSS custom properties on `:root`: color *roles*
   (`--bg`, `--surface`, `--text`, `--muted`, `--accent`, `--border`), type scale, spacing, radius,
   elevation, motion durations and easings. Dark mode under `@media (prefers-color-scheme: dark)`
   guarded by `:root:not([data-theme="light"])`, plus an explicit `:root[data-theme="dark"]`
   override. Fonts via the framework loader (`next/font`) or one preconnected stylesheet; set
   `font-display: swap` and size-adjusted fallbacks so there is no layout shift.
4. **Components.** Compose from the stack's primitives. When 21st.dev is installed, pull 2–3
   candidates per component and *adapt* them to the tokens — never paste a component with its own
   palette, radius or shadow system. One visual signature element per page (a type treatment, a
   live demo, a material, an animation), everything else quiet.
5. **Motion.** Hand off to the `motion` skill. Defaults: entrance stagger on the hero, hover and tap
   micro-feedback on interactive elements, scroll reveal only where it aids reading. Always honor
   `prefers-reduced-motion`.
6. **QA before declaring done.** Responsive at 360 / 768 / 1280 / 1920; 16px side gutters on
   phone; no horizontal scroll; contrast AA; visible focus states; full keyboard navigation;
   every image has width/height; fonts cause no layout shift; Lighthouse ≥ 90 in all four
   categories (run it when a build is available and report the numbers).

## 3. Rules of taste

- Typography carries the identity: one display face with character + ONE body face. Pick them
  deliberately for this product, not the family you reach for everywhere.
- Real hierarchy: display size ≥ 3× body; weights jump (e.g. 800 display, 400 body), not 500→600.
- Banned generic tells: purple-to-blue gradient hero, three-icon feature grid with identical
  cards, "Welcome to …" headings, glassmorphism on everything, everything centered, emoji as
  icons, drop shadows on every card, a big number + small label as the default hero.
- One accent color, used sparingly, always meaning "action" or "live".
- Depth from layering and tonal steps (bg → surface → raised), not borders on everything.
- Whitespace is generous and rhythmic: 8pt grid, sections breathe, density only where data lives.
- Real copy and real data in the deliverable. Never lorem ipsum, never placeholder avatars.
- The hero opens with the most characteristic thing in the product's world: a live demo, a real
  screenshot, a single bold statement. Decide which, on purpose.
- Images with intent: the product, its output, its materials. No stock people pointing at laptops.
- Dark mode is designed, not inverted: lift surfaces, lower saturation, re-check contrast.
- Icons from one set, one stroke width, one optical size.
- Empty, loading and error states are designed up front, with the same care as the happy path.
- Max 80ch line length for body text; serif bodies get slightly more line-height.
- Forms: labels always visible, inline validation, generous hit targets (≥ 44px).
- Motion is choreography, not decoration: one entrance sequence per view.

## 4. Stack defaults

React + Next.js App Router unless the project says otherwise. Styling follows the project (CSS
Modules or Tailwind); tokens always live in CSS variables so either works. `next/image` and
`next/font`. Motion (`motion/react`) for animation. No component-library lock-in: shadcn and
21st.dev pieces are source you own and restyle to the tokens.

## 5. Deliverable

End with: what changed (files, by role) · how to run it · screenshots if a browser tool exists ·
Lighthouse numbers if measured · open decisions for the user. Keep it short; the page speaks.

## 6. Redesigns and existing UIs

- Audit first: list the current tokens (or their absence), the fonts actually loaded, the number of
  distinct grays/radii/shadows in use. The count is the diagnosis; the fix is consolidation.
- Keep information architecture unless the brief asks otherwise; change the skin, type and
  rhythm. Users forgive a new look, not a lost page.
- Migrate incrementally: tokens → global type → shared primitives (button, card, input) → pages.
  Each step ships and keeps Lighthouse ≥ 90.
- Delete dead CSS as you go; the redesign is not done while two systems coexist.

## 7. i18n and content

- Design with the longest language first (Spanish and German run ~25–30% longer than English);
  no fixed-width labels, no truncation of CTAs.
- Dates, numbers and currencies through `Intl.*`, never hand-formatted.
- Every string in the dictionaries, including alt text and aria labels; no copy in components.

## 8. Tokens starter

```css
:root {
  --bg: #0b0d12; --surface: #141822; --raised: #1c2130;
  --text: #f2f4f8; --muted: #9aa3b5; --border: #2a3042;
  --accent: #3ecf8e; --accent-ink: #062b1c;
  --font-display: var(--font-sora), system-ui, sans-serif;
  --font-body: var(--font-inter), system-ui, sans-serif;
  --fs-display: clamp(2.5rem, 6vw, 4.5rem); --fs-h2: clamp(1.75rem, 3vw, 2.5rem);
  --fs-body: 1.0625rem; --fs-small: 0.875rem;
  --space-1: 0.5rem; --space-2: 1rem; --space-3: 1.5rem; --space-4: 2.5rem; --space-5: 4rem;
  --radius-s: 8px; --radius-m: 14px; --radius-l: 24px;
  --shadow-1: 0 1px 2px rgb(0 0 0 / .25); --shadow-2: 0 12px 32px -12px rgb(0 0 0 / .45);
  --dur-fast: 150ms; --dur-base: 250ms; --dur-slow: 450ms;
  --ease-out: cubic-bezier(.16, 1, .3, 1); --ease-in-out: cubic-bezier(.65, 0, .35, 1);
  color-scheme: dark;
}
:root[data-theme="light"] {
  --bg: #fbfbfd; --surface: #ffffff; --raised: #f2f3f7;
  --text: #0e1220; --muted: #5c6578; --border: #e3e6ee;
  --accent: #17b877; --accent-ink: #ffffff; color-scheme: light;
}
body { background: var(--bg); color: var(--text); font: var(--fs-body)/1.6 var(--font-body); }
```
