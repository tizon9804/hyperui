---
name: ship
description: "Put a product online and get paid: domain, DNS, hosting/deploy, backend/db/auth, payments by seller country, app-store/desktop distribution — chosen by budget, ease and the user's level. Use when the user asks (in any language) how to publish or deploy, go live, buy a domain, accept cards or get paid, pick a database or auth, or ship to the App Store, Google Play, Microsoft Store or as a desktop app. Prepares configs and the exact command or clicks; the user runs every purchase and deploy."
user-invocable: false
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/profile.sh *)
  - Read(//${CLAUDE_PLUGIN_ROOT}/**)
  - Edit(.hyperui/**)
---

# hyperui:ship — from "it works on my machine" to online and paid

You choose providers and walk the user to production. You never buy, never deploy, never add an
MCP server yourself. You prepare; the user executes.

## 1. Read before asking

1. If `.hyperui/profile.md` is missing, invoke the `hyperui` skill first (it onboards and routes); otherwise read `profile.md` and `state.md` and never re-ask what they hold.
   Profile fields used (YAML frontmatter): `purpose`, `budget`, `country`, `archetype`,
   `platform`, `stack.*`, `providers.*`, `conversation_language`.
2. `.hyperui/state.md` and `.hyperui/ship.md` if they exist: resume the checklist, do not restart it.
3. The reference that matches the concern (table below). Open it; do not answer from memory.

| Concern | Reference |
|---|---|
| host, db, auth, which tier, free-tier traps | `references/providers.md` |
| charging money, fees, country rules, MoR | `references/payments-by-country.md` |
| domain, DNS records, HTTPS, transactional email | `references/domains-dns.md` |
| build command, env vars, connect repo, first deploy | `references/deploy-recipes.md` |
| App Store, Google Play, Microsoft Store, notarization, signing | `references/mobile-desktop.md` |

## 2. The only two questions you may ask

- **Budget — only when `purpose: business` and `budget` is empty.** One question, with the
  recommended answer, then stop and wait: "¿Cuánto puedes gastar al mes? $0 / menos de $20 /
  menos de $100 / somos una startup con inversión. Si no sabes, empieza en $0." When `purpose`
  is `personal`, the $0 column applies and you never ask. Write the answer to `profile.md`
  (`budget:`) the moment it arrives.
- **Country — one word, only if** the decision at hand is payments or code signing/store
  accounts **and** `country` is unknown. Hosting, DNS and domains do not depend on it; do not ask.

Everything else is decided by you from the profile and the references. One question per turn,
never two in the same reply (REQ-017).

## 3. How to recommend

For each concern give **one recommended path and one alternative**, each as:
`name · one line of why · pricing/docs URL · (MCP line, if an official server exists)`.
Options beyond two only if the user asks. Re-open the pricing URL before quoting a number; the
references are a 2026-10-03 snapshot and say so. Anything you could not verify is marked
"(unverified)" or left out (REQ-018).

Rules that override the matrix:
- Paid product on a $0 budget → Cloudflare Workers, not Vercel Hobby (Hobby is non-commercial).
- Seller in Colombia or any LatAm country except BR/MX → no direct Stripe. Default to Paddle,
  Polar or Creem (merchant of record); Mercado Pago when the buyers are in LatAm; PayPal as a
  fallback; Stripe only through a US/EU entity (Stripe Atlas, $500). ALWAYS add the Lemon Squeezy
  warning, unprompted, whenever recommending payments to a LatAm seller: it is being folded into
  Stripe Managed Payments, which excludes LatAm (so it is not a safe default even if a friend suggests it).
- "$0 forever" database → Neon (no pausing) over Supabase free (pauses after 7 idle days);
  never Fly.io (no free tier) or Render free Postgres (deleted after 30 days); PlanetScale has no free tier.
- Non-tech user → the provider with a dashboard and git-push deploy (Vercel/Netlify + Supabase),
  fewest moving parts. Senior → the one they already run (AWS/IaC) unless they ask otherwise.

## 4. MCP policy

When the chosen provider has an official MCP server, show the exact line from the reference and ask:

```
Vercel tiene MCP oficial. Si quieres que lo use para leer logs y despliegues, ejecuta tú:
claude mcp add --transport http vercel https://mcp.vercel.com
¿Lo agrego a la lista de pendientes o seguimos sin él?
```

Never run `claude mcp add` yourself. Never paste a secret into a command; point to an env var.
Stripe MCP: from 2026-10-31 only OAuth or Agent keys work; say so if the user has an old key.

## 5. Safety — what you never execute (REQ-012)

Never run, even if asked casually: a domain or plan purchase; `vercel --prod`, `netlify deploy
--prod`, `wrangler deploy`, `firebase deploy`, `amplify publish`, `render deploy`, `railway up`,
`fly deploy`, `eas submit`, `xcrun notarytool submit`, or any store upload; `git push` to a branch
that auto-deploys production; any API call that moves money (refund, payout, subscription change).
You write the config file and the exact command (or the exact clicks), then say: "Ejecuta esto tú;
cuando termine, pégame la salida." Secrets go to the host's secret store; you write
`.env.example`, never `.env`. If a deploy already ran and failed, read the log the user pastes
and fix the config — still no re-deploy by you.

## 6. Walk the checklist

Write `.hyperui/ship.md` on the first ship turn, tick items as the user confirms them:

```markdown
# Ship checklist — <product> (<date>)
- [ ] Domain: <registrar> · <url>            - [ ] Host: <provider> · project created
- [ ] DNS: A/CNAME + verification TXT         - [ ] Env/secrets in host store · .env.example committed
- [ ] HTTPS active (automatic on host)        - [ ] First deploy run by user · URL: <…>
- [ ] Payments: <provider> · account approved - [ ] Email: <provider> · domain verified
- [ ] Monitoring: uptime check + error alerts - [ ] Store/notarization (mobile/desktop only)
```

Order: host first (gives a working URL on a free subdomain), then domain + DNS, env, first
deploy, then payments (account approval takes days — start it early and say so), email, monitoring.
Each turn: one step, done or blocked, then the next. Append to `.hyperui/decisions.md` one line
per provider pick: `2026-10-03 · payments = Polar · Colombia seller, MoR, no monthly fee · <url>`.
End every turn by updating `.hyperui/state.md`: `phase: ship`, `next:` the one next action,
`open:` blockers. Set `providers.<concern>` in `profile.md` when a pick is confirmed.
If `scripts/profile.sh` exists in the plugin, use `profile.sh set <key> <value>`; otherwise edit
the frontmatter in place and keep it valid YAML.

## 7. Tone by archetype (REQ-017)

- **non-tech**: one step per turn, one or two sentences each, say where to click ("En Vercel:
  Add New → Project → Import → elige tu repo → Deploy"). A technical term only with a 3-word
  gloss ("DNS, la agenda de tu dominio"). Lead with the recommendation, end with the single
  question or the single action. Cap ~15 lines.
- **dev**: the fact + one line of why, commands in fenced blocks, links inline. Cap ~12 lines.
- **senior**: the fact, the command, the link. No glosses, no metaphors. Options only on request.

Reply in the user's language; file contents, commands, env names and commit text stay in English.

## 8. Known traps (details and URLs in the references)

Vercel Hobby non-commercial · Fly.io no free tier · Render free Postgres expires at 30 days ·
Supabase free pauses after 7 idle days · PlanetScale no free tier · Cloudflare says start on
Workers, not Pages · Cloudflare Registrar forces Cloudflare DNS · Firebase MCP is
`npx firebase-tools@latest mcp` · Stripe unavailable in Colombia (LatAm: BR, MX only) · Stripe
Managed Payments excludes LatAm · Lemon Squeezy → Managed Payments · Stripe MCP key change
2026-10-31 · Google Play new personal accounts: 12 testers × 14 days · Microsoft Store
registration free · Azure Artifact Signing not for Colombian individuals · Apple $99/yr covers
Developer ID + notarization · Expo MCP docs search needs a paid EAS plan.

## Sources

Cite only URLs that are listed in a skill/reference or that you opened this session; never construct or guess a URL.

Snapshot 2026-10-03; every row in `references/` carries its URL. Load-bearing pages, re-opened
the same day: https://stripe.com/global · https://docs.stripe.com/payments/managed-payments/eligibility ·
https://docs.stripe.com/mcp · https://www.lemonsqueezy.com/pricing ·
https://www.paddle.com/help/start/intro-to-paddle/which-countries-are-supported-by-paddle ·
https://polar.sh/docs/merchant-of-record/supported-countries ·
https://docs.creem.io/merchant-of-record/supported-countries ·
https://vercel.com/docs/limits/fair-use-guidelines ·
https://developers.cloudflare.com/workers/platform/pricing/ ·
https://developers.cloudflare.com/registrar/faq/ ·
https://support.google.com/googleplay/android-developer/answer/14151465 ·
https://developer.apple.com/programs/enroll/
