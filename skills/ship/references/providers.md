# Provider matrix — hosting, backend, database, auth

**Snapshot 2026-10-03.** Prices in USD, taken from the linked pricing pages that day. Prices and
free tiers change often: **re-open the URL before quoting a number to the user.** "(unverified)"
marks a claim from a third-party page or a snippet, not from the provider's own page. MCP lines
are shown so the user can run them; the skill never runs `claude mcp add` itself.

## 1. Decision matrix by budget

Assumes a web app, sometimes with mobile. Seller country overrides the payments column; see
`payments-by-country.md`.

| Budget | Frontend / host | Database | Auth | Payments | Domain | Why |
|---|---|---|---|---|---|---|
| **$0** (validate, personal) | Cloudflare Workers free (commercial use allowed) · Vercel Hobby only if **non-commercial** | Neon free (no pausing, scales to zero) · Supabase free (pauses after 7 idle days) | Supabase Auth (50k MAU) · Better Auth (MIT, self-hosted) | CO/LatAm: Polar · US/EU: Stripe or Polar | Free `*.workers.dev` / `*.vercel.app` subdomain | Nothing costs money until you sell; MoR handles global VAT |
| **< $20/mo** (first paying users) | Cloudflare Workers Paid $5 · Netlify Personal $9 | Neon Launch (pay as you go, no minimum) | Clerk free (50k MRU) · Better Auth | CO/LatAm: Paddle / Polar / Creem · US/EU: Stripe | Cloudflare Registrar or Porkbun (~$11/yr) | Commercial-safe, near at-cost, no Stripe country problem |
| **< $100/mo** (real product) | Vercel Pro $20 (Next.js) · Render or Railway (full-stack) | Supabase Pro $25 (DB + auth + storage + backups) | Supabase Auth · Clerk Pro $25 | US/EU: Stripe + Billing · CO: Paddle/Polar · LatAm buyers: Mercado Pago | Cloudflare Registrar | Managed backups, no cold starts, one vendor per concern; email Resend free → $20 |
| **Startup** (team, compliance) | AWS Amplify or ECS Fargate via CDK/Terraform · Vercel Pro/Enterprise | Aurora Serverless v2 · PlanetScale Postgres HA $15+ | Auth0 · Clerk (SSO) | Stripe via a Stripe Atlas Delaware entity ($500) when founders are in CO; MoR if you do not want to run tax compliance | Route 53 (IaC-managed) | IaC, audit, scaling; AWS MCP, Terraform MCP, GitHub MCP all fit |

## 2. Defaults by archetype

| Archetype | Default stack | Why |
|---|---|---|
| **non-tech** | Vercel or Netlify (git-push deploy) + Supabase (one dashboard: DB, auth, storage) + Polar payment links + Porkbun or Cloudflare domain | Fewest moving parts; every piece has a remote OAuth MCP (Vercel, Netlify, Supabase, Polar) so Claude can read state without API keys |
| **dev** | Next.js on Vercel (or Cloudflare Workers) + Neon or Convex + Clerk or Better Auth + Stripe or Paddle/Polar + Resend + GitHub Actions | Branch-per-PR DBs, typed backends, good MCPs (Neon, Convex, Clerk, Stripe, GitHub) |
| **senior** | AWS (CDK or Terraform) on ECS Fargate or EKS + Aurora + Cognito/Auth0 + Stripe + Route 53 + SES + GitHub Actions (OIDC) | Full control and auditability; AWS MCP Server (IAM-scoped), HashiCorp Terraform MCP, Kubernetes MCP |

## 3. Country override (seller side)

| Seller | Payments | Code signing / stores |
|---|---|---|
| **Colombia and LatAm (except BR, MX)** | No direct Stripe. Paddle, Polar, Creem (MoR) · Mercado Pago for LatAm buyers · PayPal fallback · Stripe only via a US/EU entity. **Lemon Squeezy flagged risky** (folding into Stripe Managed Payments, which excludes LatAm). | Azure Artifact Signing not available to individuals outside US/CA → Microsoft Store or an OV/EV cert. Apple and Google Play work normally. |
| **Brazil, Mexico** | Stripe available; Managed Payments (MoR) still not — use Paddle/Polar/Creem for MoR, Mercado Pago locally. | Same as above. |
| **US / EU / UK / CA / AU** | Stripe (+ Managed Payments for digital products) · Paddle/Polar if you want MoR without Stripe. | Azure Artifact Signing available (individuals: US/CA; orgs: US/CA/EU/UK, unverified). |

## 4. Hosting and deploy

| Provider | Free tier | Paid entry | Best fit | Caveat | Pricing / docs | Official MCP (user runs it) |
|---|---|---|---|---|---|---|
| **Cloudflare Workers** | 100k requests/day, 10 ms CPU per invocation; D1 5 GB, 5M rows read/day; KV 100k reads/day. Commercial use allowed. | Workers Paid **$5/mo** minimum: 10M requests, then $0.30/M; 30M CPU-ms included | Static + edge SSR (Astro, SvelteKit, Next via adapter); cheapest at scale | Cloudflare says to **start new projects on Workers, not Pages** | https://developers.cloudflare.com/workers/platform/pricing/ · https://developers.cloudflare.com/pages/ | `claude mcp add --transport http cloudflare https://mcp.cloudflare.com/mcp` (OAuth; 2,500+ API endpoints). Docs-only: `claude mcp add --transport http cloudflare-docs https://docs.mcp.cloudflare.com/mcp`. https://developers.cloudflare.com/agents/model-context-protocol/mcp-servers-for-cloudflare/ |
| **Vercel** | Hobby: 100 GB transfer, 1M function invocations, 1M CDN requests/mo | Pro **$20/mo** per team + $20 per extra developer seat | Next.js first-class; any SSR or static frontend | **Hobby is non-commercial personal use only** — any payment or ads requires Pro | https://vercel.com/pricing · https://vercel.com/docs/limits/fair-use-guidelines | `claude mcp add --transport http vercel https://mcp.vercel.com` then `/mcp` to log in (deploys, logs, analytics). https://vercel.com/docs/agent-resources/vercel-mcp |
| **Netlify** | 300 credits/mo (production deploy ≈ 15 credits, transfer 20 credits/GB), unlimited deploy previews | Personal **$9/mo** (1,000 credits) | Static, Astro/Angular/React SPAs, light functions | Credit model: check the credit table before promising "free" | https://www.netlify.com/pricing/ | `claude mcp add --transport http netlify https://netlify-mcp.netlify.app/mcp` (docs also offer `npx -y add-mcp https://netlify-mcp.netlify.app/mcp`). https://docs.netlify.com/build/build-with-ai/netlify-mcp-server/ |
| **AWS Amplify Hosting** | New-account credits: 1,000 build-min, 5 GB CDN storage, 15 GB transfer, 500k SSR requests/mo | Pay as you go: build $0.01/min, $0.15/GB served, $0.023/GB stored, SSR $0.30/M requests | Next.js/Angular/React on AWS; teams already on Cognito/AppSync/DynamoDB | Free tier is time-limited credits, not permanent | https://aws.amazon.com/amplify/pricing/ | No Amplify server; use the AWS MCP Server: `claude mcp add --transport http aws-mcp https://aws-mcp.us-east-1.api.aws/mcp` (OAuth). https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started-aws-mcp-server.html |
| **Firebase Hosting / App Hosting** | Spark: Hosting 10 GB storage, 360 MB/day transfer | Blaze pay as you go (keeps free quotas) | Static + SPA; App Hosting for Next.js/Angular SSR | **App Hosting (SSR) is not on Spark** — needs Blaze | https://firebase.google.com/pricing | `claude mcp add firebase -- npx -y firebase-tools@latest mcp` (Auth, Firestore, rules, Hosting deploy, logs). https://firebase.google.com/docs/ai-assistance/mcp-server |
| **Render** | Web services sleep after 15 min idle (~1 min cold start), 750 instance-h/mo, ephemeral disk | Paid instance prices not readable on the page (unverified) | Full-stack services, workers, cron, Docker, managed Postgres | **Free Postgres 1 GB expires after 30 days**, no backups | https://render.com/docs/free · https://render.com/pricing | In Claude Code: `/add-plugin render` (remote `https://mcp.render.com`). https://render.com/docs/mcp-server |
| **Railway** | Trial $5 one-time credit / 30 days; Free plan $1/mo credit | Hobby **$5/mo** (includes $5 usage); Pro $20/mo per workspace. Usage ≈ $20/vCPU-mo, $10/GB-mo RAM | Full-stack + databases with zero config, monorepos, containers | Free credit is small; expect Hobby for anything always-on | https://railway.com/pricing | `railway setup agent --oauth` (CLI ≥ 5.44.0; remote `mcp.railway.com`). https://docs.railway.com/reference/mcp-server |
| **Fly.io** | **No free tier for new orgs.** Trial 2 h runtime or 7 days | Cheapest always-on shared-cpu-1x 256 MB ≈ $2.19/mo + transfer | Containers close to users, multi-region, long-running | Not a "$0" option | https://docs.fly.io/about/pricing | `fly mcp server --claude` (local stdio in flyctl). https://fly.io/docs/flyctl/mcp-server/ |

## 5. Backend, database, auth

| Provider | Free tier | Paid entry | Fit | Caveat | Pricing / docs | Official MCP (user runs it) |
|---|---|---|---|---|---|---|
| **Neon** (serverless Postgres) | Permanent free plan, no card: 100 projects, 1 GB/project (20 GB total), 100 CU-h/project/mo, 10 branches | Launch: pay as you go, **no monthly minimum** ($0.106/CU-h, $0.35/GB-mo) | Postgres for Vercel/Next.js, branch per PR | Scales to zero after 5 min (first query wakes it) | https://neon.com/pricing | `npx neon@latest init` (MCP + skills + project link; remote `https://mcp.neon.tech/mcp`). https://neon.com/docs/ai/neon-mcp-server |
| **Supabase** | 2 active projects, 500 MB DB each, 50k MAU auth | Pro **$25/mo** (8 GB disk, 100k MAU, 7-day backups, no pausing) | Postgres + Auth + Storage + Edge Functions in one dashboard | **Free projects pause after 1 week of inactivity** | https://supabase.com/pricing | `claude mcp add --scope project --transport http supabase "https://mcp.supabase.com/mcp"` (add `?read_only=true` or `?project_ref=<id>`). https://supabase.com/docs/guides/getting-started/mcp |
| **Firebase (Firestore / Auth)** | Spark: Firestore 1 GiB, 50k reads/day, 20k writes/day; Auth 50k MAU | Blaze pay as you go | Mobile-first (Flutter/Android/iOS), realtime, NoSQL | NoSQL modelling; vendor lock-in | https://firebase.google.com/pricing | Firebase MCP line above |
| **Convex** | Free / Starter: 1M function calls/mo, then pay as you go | Professional **$25/dev/mo** | Reactive TypeScript backend (DB + functions + realtime) | Production is read-only from the MCP unless `--dangerously-enable-production-deployments` | https://www.convex.dev/pricing | `claude mcp add convex -- npx -y convex@latest mcp start`. https://docs.convex.dev/ai/convex-mcp-server |
| **PlanetScale** | **No free tier** | Postgres single-node PS-5 **$5/mo**; Postgres HA $15/mo; Vitess (MySQL) HA $39/mo | Production Postgres/MySQL at scale | Storage and egress billed extra | https://planetscale.com/pricing | `claude mcp add --transport http planetscale https://mcp.pscale.dev/mcp/planetscale`. https://planetscale.com/docs/connect/mcp |
| **MongoDB Atlas** | M0 free forever: 512 MB shared, 100 ops/s | Flex $0.011/h (~$8–30/mo); Dedicated M10 from ~$57/mo | Document data, JS-heavy teams | Shared tier throttles | https://www.mongodb.com/pricing | `claude mcp add mongodb -e MONGODB_URI=<uri> -- npx -y mongodb-mcp-server` (exact args unverified; `MONGODB_READ_ONLY=true` available). https://www.mongodb.com/docs/mcp-server/get-started/ |
| **AWS RDS / Aurora** | New accounts: $100 credit + up to $100 more, 6-month free plan; Aurora PG Serverless up to 4 ACU / 1 GiB | Aurora Serverless v2 $0.12/ACU-h Standard | Enterprise / AWS-native | Minimum ACU billing; see page | https://aws.amazon.com/rds/aurora/pricing/ · https://aws.amazon.com/free/ | AWS MCP Server (line above) or `awslabs.postgres-mcp-server` via `uvx`. https://github.com/awslabs/mcp |
| **Clerk** (auth) | 50k MRU per app (retained = returns ≥ 24 h after signup) | Pro **$25/mo** ($20 annual), then $0.02/MRU | Drop-in auth UI for Next.js/React/Expo | MRU, not MAU — read the definition | https://clerk.com/pricing | `claude mcp add --transport http clerk https://mcp.clerk.com/mcp` (docs/snippets). https://clerk.com/docs/guides/ai/mcp/clerk-mcp-server |
| **Better Auth** | MIT library, self-hosted, no per-user cost | Optional hosted "Infrastructure": $0 / $20 / $299 (unverified) | TypeScript apps that own auth in their own DB (Neon/Supabase/Postgres) | You run the DB and the migrations | https://www.better-auth.com/docs/introduction | Docs MCP: `claude mcp add --transport http better-auth https://mcp.better-auth.com/mcp` |
| **Auth0** | Free up to 25k MAU | B2C Essentials **$35/mo** for 500 MAU | Enterprise SSO, B2B | Price jump after free | https://auth0.com/pricing | Auth0 MCP Server (Beta), install command not on the fetched page (unverified). https://github.com/auth0/auth0-mcp-server |
| **Supabase Auth** | included in Supabase free (50k MAU) | included in Pro | Same dashboard as the DB; social + magic link + phone | Tied to Supabase | https://supabase.com/pricing | Supabase MCP line above |

## 6. Free-tier caveats (say them before the user picks)

- **Vercel Hobby is personal, non-commercial.** Any payment processing, ads or paid work on the site requires Pro ($20/mo). https://vercel.com/docs/limits/fair-use-guidelines
- **Fly.io has no free tier** for new organizations; the trial is 2 h of runtime or 7 days. https://docs.fly.io/about/pricing
- **Render free Postgres is deleted after 30 days**, no backups; free web services sleep after 15 min. https://render.com/docs/free
- **Supabase free projects pause after 7 idle days**; Neon's free plan scales to zero but does not pause the project. https://supabase.com/pricing · https://neon.com/pricing
- **PlanetScale has no free tier**; cheapest is $5/mo single-node Postgres. https://planetscale.com/pricing
- **Firebase App Hosting (SSR) needs Blaze**; only classic Hosting is on Spark. https://firebase.google.com/pricing
- **Railway's free plan is a $1/mo credit**; always-on services land on Hobby $5/mo. https://railway.com/pricing
- **Cloudflare: start on Workers, not Pages**, for new projects. https://developers.cloudflare.com/pages/

## 7. Related tooling (senior / startup rows)

- **GitHub Actions**: public repos free; private on Free plan 2,000 min/mo. MCP: `claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer $GITHUB_PAT"}}'` (the user fills the PAT from an env var). https://docs.github.com/en/billing/concepts/product-billing/github-actions · https://github.com/github/github-mcp-server
- **Terraform MCP** (HashiCorp): `claude mcp add terraform -s user -t stdio -- docker run -i --rm hashicorp/terraform-mcp-server`. The awslabs `terraform-mcp-server` and `cdk-mcp-server` are deprecated; use `awslabs.aws-iac-mcp-server`. https://developer.hashicorp.com/terraform/mcp-server · https://github.com/awslabs/mcp/discussions/2615
- **Pulumi MCP**: `claude mcp add --transport http pulumi https://mcp.ai.pulumi.com/mcp`. https://www.pulumi.com/docs/iac/guides/ai-integration/mcp-server/
- **Context7** for any library's current docs: `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp`. https://context7.com/docs/resources/all-clients
