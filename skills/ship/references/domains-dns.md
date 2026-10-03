# Domains, DNS, HTTPS and transactional email

**Snapshot 2026-10-03.** Prices in USD for a `.com`; re-open the URL before quoting. The skill
prepares the records and the exact clicks; **the user buys the domain and saves the records.**

## 1. Registrar picks

| Registrar | .com / yr | Why / caveat | URL |
|---|---|---|---|
| **Cloudflare Registrar** (default) | **$10.44** at cost (registry + ICANN price, no markup; ≈ $11.15 after the 2026-11-01 Verisign increase, unverified) | Renews at the same price; free WHOIS redaction and DNSSEC. **Must use Cloudflare nameservers** — fine, Cloudflare DNS is the best free DNS anyway. Needs a Cloudflare account first; new domains can be registered directly, existing ones transferred after 60 days at the previous registrar. | https://www.cloudflare.com/products/registrar/ · https://developers.cloudflare.com/registrar/faq/ |
| **Porkbun** (non-tech alternative) | **$11.08** registration and renewal | Simplest checkout; free WHOIS privacy, Let's Encrypt SSL, 20 email forwards, DNS included. No nameserver lock-in. | https://porkbun.com/tld/com |
| **Namecheap** | ~$9.58 first year, renewal ~$14–18 (unverified; official page returned 403) | Cheap first year, renewal jump. Only if the user already has an account there. | https://www.namecheap.com/domains/com/ |
| **AWS Route 53** (senior / IaC) | ~$16/yr (unverified) + **$0.50/mo per hosted zone** + $0.40 per million queries | Domain and zone managed from Terraform/CDK alongside the rest of the stack; ALIAS records to CloudFront/ALB. | https://aws.amazon.com/route53/pricing/ |
| Google Domains | — | **Gone**: migrated to Squarespace Domains. Do not recommend. | https://domains.squarespace.com/google-domains |

Non-tech wording: "Un dominio es tu dirección en internet; cuesta unos $11 al año. Lo compras tú
en Porkbun con tu tarjeta; yo te digo qué escribir después."

## 2. DNS records — what to add and where

The host tells you the exact values after you add the custom domain in its dashboard. The pattern:

| Record | Name | Value | When |
|---|---|---|---|
| **A** | `@` (root `example.com`) | the host's IPv4 as shown in its domain card (Vercel: `76.76.21.21` or the value on the card; Netlify and Firebase show theirs in the UI) | Root domain on hosts that give an IP |
| **CNAME** | `www` | the host's target, copied from its UI (Vercel gives a per-project hostname like `<id>.vercel-dns-017.com`; Netlify `<site>.netlify.app`; Render `<service>.onrender.com`; Railway the CNAME **and** a TXT it shows — both required) | Subdomains |
| **CNAME / ALIAS / ANAME flattening** | `@` | same target as above | Root domain on hosts that only give a hostname; Cloudflare and Porkbun flatten CNAME at the root, Route 53 uses ALIAS |
| **TXT** | `@` or the name the host gives (`_vercel`, `_acme-challenge`, Railway's verification name…) | the verification string the host shows | Domain ownership (Vercel asks only when the domain is used by another Vercel account) / certificate issuance |
| **MX + TXT (SPF) + CNAME (DKIM) + TXT (DMARC)** | `@`, `resend._domainkey`, `_dmarc`… | from the email provider's dashboard | Transactional email (section 4) |

Steps the skill writes for the user (one per turn for non-tech):
1. In the host: Project → Settings → Domains → Add `example.com` and `www.example.com`. Copy the
   records it shows.
2. In the registrar/DNS: DNS → Add record → type, name, value exactly as copied. On Cloudflare set
   the proxy (orange cloud) **off** for records the host must verify, unless the host's docs say
   it works proxied (Cloudflare Workers custom domains do; Vercel recommends DNS-only).
3. Wait: propagation is usually minutes, up to 48 h. Check with `dig +short example.com` or
   https://dnschecker.org. The host's domain page turns green when it has verified.
4. Redirect `www` → root (or the reverse) in the host's domain settings so one URL is canonical.
5. Remove stale `AAAA` or conflicting `A`/`CNAME` records for the same hostname — the most common
   cause of "invalid configuration" on Vercel and Render.

## 3. HTTPS is automatic on every host in `deploy-recipes.md`

Cloudflare Workers, Vercel, Netlify, Amplify, Firebase Hosting, Render and Railway issue and renew
Let's Encrypt (or their own) certificates once DNS points at them. Nothing to buy. If HTTPS stays
"pending" for more than an hour the cause is almost always a wrong record or a CAA record at the
DNS provider that forbids the issuer; check `dig CAA example.com`. Route 53 + CloudFront uses ACM
(free) — request the cert in `us-east-1` and add the ACM validation CNAME.

## 4. Transactional email (receipts, magic links, password resets)

| Provider | Free | Paid entry | Fit | MCP (user runs it) | URL |
|---|---|---|---|---|---|
| **Resend** (default) | 3,000 emails/mo, 100/day, 3 domains | Pro **$20/mo** (50k), $35 (100k) | Best DX for React/Next; React Email templates | `claude mcp add resend -e RESEND_API_KEY=$RESEND_API_KEY -- npx -y resend-mcp`; remote `https://mcp.resend.com/mcp` · https://resend.com/docs/mcp-server | https://resend.com/pricing |
| **Postmark** | 100/mo | Basic **$15/mo** for 10k (+$1.80 per 1k) | Deliverability focus, separate transactional/broadcast streams | none found | https://postmarkapp.com/pricing |
| **Amazon SES** | covered by AWS free credits ($200 / 6 months for new accounts) | **$0.10 per 1k** à la carte; dedicated IP $24.95/mo | Cheapest at volume; senior/AWS stacks | AWS MCP Server | https://aws.amazon.com/ses/pricing/ |

Setup the skill prepares: a sending subdomain (`mail.example.com`) so the root's reputation is
untouched; the SPF TXT, DKIM CNAMEs and a `p=none` DMARC TXT exactly as the provider shows them;
`EMAIL_FROM` and the API key as env vars in the host's secret store; one test send that **the user
triggers** from the provider dashboard or a `curl` the skill writes out.

## Sources

https://www.cloudflare.com/products/registrar/ · https://developers.cloudflare.com/registrar/faq/ ·
https://porkbun.com/tld/com · https://www.namecheap.com/domains/com/ · https://aws.amazon.com/route53/pricing/ ·
https://domains.squarespace.com/google-domains · https://vercel.com/docs/domains/working-with-domains/add-a-domain ·
https://developers.cloudflare.com/workers/configuration/routing/custom-domains/ · https://render.com/docs/custom-domains ·
https://docs.railway.com/guides/public-networking · https://resend.com/pricing · https://resend.com/docs/mcp-server ·
https://postmarkapp.com/pricing · https://aws.amazon.com/ses/pricing/
