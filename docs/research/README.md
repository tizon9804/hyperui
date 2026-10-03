# Research notes (snapshot 2026-10-03)

Source material the hyperui skills are grounded in. Every row carries the URL that was opened
when it was written; anything that could not be opened is marked "(unverified)". Re-check
prices and availability before relying on them — these are snapshots, not live data.

| File | What it holds | Used by |
|---|---|---|
| [providers-and-mcps.md](providers-and-mcps.md) | Hosting, backend/DB/auth, payments (incl. seller-country availability), domains/DNS/email, IaC & containers, docs-on-demand MCPs, mobile/desktop distribution, decision matrix by budget and user level, gotchas | `ship`, `infra`, `build` |
| [engineering-sources.md](engineering-sources.md) | Canonical sources: language style guides, architecture & patterns, testing, security (OWASP Top 10:2025, ASVS 5.0, NIST 800-63B-4, RFC 9700), delivery (Conventional Commits, SemVer, branching models), infra, UX heuristics; official MCP servers | `build`, `review`, `patterns`, `git`, `infra` |
| [munzner-vad.md](munzner-vad.md) | Tamara Munzner's *Visualization Analysis and Design*: what–why–how, nested model, task typology, channel effectiveness, procedure, question→idiom table, references (free ones marked), where popular summaries diverge from the book | `viz` |

How to refresh: re-run the same questions against the official pages listed in each file, bump
the snapshot date in the header, and note what changed in `decisions.md` of the project that
depends on it.
