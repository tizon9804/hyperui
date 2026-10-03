# Pull request template

Use the repo's own template when it exists (`.github/pull_request_template.md`,
`docs/pull_request_template.md`, root `pull_request_template.md`, or
`.github/PULL_REQUEST_TEMPLATE/`). Otherwise use this one. To add it to the user's repo, save it
as `.github/pull_request_template.md` (ask first — it is a new file in their repo).

Source for template locations:
https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository

**Title** (GitHub title field, not in the body): Conventional Commit style, ≤ 72 chars —
`feat(cart): add coupon field`. No ticket prefix.

```markdown
## What and why

What this change does and the problem it solves, in two to five lines.
Link the issue only if there is one (e.g. "Closes #42").

## How it was tested

- [ ] Unit tests: base case, error/validation case, edge cases
- [ ] Ran it locally: <command or steps>
- Steps for a reviewer to try it:
  1. …
  2. …

## Screenshots (UI changes only)

| Before | After |
|---|---|
| … | … |

## Checklist

- [ ] No secrets, keys or `.env` files in the diff
- [ ] No unconfirmed destructive changes (data, schema, infra)
- [ ] Docs / README updated if setup or behavior changed
- [ ] CHANGELOG `Unreleased` updated if the project keeps one
```

Filling rules:

- Delete the Screenshots section when no UI changed; never leave an empty table.
- "How it was tested" lists what was actually run — do not tick boxes that were not done.
- For a PR that is part of a series, add a short "Series" line: `1/3 → schema; 2/3 → API (this);
  3/3 → UI`, and say whether it touches a hot path (code that runs on every request).
- If behavior ships behind a feature flag, say what applies on deploy regardless of the flag
  (migrations, config, scheduled jobs).
