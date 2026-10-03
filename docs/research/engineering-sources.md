# Engineering canonical sources

Checked 2026-10-03. Every URL was fetched (curl -L, HTTP 200, and the page title matched the expected page). The ones that needed content checks were also read with WebFetch. Where a URL redirects, the table lists the final URL. "(unverified)" means the site blocked automated fetches (403/429), so the page could not be opened.

## 1. Language style / rules

| Topic | Source | URL | Why it's canonical (<=10 words) |
|---|---|---|---|
| Go | Effective Go | https://go.dev/doc/effective_go | Go team's idiomatic-Go guide |
| Go | Go Code Review Comments | https://go.dev/wiki/CodeReviewComments | Official list of common Go review issues |
| Go | Google Go Style Guide | https://google.github.io/styleguide/go/ | Google's guide, decisions, and best practices |
| Python | PEP 8 | https://peps.python.org/pep-0008/ | Official Python style standard |
| Python | PEP 20 (Zen of Python) | https://peps.python.org/pep-0020/ | Python's design principles |
| Python | Google Python Style Guide | https://google.github.io/styleguide/pyguide.html | Widely adopted rules beyond PEP 8 |
| Python | Ruff docs | https://docs.astral.sh/ruff/ | De-facto linter/formatter with rule catalog |
| TypeScript | TS Handbook: Do's and Don'ts | https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html | Official TS team typing guidance |
| TypeScript | Google TypeScript Style Guide | https://google.github.io/styleguide/tsguide.html | Large-scale production TS conventions |
| TypeScript | typescript-eslint | https://typescript-eslint.io/ | Standard TS lint rules and configs |
| JavaScript | Airbnb JS Style Guide | https://github.com/airbnb/javascript | Most-adopted community JS style guide |
| Next.js | App Router docs | https://nextjs.org/docs/app | Official framework docs (v16.x) |
| Next.js | Fetching Data | https://nextjs.org/docs/app/getting-started/fetching-data | Official server/client data-fetching model |
| Next.js | Caching | https://nextjs.org/docs/app/getting-started/caching | Official caching/revalidation semantics |
| Next.js | Production checklist ("Guides: Production") | https://nextjs.org/docs/app/guides/production-checklist | Official pre-launch optimization checklist |
| React | Thinking in React | https://react.dev/learn/thinking-in-react | Official component-design method |
| React | Rules of Hooks | https://react.dev/reference/rules/rules-of-hooks | Official hook invariants |
| Angular | Angular Style Guide | https://angular.dev/style-guide | Official Angular team conventions |
| Swift | Swift API Design Guidelines | https://www.swift.org/documentation/api-design-guidelines/ | Official Swift naming/API rules |
| Swift | SwiftLint | https://github.com/realm/SwiftLint | De-facto Swift linter |
| Dart | Effective Dart | https://dart.dev/effective-dart | Official Dart style/usage/design |
| Flutter | Guide to app architecture | https://docs.flutter.dev/app-architecture/guide | Official Flutter layering (MVVM, repositories) |
| Rust | Rust API Guidelines | https://rust-lang.github.io/api-guidelines/ | Rust library team API checklist |
| Rust | Clippy | https://doc.rust-lang.org/clippy/ | Official Rust lint collection |
| Rust | The Rust Programming Language | https://doc.rust-lang.org/book/ | Official language book |
| Java | Google Java Style Guide | https://google.github.io/styleguide/javaguide.html | Most-cited Java formatting/style standard |
| Java | Effective Java 3rd ed. (Bloch), InformIT | https://www.informit.com/store/effective-java-9780134685991 | Definitive Java best-practices book |
| Java | Spring Boot reference | https://docs.spring.io/spring-boot/index.html | Official Spring Boot docs |
| Kotlin | Kotlin coding conventions | https://kotlinlang.org/docs/coding-conventions.html | Official JetBrains Kotlin style |

## 2. Architecture and patterns

| Topic | Source | URL | Why it's canonical |
|---|---|---|---|
| DDD | Domain Language (Evans) | https://www.domainlanguage.com/ddd/ | Eric Evans' own DDD reference hub |
| DDD | Implementing DDD (Vernon), InformIT | https://www.informit.com/store/implementing-domain-driven-design-9780321834577 | Standard tactical-DDD implementation book |
| DDD | DDD Crew (GitHub) | https://github.com/ddd-crew | Community starter kits: context canvas, EventStorming |
| DDD | Microsoft: Tactical DDD for microservices | https://learn.microsoft.com/en-us/azure/architecture/microservices/model/tactical-domain-driven-design | Aggregates/entities/VOs with worked example |
| CQRS | Fowler bliki: CQRS | https://martinfowler.com/bliki/CQRS.html | Definitive short definition plus caveats |
| CQRS | Azure: CQRS pattern | https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs | When to use it, plus trade-offs |
| Event Sourcing | Azure: Event Sourcing pattern | https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing | Pattern reference with its problems |
| Hexagonal | Cockburn: Hexagonal Architecture | https://alistair.cockburn.us/hexagonal-architecture | Original ports-and-adapters author |
| Clean Arch | Uncle Bob: The Clean Architecture (2012) | https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html | Original dependency-rule post |
| GoF patterns | Refactoring.Guru catalog | https://refactoring.guru/design-patterns | Clear GoF catalog with code per language |
| Singleton | Refactoring.Guru: Singleton | https://refactoring.guru/design-patterns/singleton | Pattern, pros/cons, thread-safety |
| Cloud patterns | Azure Cloud Design Patterns index | https://learn.microsoft.com/en-us/azure/architecture/patterns/ | Vendor-neutral-ish catalog of cloud patterns |
| Circuit Breaker | Fowler bliki | https://martinfowler.com/bliki/CircuitBreaker.html | The canonical description of the pattern |
| Circuit Breaker | Azure: Circuit Breaker | https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker | States, considerations, when not to use |
| Retry | Azure: Retry | https://learn.microsoft.com/en-us/azure/architecture/patterns/retry | Backoff/idempotency guidance |
| Bulkhead | Azure: Bulkhead | https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead | Resource isolation pattern |
| Rate limiting | Azure: Rate Limiting | https://learn.microsoft.com/en-us/azure/architecture/patterns/rate-limiting-pattern | Client-side rate limiting pattern |
| Throttling | Azure: Throttling | https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling | Server-side load control pattern |
| Resilience (JVM) | Resilience4j docs | https://resilience4j.readme.io/docs | Standard JVM CB/retry/bulkhead/ratelimiter library |
| Resilience (.NET) | Polly docs | https://www.pollydocs.org/ | Standard .NET resilience library |
| App design | The Twelve-Factor App | https://12factor.net/ | Canonical cloud-native app principles |
| Well-Architected | Azure Well-Architected Framework | https://learn.microsoft.com/en-us/azure/well-architected/ | Microsoft's five-pillar framework |
| Well-Architected | AWS Well-Architected | https://aws.amazon.com/architecture/well-architected/ | AWS framework home and lenses |
| Well-Architected | AWS: The pillars of the framework | https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html | Six pillar definitions |

## 3. Testing

| Topic | Source | URL | Why it's canonical |
|---|---|---|---|
| TDD | Kent Beck: "Canon TDD" | https://tidyfirst.substack.com/p/canon-tdd | TDD's creator defines the workflow (2023) |
| TDD | TDD by Example (Beck), InformIT | https://www.informit.com/store/test-driven-development-by-example-9780321146533 | The original TDD book |
| TDD | Fowler bliki: TDD | https://martinfowler.com/bliki/TestDrivenDevelopment.html | Short authoritative summary |
| Test strategy | Kent C. Dodds: Testing Trophy | https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications | Origin of the testing-trophy model |
| Test strategy | Fowler: Practical Test Pyramid | https://martinfowler.com/articles/practical-test-pyramid.html | Canonical test-pyramid article |
| Testing practice | Google Testing Blog | https://testing.googleblog.com/ | Google's testing practices ("Testing on the Toilet") |
| E2E | Playwright docs | https://playwright.dev/docs/intro | Official Playwright docs |
| E2E | Playwright best practices | https://playwright.dev/docs/best-practices | Official locator/isolation guidance |
| JS unit | Vitest guide | https://vitest.dev/guide/ | Official Vitest docs |
| JS unit | Jest docs | https://jestjs.io/docs/getting-started | Official Jest docs |
| Python | pytest docs | https://docs.pytest.org/en/stable/ | Official pytest docs |
| Python | pytest good practices | https://docs.pytest.org/en/stable/explanation/goodpractices.html | Official layout/import guidance |
| Go | testing package | https://pkg.go.dev/testing | Official stdlib test API |
| Go | Table-driven tests wiki | https://go.dev/wiki/TableDrivenTests | Official idiom for Go tests |
| Swift | XCTest | https://developer.apple.com/documentation/xctest | Apple's official legacy test framework |
| Swift | Swift Testing | https://developer.apple.com/documentation/testing | Apple's modern macro-based framework |

## 4. Security

| Topic | Source | URL | Why it's canonical |
|---|---|---|---|
| Web risks | OWASP Top 10:2025 (current) | https://top10.owasp.org/2025/ | Latest OWASP Top 10 edition |
| Web risks | OWASP Top 10 (all editions, incl. 2021) | https://top10.owasp.org/ | Official site; old owasp.org/Top10 redirects here |
| Web risks | OWASP Top 10 project page | https://owasp.org/www-project-top-ten/ | OWASP project landing |
| Web risks | OWASP Top 10 repo | https://github.com/OWASP/Top10 | Source of the Top 10 text |
| Verification | OWASP ASVS (v5.0.0 current) | https://owasp.org/www-project-application-security-verification-standard/ | Testable app security requirements standard |
| Verification | ASVS repo, v5.0.0 | https://github.com/OWASP/ASVS/tree/v5.0.0 | Source and downloads for ASVS 5.0 |
| Cheat sheets | OWASP Cheat Sheet Series index | https://cheatsheetseries.owasp.org/ | OWASP's concise defensive guidance |
| SQLi | SQL Injection Prevention CS | https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html | Parameterized queries, the standard defense |
| AuthN | Authentication CS | https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html | OWASP login/authN guidance |
| Passwords | Password Storage CS | https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html | Argon2id/bcrypt hashing parameters |
| Sessions | Session Management CS | https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html | Cookie/session ID lifecycle rules |
| CSRF | CSRF Prevention CS | https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html | Token/SameSite/Fetch-Metadata defenses |
| XSS | XSS Prevention CS | https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html | Output-encoding rules per context |
| MITM / TLS | Transport Layer Security CS | https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html | TLS config, protects against MITM |
| HSTS | HTTP Strict Transport Security CS | https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Strict_Transport_Security_Cheat_Sheet.html | Prevents SSL stripping/downgrade |
| DoS / rate limit | Denial of Service CS | https://cheatsheetseries.owasp.org/cheatsheets/Denial_of_Service_Cheat_Sheet.html | App-level DoS and rate-limit controls |
| Secrets | Secrets Management CS | https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | Storage, rotation, CI/CD secret handling |
| Input | Input Validation CS | https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html | Allowlist validation guidance |
| OAuth | OAuth 2.0 CS | https://cheatsheetseries.owasp.org/cheatsheets/OAuth2_Cheat_Sheet.html | Practical OAuth implementation pitfalls |
| APIs | OWASP API Security Top 10 (2023) | https://api-security.owasp.org/editions/2023/en/0x11-t10/ | Current API-specific risk list (BOLA etc.) |
| LLM apps | OWASP Top 10 for LLM / GenAI | https://genai.owasp.org/llm-top-10/ | Prompt-injection and other LLM-app risks |
| DDoS | Cloudflare Learning: What is a DDoS attack | https://www.cloudflare.com/learning/ddos/what-is-a-ddos-attack/ (unverified: 403 to bots) | Clear vendor primer on DDoS types |
| OAuth | RFC 6749 OAuth 2.0 | https://datatracker.ietf.org/doc/html/rfc6749 | The IETF OAuth 2.0 spec |
| OAuth | RFC 9700 OAuth 2.0 Security BCP | https://datatracker.ietf.org/doc/html/rfc9700 | IETF Best Current Practice (Jan 2025) |
| JWT | RFC 8725 JWT BCP | https://datatracker.ietf.org/doc/html/rfc8725 | IETF JWT safe-usage rules |
| OIDC | OpenID Connect Core 1.0 | https://openid.net/specs/openid-connect-core-1_0.html | The OIDC spec (errata set 2) |
| Passwords | NIST SP 800-63B-4 (HTML) | https://pages.nist.gov/800-63-4/sp800-63b.html | US federal authN guideline, Rev 4 (Aug 2025) |
| Passwords | NIST CSRC: SP 800-63B-4 final | https://csrc.nist.gov/pubs/sp/800/63/b/4/final | Official publication record |
| CSP | MDN: Content Security Policy | https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP | Reference web-platform docs |
| SRI | MDN: Subresource Integrity | https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity | Reference web-platform docs |
| SRI | W3C SRI spec | https://www.w3.org/TR/sri/ | Normative specification |
| Deps | GitHub: Dependabot alerts | https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-alerts | Official Dependabot docs |
| Deps | GitHub: dependabot.yml options reference | https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference | Official config reference |
| Deps | Snyk User Docs | https://docs.snyk.io/ | Official Snyk docs |
| Deps | Trivy | https://trivy.dev/ | Official Aqua Trivy scanner docs |
| Deps | Trivy repo | https://github.com/aquasecurity/trivy | Source and releases |
| Cloud sec | Wiz (site / Academy) | https://www.wiz.io/academy | Vendor site; public educational content |
| Cloud sec | Wiz docs | https://docs.wiz.io/ (unverified: 403/429, login-gated) | Product docs need a customer login |
| Supply chain | SLSA | https://slsa.dev/ | OpenSSF build-provenance framework |
| Supply chain | OpenSSF Scorecard | https://github.com/ossf/scorecard | Automated repo security-posture checks |
| CI security | GitHub Actions secure use | https://docs.github.com/en/actions/reference/security/secure-use | Official Actions hardening guidance |

## 5. Delivery

| Topic | Source | URL | Why it's canonical |
|---|---|---|---|
| Commits | Conventional Commits 1.0.0 | https://www.conventionalcommits.org/en/v1.0.0/ | The commit-message spec |
| Versioning | Semantic Versioning 2.0.0 | https://semver.org/ | The SemVer spec |
| Changelog | Keep a Changelog 1.1.0 | https://keepachangelog.com/en/1.1.0/ | De-facto CHANGELOG format |
| Branching | Git Flow (nvie, 2010) | https://nvie.com/posts/a-successful-git-branching-model/ | Original Git Flow post (with author's 2020 caveat) |
| Branching | GitHub Flow | https://docs.github.com/en/get-started/using-github/github-flow | Official GitHub Flow description |
| Branching | Trunk-Based Development | https://trunkbaseddevelopment.com/ | Canonical TBD reference (Hammant) |
| Review | GitHub: Pull request reviews | https://docs.github.com/en/pull-requests/reference/pull-request-reviews | Official PR review mechanics |
| Review | Google Code Review Developer Guide | https://google.github.io/eng-practices/review/ | Google's reviewer and author guide |
| CI | GitHub Actions docs | https://docs.github.com/en/actions | Official Actions docs |
| Releases | release-please | https://github.com/googleapis/release-please | Google's conventional-commit release PRs |
| Releases | semantic-release | https://semantic-release.gitbook.io/semantic-release | Fully automated SemVer releases |
| Releases | Changesets | https://github.com/changesets/changesets | Monorepo versioning/changelog standard |

## 6. Infra

| Topic | Source | URL | Why it's canonical |
|---|---|---|---|
| Terraform | Terraform docs | https://developer.hashicorp.com/terraform/docs | Official HashiCorp docs |
| Terraform | Terraform style guide | https://developer.hashicorp.com/terraform/language/style | Official HCL conventions |
| Terraform | Terraform MCP Server docs | https://developer.hashicorp.com/terraform/mcp-server | Official MCP: live registry docs/modules/policies |
| Terraform | terraform-mcp-server repo | https://github.com/hashicorp/terraform-mcp-server | Official source (v1.0.x) |
| Terragrunt | Terragrunt docs | https://docs.terragrunt.com/getting-started/quick-start/ | Official docs (moved off gruntwork.io) |
| OpenTofu | OpenTofu docs | https://opentofu.org/docs/ | Official Linux Foundation fork docs |
| ECS/Fargate | Architect for AWS Fargate | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html | Official AWS Fargate docs |
| ECS | ECS best practices | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-best-practices.html | Official guide (old bestpracticesguide redirects here) |
| EKS | EKS Best Practices Guide | https://docs.aws.amazon.com/eks/latest/best-practices/introduction.html | Official AWS EKS guidance |
| Kubernetes | Concepts | https://kubernetes.io/docs/concepts/ | Official K8s docs |
| Kubernetes | Production environment | https://kubernetes.io/docs/setup/production-environment/ | Official production-readiness guidance |
| Kubernetes | Security checklist | https://kubernetes.io/docs/concepts/security/security-checklist/ | Official baseline security checklist |
| Docker | Building best practices | https://docs.docker.com/build/building/best-practices/ | Official Dockerfile guidance |
| CI/CD | AWS CodePipeline user guide | https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html | Official AWS docs |
| IaC | Pulumi docs | https://www.pulumi.com/docs/ | Official Pulumi docs |
| IaC | AWS CDK v2 guide | https://docs.aws.amazon.com/cdk/v2/guide/home.html | Official AWS CDK docs |
| IaC | AWS CDK best practices | https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html | Official CDK design guidance |

## 7. Data / analytics UX

| Topic | Source | URL | Why it's canonical |
|---|---|---|---|
| Usability | NN/g: 10 Usability Heuristics | https://www.nngroup.com/articles/ten-usability-heuristics/ | Nielsen's original heuristics |
| Accessibility | WCAG 2.2 Quick Reference | https://www.w3.org/WAI/WCAG22/quickref/ | W3C official success-criteria reference |
| Design system | Material Design 3 | https://m3.material.io/ | Google's official design system |
| Design system | Apple Human Interface Guidelines | https://developer.apple.com/design/human-interface-guidelines | Apple's official platform UX rules |
| A11y patterns | Inclusive Components (Pickering) | https://inclusive-components.design/ | Accessible component patterns, widely cited |
| Performance | web.dev: Web Vitals | https://web.dev/articles/vitals | Google's Core Web Vitals definitions |
| Performance | Lighthouse performance scoring | https://developer.chrome.com/docs/lighthouse/performance/performance-scoring | Official metric weights and scoring curve |

## Official / first-party MCP servers (all opened and live)

| Area | Server | URL | Notes |
|---|---|---|---|
| GitHub | github-mcp-server | https://github.com/github/github-mcp-server | GitHub's official MCP |
| Terraform | Terraform MCP | https://github.com/hashicorp/terraform-mcp-server | Registry docs, modules, Sentinel policies, HCP workspaces |
| AWS | awslabs/mcp | https://github.com/awslabs/mcp | Includes aws-documentation, aws-iac, ecs, eks, well-architected-security, and others |
| Pulumi | Pulumi MCP | https://www.pulumi.com/docs/ai/mcp-server/ | Remote server https://mcp.ai.pulumi.com/mcp (OAuth) |
| Next.js | next-devtools-mcp | https://nextjs.org/docs/app/guides/mcp | Next 16+ has a built-in /_next/mcp dev endpoint plus version-accurate docs |
| Angular | Angular CLI MCP | https://angular.dev/ai/mcp | `npx @angular/cli mcp`; get_best_practices, search_documentation |
| Dart/Flutter | Dart and Flutter MCP | https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server | `dart mcp-server` |
| Microsoft docs | Microsoft Learn MCP | https://learn.microsoft.com/en-us/training/support/mcp | https://learn.microsoft.com/api/mcp, no auth (covers Azure patterns/WAF) |
| Browser/E2E | Playwright MCP | https://github.com/microsoft/playwright-mcp | Official Microsoft |
| Browser perf | Chrome DevTools MCP | https://github.com/ChromeDevTools/chrome-devtools-mcp | Official; traces/perf insights |
| Kubernetes | kubernetes-mcp-server (Red Hat/containers) | https://github.com/containers/kubernetes-mcp-server | Community-official, not kubernetes.io |
| Docker | Docker MCP Catalog and Toolkit | https://docs.docker.com/ai/mcp-catalog-and-toolkit/ | Official Docker docs |
| Snyk | Snyk Studio (MCP) | https://docs.snyk.io/agent-security/agentic-security-with-snyk-studio/getting-started-with-snyk-studio | Official Snyk agent integration |
