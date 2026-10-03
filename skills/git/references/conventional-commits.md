# Conventional Commits (1.0.0) — how hyperui writes commit messages

Source: https://www.conventionalcommits.org/en/v1.0.0/

## Shape

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

- **Subject line**: ≤ 72 characters, imperative mood ("add", not "added"/"adds"), lowercase
  first word after the colon, no trailing period.
- **Scope**: a noun for the area touched, in parentheses: `feat(auth): …`, `fix(cart): …`.
  Optional; use the repo's existing scopes if it has them.
- **Body**: blank line after the subject, wrapped at 72. Explain *why* and any non-obvious
  consequence; the diff already shows *how*.
- **Footers**: `Token: value` lines after a blank line — `BREAKING CHANGE: …`, `Refs: <id>`
  (only when the user has a tracker and gives the id), `Reviewed-by: …`. No AI co-author
  trailer unless the user asks for one.

## Types

| Type | Use for | SemVer effect |
|---|---|---|
| `feat` | a new capability for the user/API | MINOR |
| `fix` | a bug fix | PATCH |
| `perf` | faster/lighter, same behavior | PATCH |
| `refactor` | restructure, no behavior change | none |
| `docs` | documentation only | none |
| `style` | formatting, whitespace, no logic | none |
| `test` | add or fix tests only | none |
| `build` | build system, dependencies, packaging | none (PATCH if shipped deps change) |
| `ci` | CI configuration | none |
| `chore` | maintenance that fits nothing above (incl. `chore(release)`) | none |
| `revert` | reverts a previous commit; body: `This reverts commit <sha>.` | depends on what is reverted |

Only `feat` and `fix` are defined by the spec; the rest are the widely used
`@commitlint/config-conventional` set. If the repo has a `commitlint` config, it wins.

## Breaking changes

Either `!` before the colon or a `BREAKING CHANGE:` footer (or both). Any type can be
breaking. Breaking → MAJOR (or MINOR while the project is `0.y.z`).

```
feat(api)!: drop the v1 orders endpoint

BREAKING CHANGE: clients must call /v2/orders; /v1/orders now returns 410.
```

## Choosing the type — quick checks

- The user/caller can do something new → `feat`.
- Something that should have worked now works → `fix`.
- Nobody outside the code can tell the difference → `refactor` / `style` / `test` / `chore`.
- Mixed `feat` + unrelated `fix` in one diff → propose two commits.

## Examples

```
feat(checkout): add coupon code field
fix(login): redirect to the original page after sign-in
docs: explain local setup with Docker
refactor(cart): extract price calculation into a pure function
chore(deps): bump next from 15.1.0 to 15.1.3
revert: feat(checkout): add coupon code field
```

Bad → good:

- `Updated stuff` → `fix(header): keep the menu open on mobile tap`
- `feat: Added new button.` → `feat(profile): add delete-account button`
- `[ABC-123] fix login` → `fix(login): handle expired session token` + footer `Refs: ABC-123`
