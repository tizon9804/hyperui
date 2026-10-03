---
hyperui: 1                       # schema version
archetype: "non-tech"            # non-tech | dev | senior
conversation_language: "es"      # BCP-47 primary tag of how the user writes (es, en, …)
product_languages: [es]          # asked at the brief; [] until asked
i18n: false                      # several locales / default locale / RTL needs
purpose: "business"              # personal | business
budget: "$0"                     # $0 | <20 | <100 | startup — only when purpose = business
country: "CO"                    # seller/operator country (ISO 3166-1 alpha-2) — drives payments and signing advice
platform: "web"                  # web | mobile | macos | windows | multi
stack:                           # inferred from the repo first, asked only if nothing exists
  framework: "astro"             # nextjs | angular | react | flutter | swiftui | tauri | …
  language: "typescript"         # typescript | …
  styling: "css"                 # css-modules | tailwind | …
providers:
  host: ""                       # cloudflare-workers | vercel | amplify | firebase | …
  db: ""                         # neon | supabase | …
  auth: ""                       # supabase | clerk | better-auth | …
  payments: ""                   # paddle | polar | creem | mercadopago | paypal | stripe | none
  domain: ""                     # cloudflare | porkbun | route53 | none
design:
  direction: ""                  # e.g. "Luminous Soft-Tech"
  fonts: { display: "", body: "" }
  palette: { bg: "", accent: "" }
  motion: ""                     # restrained | expressive
tone_notes: ""                   # e.g. "terse; technical terms; no metaphors"
private: false                   # true after `profile.sh private` (.hyperui/ added to .gitignore)
---
<!-- Free notes the model may append below (one line each, dated). -->
