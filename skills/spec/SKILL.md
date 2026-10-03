---
name: spec
description: "Plan a product or change before building: gated PRD → requirements → design → tasks, or a one-file SDD-lite for small changes. Use after a design is picked or when the user asks to plan, scope, break down, or 'how do we build this' (planéalo, cómo lo hacemos, plan it, spec it) — any language. Reads .hyperui/profile.md, writes .hyperui/spec/."
user-invocable: false
---

# hyperui:spec — an executable specification, sized to the job

Turn what the user wants into a spec a person approves and an agent can execute: what it is,
what it must do, how it gets built, in what order. The flow is **gated**: finish a phase,
present it, **wait for explicit approval**, then start the next. Never deliver all phases in
one pass, even when the user is in a hurry. The reason is economic: fixing scope in the PRD
costs minutes; fixing it after the code is written costs days.

## 0. Read memory first — never re-ask what is already known

1. Read `.hyperui/profile.md` (archetype, conversation_language, product_languages, i18n,
   purpose, budget, country, platform, stack, providers), `.hyperui/state.md`, `brief.md`,
   `design.md`, and anything under `.hyperui/spec/`. If a spec for this topic exists, say which
   phase it stopped at and continue there — never overwrite an approved file.
2. Anchor in the repo: `README.md`, `package.json` / `Makefile` / lockfile (real build and test
   commands, framework), folder layout, existing tokens and docs. Every path, type, table or
   route you later write comes from a file you read, or is marked **new**. Never invent one.
3. Derive the **topic slug** from the brief (lowercase, hyphens, no accents, 2–3 words:
   `bakery-landing`, `member-billing`). State it; do not ask for it.
4. Reply in `conversation_language`. The spec files are written in the language the user
   writes in; code, identifiers and commands stay in English.
5. A ticket or doc tool (issue tracker, wiki) is **asked about only if the user mentions one**,
   and then only to paste its link in the spec header. Never assume one exists.

## 1. Pick the track by signals — state it in one line, let the user override

| Signals | Track | Output |
|---|---|---|
| Landing, static or marketing site, portfolio, single-screen app, no backend, no login, no payments | **SDD-lite** | `.hyperui/spec/<topic>.md` — one file, four sections, each ≤ 20 lines |
| Any backend or database, auth, payments, several user roles, external integrations, several services, mobile + web | **Full track** | `.hyperui/spec/<topic>/00-prd.md → 01-requirements.md → 02-design.md → 03-tasks.md`, one approval per file |

Say it like: "This is a landing with no backend → SDD-lite, one file. Say *full* if you want the
four-phase plan." Record the choice in `decisions.md` (section 6). If the user overrides, follow
them and record that instead.

## 2. Voice by archetype

- **non-tech** — plain words; one step per message; **exactly one question per turn, with a
  recommended answer**. Every spec file opens with a `## Glossary` of **≤ 6 terms** actually
  used in it (3-word gloss each). The **language and framework are chosen for them**: one line
  with the pick and why, citing the profile (`purpose`, `budget`, `platform`) and
  `${CLAUDE_PLUGIN_ROOT}/skills/ship/references/providers.md` (open it first; if absent or unreadable,
  say "provider matrix not installed yet" and reason from the profile alone). Never present
  them a choice of frameworks.
- **dev** — the fact plus one line of why; technical vocabulary; ≤ 1 question.
- **senior** — terse, technical, no glosses; they lead. They may **skip a phase explicitly**
  ("skip the PRD", "straight to tasks"): write `N/A — skipped by the user` in that file's
  place and move on. Never skip a phase on your own.

Always: lead with the next step, no preambles, hard cap ~15 lines (non-tech) / ~12 (dev,
senior) per reply unless detail was requested.

## 3. SDD-lite (one file, one gate)

Write `.hyperui/spec/<topic>.md` from `${CLAUDE_PLUGIN_ROOT}/skills/spec/references/sdd-lite-template.md`: **PRD** (problem, the
ONE job, audience, success signal, in/out) · **Requirements** (3–8 EARS lines, each with one
Given-When-Then acceptance) · **Design** (stack chosen, pages/sections, tokens from
`design.md`, product languages/i18n, hosting intent, nothing invented) · **Tasks** (≤ 8,
ordered, each with files, command, binary acceptance). Then present it and ask once:
"Does this match what you want? Anything to add or drop before I build the first task?"
Wait for approval. Revisions go in the same file under `## Revisions`.

## 4. Full track (four files, four gates)

Templates: read `${CLAUDE_PLUGIN_ROOT}/skills/spec/references/<name>.md`; if that read is denied, the
section lists below are the contract — do not stop. Each phase: write the file → self-review against its checklist →
present it → ask the gate question → **wait for explicit approval**. On feedback, fix the same
file, append a one-line entry to its `## Revisions`, present again. If feedback invalidates an
approved earlier file, say so and update that file too.

### Phase 1 — PRD (`00-prd.md`, `references/prd-template.md`)
Starting points: (a) the user has a written brief, ticket or page → summarize it, quote its
acceptance criteria **verbatim**, list what it does not answer; (b) nothing exists → ask at most
the missing of: what problem, for whom, how we know it worked, what stays out, constraints
(one question per turn for non-tech; batch ≤ 3 for others) and write it; (c) a small technical
change → `N/A — reason` and move on. A PRD is a **product** document: what and why, no tables,
endpoints or packages. No success signal → state it as an explicit risk.
Gate: "This is the starting point. Is this what needs to be built? Anything to fix before I
break it into requirements?"

### Phase 2 — Requirements (`01-requirements.md`, `references/requirements-template.md`)
Break the PRD into behavior, do not reinvent it. Ask only what is missing (data stored? who
logs in? money moves? personal data? offline? languages?). Use **EARS** (Easy Approach to
Requirements Syntax — explain it in one line the first time): `WHEN <trigger> THE SYSTEM SHALL
<observable outcome>`; `WHILE <state>` for modes, `IF <unwanted> THEN` for failures. Each REQ =
one behavior, acceptance as **Given / When / Then** scenarios, binary, plus the real build and
test commands. Traceability table UC → REQ; a use case with no REQ is scope being cut — say so.
Self-review: every UC covered · WHEN names a specific event · no "works correctly" · paths exist
or are **new** · open questions are only decisions that block design.
Gate, with a size signal so scope can still be corrected cheaply: "Requirements draft. It
looks like a [single-screen / multi-page / backend + UI / multi-service] change. Does it capture
what you want? Anything to adjust before design?"

### Phase 3 — Design (`02-design.md`, `references/design-template.md`)
First classify the change (single screen · multi-page · backend + UI · multi-service · new
platform; traits: state lifecycle, multi-table) and **propose** the diagram set (Mermaid:
sequence always — happy path + most likely failure; flowchart for branching; stateDiagram for
lifecycles; erDiagram for several tables; C4/flowchart for several services). One confirmation,
then write. The design names: stack and framework with the why (non-tech: chosen for them,
cited as in section 2), affected components with real paths, data model with a **column-level
table** for every table created or changed, API contract if any, auth and personal-data
handling resolved explicitly, product languages/i18n, errors, config and secrets
(`.env.example`, never `.env`), test strategy, observability, docs to update, open questions,
REQ → decision traceability. Trade-offs as **ADR-lite** lines (context · decision · consequence)
that also go to `decisions.md`. A new dependency is flagged, never installed here.
Gate: "This is the design. Does the approach hold? Any concerns before I split it into tasks?"

### Phase 4 — Tasks (`03-tasks.md`, `references/tasks-template.md`)
Atomic tasks grouped in **waves** by dependency; each: files (real paths), exact commands,
binary acceptance including build and tests green, the tests written first (happy, error, edge),
depends-on. Mandatory tasks wherever the design requires them: migration, registration/wiring,
i18n strings, docs, tests. No task over one day — split it. The waves tell a parallel executor
what can run together.
Gate: "This is the plan. Does the breakdown look right? Anything to add, split or reorder?"
After approval, hand off: one line proposing the first task (`build` runs it).

## 5. Bug variant
Phase 2 becomes `01-bug-analysis.md`: reported vs expected behavior, what must not change,
repro steps, affected files with line refs, root cause stated with caution ("probably"),
regression risk, minimal fix. Then design and tasks focused on the fix (usually 1–3 tasks).

## 6. Writing style and memory writes

- Plain language, short sentences; no "leverage / robust / seamless". Concrete names from the
  repo over "the system". Every diagram gets a 1–2 sentence caption. Cite ids with their gloss:
  `REQ-002 (checkout form validation)`, never bare. A section that does not apply says
  `N/A — reason`.
- After every gate: `.hyperui/state.md` → `phase: spec`, `next:` the next phase or first task,
  `open:` the open questions, `last_updated`. Track and spec path recorded there too.
- `.hyperui/decisions.md`, one line each: `YYYY-MM-DD · track = SDD-lite · landing, no backend ·
  spec/<topic>.md`; the same format for stack, framework, data and auth decisions, with the
  source URL when one was opened.
- Safety: stop and ask before anything with external effect (creating tickets in the user's
  tool, buying, deploying, deleting data). The spec itself has none.

## Sources
- EARS — Alistair Mavin, *Easy Approach to Requirements Syntax*: https://alistairmavin.com/ears/
- Given / When / Then — Gherkin reference (Cucumber): https://cucumber.io/docs/gherkin/reference/
- Given When Then — Martin Fowler (bliki, credits North & Matts): https://martinfowler.com/bliki/GivenWhenThen.html
- ADR — Michael Nygard, *Documenting Architecture Decisions*: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
