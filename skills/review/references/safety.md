# Safety rules for risky actions

Applies to every hyperui step, not only review. **Golden rule:** when in any doubt whether an
action is destructive, irreversible, or has an effect outside this machine, **stop and ask**.
One extra confirmation is cheaper than one piece of lost data.

## 1. Data — never without an explicit yes

- `DROP DATABASE` / `DROP TABLE` / `DROP SCHEMA`, `TRUNCATE`.
- `DELETE` or `UPDATE` without a `WHERE`, or with a `WHERE` that hits rows en masse.
- Schema-tool reset or repair commands outside a throwaway local DB (`migrate reset`,
  `migrate:fresh`, `db:wipe`, `db push --force-reset`, a migration tool's `clean`/`repair`).
- Migrations that drop columns or tables in shared or production environments; editing a
  migration already applied anywhere shared.
- Deleting cloud resources: buckets/objects, queues, topics, databases, any infra resource.
- Restoring or overwriting backups.
- **Never operate directly on a production database**; that goes through the user's own process.

## 2. Filesystem and git

- No `rm -rf` or recursive deletion outside the project workspace without confirmation.
- No `git push --force` / `--force-with-lease` to a shared branch, `main` above all.
- No `git reset --hard`, `git clean -fd`, or history rewriting (`rebase`, `filter-branch`,
  `filter-repo`) that discards work, without confirming.
- No deleting remote branches unless asked.
- No `--no-verify`; never skip pre-commit / pre-push hooks.
- **No `git commit --amend`, ever** — not even unpushed. Every change is a new commit
  (`--fixup` only when the user explicitly asks to squash).
- Work on a branch; never commit directly to `main` when the repo uses branches.

## 3. Secrets and sensitive data

- Never commit `.env`, keys, tokens, credentials or certificates; check the diff before every
  commit. hyperui writes `.env.example`, never `.env`.
- Never hardcode secrets (use env vars or a secrets manager); never log passwords, tokens, personal data or card data.
- Never paste secrets or production data into prompts, issues, PRs or external services.
- Never download production dumps to a local machine.
- A secret found already committed → tell the user it must be **rotated**; deleting it from
  the latest commit is not enough.

## 4. Effects outside this machine — confirm each one

- **Purchases** of any kind: domains, plan upgrades, paid add-ons, credits.
- Deploying to production or triggering pipelines; approving environment/deployment gates.
- Creating, merging or closing pull requests; publishing packages, images or releases.
- Sending messages, creating or editing tickets, commenting on other people's PRs.
- Installing or updating dependencies, changing library versions.
- Calling external APIs that mutate state or cost money.
- Adding an MCP server or changing tool permissions (show the exact command; the user runs it).

An approval covers that one action. It does **not** extend to the next one.

## 5. Infrastructure and permissions

- Least privilege: credentials used have the minimum scope; the app's DB user has no DDL
  rights in production.
- No changes to IAM, security groups, DNS or production environment variables without review.
- Never disable security controls (validation, authentication, rate limits, TLS verification)
  "just to make it work".

## 6. Honesty of the change

- Do not introduce known vulnerabilities (injection, XSS, secrets in the client, open CORS).
- Report results faithfully: a failing test is reported with its real output; never claim
  something was verified if it was not run.
- Before deleting or overwriting something hyperui did not create, inspect it; if it
  contradicts what was expected, flag it instead of proceeding.
- No changes outside the requested scope.

## 7. When an action is risky

1. **Stop** before executing.
2. **Explain** in one or two lines what it does and what would be lost; is it reversible?
3. **Propose** a safer alternative when one exists (dry run, backup first, narrower `WHERE`,
   a staging environment).
4. **Wait for an explicit yes.** Irreversible actions are confirmed even when the request
   already sounded like an order.

Quick check: reversible (else, is there a backup)? Touches production or shared data? Touches
secrets or personal data? Has an external effect or a cost? Explicitly approved? Any flag → ask.
