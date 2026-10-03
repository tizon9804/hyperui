# Security checklist

OWASP Top 10:2025 (https://top10.owasp.org/2025/): per category, what to check, then the cheat
sheet with the fix (open it before quoting a parameter; index https://cheatsheetseries.owasp.org/).
Auth, payments or personal data → go deeper with ASVS 5.0, the matching chapter:
https://owasp.org/www-project-application-security-verification-standard/

## A01:2025 Broken Access Control
- Every endpoint checks *who* the caller is **and** that the resource belongs to them
  (`GET /orders/:id` filters by the session's user id, not only by `id`).
- Deny by default: new routes, server actions and API handlers require auth unless public on purpose.
- No authorization decided in the client only (hidden buttons are not access control).
- SSRF (folded into A01 in 2025): URLs fetched server-side from user input go through an allowlist.
- https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html

## A02:2025 Security Misconfiguration
- No debug mode, verbose errors or default credentials in production config; no open buckets.
- CORS is an explicit origin list, never `*` with credentials.
- Security headers set: CSP, HSTS, `X-Content-Type-Options: nosniff`, frame-ancestors.
- https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html

## A03:2025 Software Supply Chain Failures
- A new dependency is justified, from the official registry (typosquat check), lockfile committed.
- Dependency scanning is on (Dependabot alerts, Trivy or the host's scanner); CI actions are
  pinned to a full commit SHA, workflow tokens least-privilege.
- https://cheatsheetseries.owasp.org/cheatsheets/Software_Supply_Chain_Security_Cheat_Sheet.html

## A04:2025 Cryptographic Failures
- TLS everywhere; no secrets or personal data over plain HTTP; HSTS on (see below).
- No MD5/SHA-1 for anything security-relevant, no fixed IVs, no homegrown crypto; random
  values for tokens come from a CSPRNG (`crypto.randomBytes`, `secrets`), never `Math.random`.
- Passwords hashed with Argon2id (min 19 MiB, t=2, p=1), scrypt, or bcrypt cost ≥ 10.
- https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html

## A05:2025 Injection
- **SQL built by concatenating or interpolating input is blocking.** Fix: prepared statements
  / parameterized queries (or the ORM's bound parameters). Table or column names from input go
  through an allowlist map — bind variables cannot cover identifiers. Escaping is the weakest
  defense; do not propose it as the fix.
- Shell commands: no string-built commands; pass an argument array, no `shell: true`.
- XSS: output encoded per context; no `innerHTML` / `dangerouslySetInnerHTML` / `v-html` with
  untrusted data unless sanitized (DOMPurify). No `eval`, `new Function`, template injection.
- https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html

## A06:2025 Insecure Design
- Money or stock changes run in a transaction or with optimistic locking; idempotency keys on
  payment and webhook handlers; webhook signatures verified.
- Business limits enforced on the server (coupon reuse, free-tier caps, invite counts).
- https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html

## A07:2025 Authentication Failures
- Prefer a maintained auth provider/library over hand-rolled login.
- Rate limiting / lockout on login, password reset, OTP and email-sending endpoints.
- Session cookies `HttpOnly`, `Secure`, `SameSite=Lax|Strict`; session id rotated at login;
  server-side invalidation on logout; CSRF defense on cookie-authenticated state changes.
- Passwords per NIST SP 800-63B-4 (next section). Generic login errors ("invalid credentials").
- https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html

## A08:2025 Software or Data Integrity Failures
- No deserialization of untrusted data into objects (`pickle`, Java native, YAML full load).
- Third-party scripts from a CDN carry Subresource Integrity (`integrity` + `crossorigin`).
- https://cheatsheetseries.owasp.org/cheatsheets/Deserialization_Cheat_Sheet.html

## A09:2025 Security Logging and Alerting Failures
- Login failures, access denials, admin actions logged (who/what/when); logs never contain passwords, tokens, card data or full personal data.
- Someone is alerted on spikes (failed logins, 5xx); a log nobody reads is not detection.
- https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

## A10:2025 Mishandling of Exceptional Conditions
- Client errors are generic; stack traces and SQL errors go to the internal log only.
- Fail closed: an exception in an auth/permission check denies, never allows.
- Every external call has a timeout; partial failures roll back (no half-written state).
- https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html

## Cross-cutting checks
- **APIs — OWASP API Top 10 2023** (https://api-security.owasp.org/editions/2023/en/0x11-t10/):
  BOLA (API1) = A01 per object; API3: no mass-assignment of the body, return only allowed
  fields; API4: pagination caps, body size limits; API10: validate third-party API responses.
- **Input validation:** every external input (body, query, headers, webhooks, queue messages)
  validated server-side with an allowlist schema (zod, pydantic…). https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html
- **Secrets in the repo:** no keys, tokens or connection strings in code, tests, fixtures or
  client bundles (`NEXT_PUBLIC_*`, `VITE_*` are public). `.env` ignored, `.env.example`
  committed. A secret already in history must be **rotated** — deleting it is not enough.
  Scanner: gitleaks (https://github.com/gitleaks/gitleaks). https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- **TLS / HSTS / MITM:** HTTPS only, HTTP redirects to HTTPS; `Strict-Transport-Security:
  max-age=63072000; includeSubDomains; preload` once stable (start with a short max-age;
  preload is hard to undo). No disabled certificate verification (`rejectUnauthorized: false`,
  `verify=False`).
  https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html ·
  https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Strict_Transport_Security_Cheat_Sheet.html
- **DoS / rate limiting:** per-IP and per-account limits on auth, signup, search and expensive
  endpoints; body size caps; timeouts; no catastrophic-backtracking regex on input. https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html
- **Passwords — NIST SP 800-63B-4** (https://pages.nist.gov/800-63-4/sp800-63b.html): minimum
  **15 characters** when the password is the only factor, **8** when part of MFA; allow at
  least 64; **no composition rules**; **no forced periodic rotation** (only on evidence of
  compromise); check against a blocklist of common/breached passwords; allow paste and
  password managers.
- **OAuth — RFC 9700** (https://datatracker.ietf.org/doc/html/rfc9700): authorization code +
  PKCE; no implicit grant; never the resource-owner password grant; exact redirect-URI match;
  `state`/PKCE against CSRF; refresh tokens for public clients rotated or sender-constrained.
  https://cheatsheetseries.owasp.org/cheatsheets/OAuth2_Cheat_Sheet.html
- **JWT — RFC 8725** (https://datatracker.ietf.org/doc/html/rfc8725): verify with an explicit
  algorithm allowlist, reject `alg: none`; validate `iss`, `aud`, `exp`; one key per
  algorithm; no human password as an HMAC key; distinct `typ` per token kind.
- **CSP / SRI:** script CSP without `unsafe-inline`/`unsafe-eval` (nonces or hashes); SRI on CDN
  scripts. https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP ·
  https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity
- **Dependency scanning and provenance:** Dependabot alerts
  (https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-alerts),
  Trivy (https://trivy.dev/), SLSA (https://slsa.dev/), OpenSSF Scorecard
  (https://github.com/ossf/scorecard), Actions hardening
  (https://docs.github.com/en/actions/reference/security/secure-use).
- **LLM features:** model output is untrusted input; prompt injection: https://genai.owasp.org/llm-top-10/
