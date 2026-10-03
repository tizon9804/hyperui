# Payments by seller country

**Snapshot 2026-10-03.** Fees in USD from the linked pages. Re-open the pricing URL before
quoting. The seller's country (where the business or person receiving the money is based)
decides everything below; the buyer's country only matters for local methods (PSE, cash, local
cards) and for fee surcharges on international cards.

## 1. The Colombia / LatAm rules (apply before anything else)

1. **Stripe is not available to sellers in Colombia.** The only Latin American countries on
   Stripe's supported list are **Brazil and Mexico**. https://stripe.com/global
2. **Stripe Managed Payments (Stripe's merchant-of-record product) accepts no Latin American
   business.** Supported business locations are US, CA, the EU/EEA countries, CH, GB, NO, AU,
   HK, JP, SG; digital products only. https://docs.stripe.com/payments/managed-payments/eligibility
3. **Lemon Squeezy is being folded into Stripe Managed Payments.** Stripe owns Lemon Squeezy and
   its pricing page carries the banner "2026 Update: Lemon Squeezy + Stripe Managed Payments".
   Colombia is still on Lemon Squeezy's payout list today, but the destination product excludes
   LatAm sellers, so **do not recommend Lemon Squeezy to a Colombian or LatAm seller**; if they
   already use it, tell them to plan a move. https://www.lemonsqueezy.com/pricing ·
   https://docs.lemonsqueezy.com/help/getting-started/supported-countries
4. **Path to Stripe from Colombia:** a US entity through **Stripe Atlas** (Delaware C-corp or
   LLC, **$500** one-time, then $100/yr; founders from 175+ countries). Only worth it for a
   startup that also wants US banking and investors; it adds US tax filings. https://stripe.com/atlas
5. **A merchant of record (MoR)** charges the buyer, collects VAT/sales tax worldwide and pays
   the seller out; the seller invoices nothing abroad. For a solo seller of digital products
   outside the US/EU this is the default, not an option.

## 2. Defaults by seller and buyer

| Seller | Buyers | Recommended | Alternative | Why |
|---|---|---|---|---|
| **Colombia** (digital product, subscriptions) | worldwide | **Polar** — 5% + 50¢, no monthly fee, MoR, Colombia payouts via Stripe Connect Express, remote MCP · https://polar.sh/resources/pricing | **Paddle** — 5% + 50¢, MoR, Colombia supported, remote MCP · https://www.paddle.com/pricing | Both handle global tax; Polar is faster to set up for a one-person seller; Paddle is older and better for B2B invoicing |
| **Colombia** (lowest fee) | worldwide | **Creem** — 3.9% + 40¢, MoR, Colombia local-bank payouts (partner restrictions: may be personal accounts only), USDC payouts · https://www.creem.io/pricing | Polar | Cheapest MoR; smaller company — check payout restrictions first |
| **Colombia / any LatAm** | mostly LatAm buyers (PSE, cash, local cards, COP) | **Mercado Pago** — Colombia Checkout ≈ 3.29–3.99% + COP 800 + 19% VAT on the fee (unverified; official cost page returned 403) · https://www.mercadopago.com.co/developers/en/docs/mcp-server/overview | **PayPal** — 3.4% + fixed domestic, 5.4% + fixed international, COP withdrawal fee COP 3,500 · https://www.paypal.com/co/business/paypal-business-fees | Local methods convert better in LatAm; Mercado Pago is not a MoR, local taxes stay with the seller |
| **Colombia** (startup, investors) | worldwide | **Stripe Atlas → Stripe** — $500 + Stripe fees · https://stripe.com/atlas | Paddle (B2B invoices, no US entity) | Only when the company is going to be a US entity anyway |
| **Brazil / Mexico** | worldwide | Stripe (available) or Paddle/Polar for MoR | Mercado Pago locally | Stripe Managed Payments still excluded; MoR via Paddle/Polar/Creem |
| **US / EU / UK / CA / AU** | worldwide | **Stripe** — 2.9% + 30¢ domestic (US); +1.5% international cards; +1% currency conversion; Managed Payments adds +3.5% for MoR on digital products · https://stripe.com/pricing | Paddle or Polar if MoR without Stripe's eligibility review | Stripe has the deepest tooling (Billing, Tax, Checkout, Payment Links) |
| **Any** (physical goods, services, marketplaces) | — | Stripe where available; Mercado Pago / PayPal elsewhere | — | MoR products (Managed Payments, Paddle, Polar, Creem, Lemon Squeezy) are for **digital** products only |

## 3. Fees table

| Provider | Fee | MoR | Seller in Colombia | Pricing | Countries | Official MCP (user runs it) |
|---|---|---|---|---|---|---|
| **Stripe** | 2.9% + 30¢ (US domestic); +1.5% intl card; +1% FX; dispute $15. Managed Payments +3.5% | No; yes with Managed Payments | **No** (BR, MX only in LatAm) | https://stripe.com/pricing | https://stripe.com/global | `claude mcp add --transport http stripe https://mcp.stripe.com/` then `/mcp` (OAuth). Or `npm i -g @stripe/cli && stripe agent setup`. https://docs.stripe.com/mcp |
| **Paddle** | 5% + 50¢ (custom under $10) | Yes | **Yes** (unsupported: Venezuela, Cuba, Nicaragua, Haiti, Russia and others) | https://www.paddle.com/pricing | https://www.paddle.com/help/start/intro-to-paddle/which-countries-are-supported-by-paddle | Remote, API-key bearer: `claude mcp add --transport http paddle https://mcp.paddle.com/mcp --header "Authorization: Bearer $PADDLE_API_KEY"` (sandbox `https://sandbox-mcp.paddle.com/mcp`; local `@paddle/paddle-mcp-server` frozen). https://developer.paddle.com/changelog/2026/remote-paddle-mcp-server |
| **Polar** | Starter 5% + 50¢ (orgs since 2026-05-27; legacy 4% + 40¢); +1.5% non-US cards; payouts $2/mo + 0.25% + 25¢; Pro $20/mo lowers rates | Yes | **Yes** (payouts via Stripe Connect Express; also AR, BO, CL, CR, DO, EC, SV, GT, GY, JM, MX, PY, PE, TT, UY) | https://polar.sh/resources/pricing | https://polar.sh/docs/merchant-of-record/supported-countries | `claude mcp add --transport http polar https://mcp.polar.sh/mcp/polar-mcp`. https://www.polar.sh/docs/integrate/mcp |
| **Creem** | 3.9% + 40¢; local bank payout 7 EUR/USD or 1% | Yes (tax in 50+ countries) | **Yes**, local bank with partner restrictions (may be personal accounts only); USDC payouts | https://www.creem.io/pricing | https://docs.creem.io/merchant-of-record/supported-countries | None found |
| **Lemon Squeezy** | 5% + 50¢; extra for intl and PayPal | Yes | Yes today — **but folding into Stripe Managed Payments, which excludes LatAm. Risky.** | https://www.lemonsqueezy.com/pricing | https://docs.lemonsqueezy.com/help/getting-started/supported-countries | None found |
| **Mercado Pago** | CO Checkout ≈ 3.29–3.99% + COP 800 + 19% VAT on the fee, by payout speed (unverified) | No | **Native** (also AR, BR, MX, CL, PE, UY) | https://www.mercadopago.com.co/developers/en/docs/mcp-server/overview | same | Remote, OAuth: `claude mcp add --transport http mercadopago https://mcp.mercadopago.com/mcp` (URL from a docs snippet, unverified; confirm on the overview page). Tools: docs search, app/credential management, webhooks, test users, integration-quality check |
| **PayPal** | CO: 3.4% + fixed domestic, 5.4% + fixed international; COP withdrawal COP 3,500; 3.5% FX | No | **Yes**, local bank withdrawal | https://www.paypal.com/co/business/paypal-business-fees | same | Local: `claude mcp add paypal -e PAYPAL_ACCESS_TOKEN=$PAYPAL_ACCESS_TOKEN -e PAYPAL_ENVIRONMENT=SANDBOX -- npx -y @paypal/mcp --tools=all`; remote `https://mcp.paypal.com` (sandbox `https://mcp.sandbox.paypal.com`). https://developer.paypal.com/tools/mcp-server/ |

## 4. Stripe MCP key change (2026-10-31)

From **October 31, 2026**, Stripe MCP no longer accepts full-access secret keys or restricted
API keys without the Agent tag; requests get a `401` with an OAuth discovery challenge. Use
OAuth (`/mcp` after `claude mcp add`) or create an **Agent key** and pass it from an env var in
`.mcp.json` (`"Authorization": "Bearer ${AGENT_API_KEY}"`). Refunds and outbound payments
require human confirmation in the Stripe dashboard. https://docs.stripe.com/mcp

## 5. What the skill does and does not do here

- Does: pick the provider, open the sign-up URL, list the documents the provider will ask for
  (ID, bank account, tax ID / NIT or RUT in Colombia), write the checklist item, prepare the
  checkout/payment-link integration code and the webhook handler with the secret read from an
  env var.
- Does not: create the account, submit KYC, move money, issue refunds, change a subscription or
  run any MCP write tool without the user doing it. Account approval takes days; say so and
  start it early in the checklist.

## Sources

https://stripe.com/global · https://stripe.com/pricing · https://docs.stripe.com/payments/managed-payments/eligibility ·
https://stripe.com/atlas · https://docs.stripe.com/mcp · https://www.lemonsqueezy.com/pricing ·
https://docs.lemonsqueezy.com/help/getting-started/supported-countries · https://www.paddle.com/pricing ·
https://www.paddle.com/help/start/intro-to-paddle/which-countries-are-supported-by-paddle ·
https://developer.paddle.com/changelog/2026/remote-paddle-mcp-server · https://polar.sh/resources/pricing ·
https://polar.sh/docs/merchant-of-record/supported-countries · https://www.polar.sh/docs/integrate/mcp ·
https://www.creem.io/pricing · https://docs.creem.io/merchant-of-record/supported-countries ·
https://www.mercadopago.com.co/developers/en/docs/mcp-server/overview ·
https://www.paypal.com/co/business/paypal-business-fees · https://developer.paypal.com/tools/mcp-server/
