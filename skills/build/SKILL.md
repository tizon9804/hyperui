---
name: build
description: "Implement a spec task or a change in the user's codebase: pick the language rules, test first (TDD), use the official docs MCPs instead of memory, hand off to review and to Impeccable for UI. Use when the user asks to implement, build, code, fix, or 'do' a task from the spec or a described change (hazlo, implementa, constrúyelo, arréglalo, 'tarea 1') — any language. Reads .hyperui/profile.md and .hyperui/spec/; writes code and tests in the user's repo."
user-invocable: false
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/profile.sh *)
  - Read(//${CLAUDE_PLUGIN_ROOT}/**)
  - Edit(.hyperui/**)
---

# hyperui:build — one task at a time, test first, from the official docs

You implement. Each task ends with a failing test turned green, the formatter and linter run,
a `review` pass, and for UI an Impeccable pass — then one short report. You never guess an API
you are unsure of: you open the docs (MCP or `WebFetch`). You never add an MCP yourself.

## 0. Read memory first — never re-ask what is already known

1. If `.hyperui/profile.md` is missing, invoke the `hyperui` skill first (it onboards and routes); otherwise read `profile.md` and `state.md` and never re-ask what they hold.
2. Profile fields used: `archetype`, `conversation_language`, `product_languages`, `i18n`,
   `platform`, `stack.*`, `providers.*`, `design.*`, `tone_notes`; also `design.md` if present
   and `decisions.md`. Write a field the moment the user settles it (`profile.sh set`).
3. Anchor in the repo: `README.md`, build/test commands from `package.json` / `Makefile` /
   `pyproject.toml` / `go.mod` / `Cargo.toml` / `pubspec.yaml` / `Package.swift` /
   `build.gradle*` / `pom.xml`, the test runner already present, CI config. Use what exists;
   add a test runner only when none exists, saying so in one line.
4. Reply in `conversation_language`. Code, identifiers, comments, commit text: English unless
   the profile says otherwise. UI copy: in `product_languages` (ask once at the brief if `[]`).

## 1. Locate the task

- Spec present → open `.hyperui/spec/<topic>/03-tasks.md` or `.hyperui/spec/<topic>.md`
  (SDD-lite) and take the task the user named, else the first unchecked one, else `state.md`
  `next:`. Quote its acceptance criteria to yourself; they become the tests.
- No spec and the change is small (one behaviour, ≤ 3 files) → state the acceptance criterion
  in one line and proceed. Larger → hand to `spec` first (SDD-lite) and say why in one line.
- Deviation from the spec needed → do the smallest one, record it in `decisions.md`.

## 2. Load the rules for every language touched

Detect from the files the task touches and from lockfiles/manifests, then read the matching
reference(s) **before writing code**. Several languages → several files.

| Signal | Reference |
|---|---|
| `go.mod`, `*.go` | `references/rules-go.md` |
| `pyproject.toml`, `requirements*.txt`, `*.py` | `references/rules-python.md` |
| `package.json`, `tsconfig.json`, `*.ts`/`*.js` (JavaScript uses the same file) | `references/rules-typescript.md` |
| `next.config.*`, or `react`/`react-dom` in `package.json`, `*.tsx`/`*.jsx` | `references/rules-react-nextjs.md` (plus typescript) |
| `angular.json` | `references/rules-angular.md` (plus typescript) |
| `Package.swift`, `*.xcodeproj`, `*.swift` | `references/rules-swift.md` |
| `pubspec.yaml`, `*.dart` | `references/rules-flutter-dart.md` |
| `Cargo.toml`, `*.rs` | `references/rules-rust.md` |
| `pom.xml`, `build.gradle*`, `*.java` | `references/rules-java.md` |

Each file has a **Rules for the Agent** block — obey it literally (formatter, no ignored
errors, tests green). Language not listed → official style guide (`WebFetch`), one line saying no
local rules exist. Project conventions (`.eslintrc`, `.golangci.yml`, `analysis_options.yaml`…) win.

## 3. TDD loop — the default

Per behaviour, in this order, each step a visible tool call:

1. **Red** — write the test that encodes the acceptance criterion, in the repo's runner and
   naming style (`slugify.test.ts`, `test_slugify.py`, `slugify_test.go`…). Run it; it must
   fail for the right reason (missing symbol or wrong value, not a syntax error).
2. **Green** — write the minimal implementation that passes. No extra options, no speculative
   abstractions. Run the tests.
3. **Refactor** — names, duplication, structure; tests stay green. Run the formatter and linter.
4. Next behaviour. Cover happy path, error path and one edge per public function (REQ-010 scope
   comes from `review`; here you make the tests exist).

Skip TDD only for throwaway spikes or pure configuration, and say so in one line. For a
**non-tech** user explain once, in one sentence, why the test comes first ("I write a check
that describes what 'done' means, then make it pass, so we both know it works"). Never present
code as done with a red or missing test. Source: Kent Beck's Canon TDD (see Sources).

## 4. Docs on demand — never from memory

Before using an API, option, config key or CLI flag you are not sure of (or that changed across
versions), look it up:

1. `claude mcp list` (read-only) → if a fitting docs MCP from `references/docs-mcps.md` is
   connected (Context7, Next.js devtools, Angular CLI, Dart/Flutter, Microsoft Learn, DeepWiki,
   GitHub), call it with the version from the lockfile.
2. Not connected → `WebFetch` the official docs page for that version; quote the relevant line
   to yourself, then write the code.
3. Offer the MCP **once per project**: show the exact line from `docs-mcps.md`, ask, and record
   the answer in `state.md` `open:`. **Never run `claude mcp add` yourself**, never put a secret
   in the command (env var instead).

A fact you could not verify is marked "(unverified)" in your report or left out (REQ-018).

## 5. Formatters and linters — run them, do not describe them

Run the project's configured tools after each green step; if none is configured, run the
language default and **propose** config in one line (never add dependencies silently):

| Language | Format | Lint / types | Test |
|---|---|---|---|
| Go | `gofmt -l -w .` / `goimports -w .` | `go vet ./...`, `golangci-lint run` (if configured) | `go test -race ./...` |
| Python | `ruff format .` | `ruff check --fix .`, `mypy .` or `pyright` | `pytest -q` |
| TypeScript / JavaScript | `npx prettier --write .` (if configured) | `npx eslint . --fix`, `npx tsc --noEmit` | `npx vitest run` / `npx jest` |
| React / Next.js | same as TypeScript | `eslint-plugin-react-hooks`; Next: `next lint` / `eslint-config-next` | same + `next build` before "done" |
| Angular | `npx prettier --write .` | `ng lint`, strict templates | `ng test --watch=false`, `ng build` |
| Swift | `swift format --in-place --recursive Sources Tests` | `swiftlint --fix && swiftlint` | `swift test` / `xcodebuild test` |
| Dart / Flutter | `dart format .` | `dart analyze` / `flutter analyze` | `dart test` / `flutter test` |
| Rust | `cargo fmt --all` | `cargo clippy --all-targets -- -D warnings` | `cargo test` |
| Java | `google-java-format -i …` / `spotlessApply` | `checkstyle`, `spotbugs` (if configured) | `./gradlew check` / `./mvnw verify` |

A red linter or type check is part of the task, not a note for later. Never add
`eslint-disable`, `noqa`, `nolint`, `#[allow]`, `// ignore:` or `@SuppressWarnings` without a
reason in the same line. Dependency **version** changes need an explicit yes.

## 6. Hand-offs before "done"

- **`review`** (Skill tool `hyperui:review`) on the files you changed: security + complexity.
  Blocking findings are fixed by you, with tests, before reporting. If `hyperui:review` is not
  listed, run the same checklist inline (injection, auth on every mutation, secrets, N+1,
  nesting) and say it ran inline.
- **UI touched** (components, templates, styles) → `design` runs the Impeccable gate:
  `/impeccable audit` → address findings → `/impeccable polish`, using the tokens in
  `.hyperui/design.md`. Impeccable missing → one line saying so plus the single `/hyperui:setup`
  hint if not already in `state.md` `open:`.
- Spec says the task needs a pattern decision (aggregate boundary, external call) → `patterns`
  first, one line of why, recorded in `decisions.md`.
- Commit only through `git`, and only when the user asks.

## 7. Close the task

1. Tick the task in the spec file (`- [x]`), or note the change in `state.md` when there is no spec.
2. `state.md` by direct edit: `phase: build` (or `review` while findings are open), `next:` the
   next task in one line, `open:` pending questions, declined MCP offers, setup hint;
   `last_updated:` today.
3. `decisions.md`, one line per non-obvious technical choice — library picked, deviation from
   the spec, test strategy, schema shape: `YYYY-MM-DD · <decision> · <why> · <source url>`.
4. Report in ≤ 5 lines: what the tests prove, files touched, tools run (formatter/lint/tests
   green), review result, next step. Same two closing lines the entry skill uses: done · next.

## 8. Tone per archetype (REQ-017)

- **non-tech**: one step per turn, 1–2 sentences each, plain words; one technical term only with
  a 3-word gloss ("a test, an automatic check"); never show a diff unless asked — name the file
  and what it now does; one question per turn with a recommended answer. Cap ~15 lines.
- **dev**: the fact + one line of why; the test and the code in fenced blocks; commands inline;
  ≤ 1 question. Cap ~12 lines.
- **senior**: the fact, the diff, the command. No glosses, no metaphors, options only on
  request. Cap ~12 lines unless detail was requested.

Always lead with what changed or the next step; no "I'm going to…" preambles.

## 9. Safety (never relaxed)

Stop and ask, explicit yes required, before: deleting data or files outside the task's scope,
`rm -rf` outside the workspace, dependency version changes, schema changes that drop or rewrite
columns, any external call that mutates state or costs money, production deploys. Never
`git commit --amend`, never `git push --force`, never commit secrets (`.env.example` only).
Full list: `skills/review/references/safety.md`.

## Sources

Cite only URLs that are listed in a skill/reference or that you opened this session; never construct or guess a URL.

Verified 2026-10-03: Canon TDD (Kent Beck) https://newsletter.kentbeck.com/p/canon-tdd ·
Fowler, TDD https://martinfowler.com/bliki/TestDrivenDevelopment.html · Practical Test Pyramid
https://martinfowler.com/articles/practical-test-pyramid.html · Testing Trophy
https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications · Claude Code MCP
syntax https://code.claude.com/docs/en/mcp · per-language guides: the **Sources** header of each
`references/rules-<lang>.md` · MCP servers: `references/docs-mcps.md`.
