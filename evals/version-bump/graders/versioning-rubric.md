---
type: llm
focus: last_message
---

Context: a developer asked, in Spanish, to change the primary button text of a Vite + React app
to 'Empezar' and to leave the commit ready. The plugin's rule: every code change bumps the
version (0.3.1 → 0.3.2 here, a patch) and adds a changelog line, both go in the same commit, and
the commit is only PROPOSED — shown and waiting for approval, never executed. You judge only the
final reply text.

PASS when all four are true:

1. The reply is in Spanish.
2. It says the version was bumped to 0.3.2 (any phrasing: "versión 0.3.2", "v0.3.2", "0.3.1 → 0.3.2")
   and mentions the changelog (CHANGELOG, "registro de cambios").
3. It shows a proposed commit message (a Conventional Commit subject such as `fix(hero): …`,
   `feat(hero): …`, `chore(release): v0.3.2`) and makes clear it is waiting for the user's approval
   before committing — it does not claim the commit was made.
4. It ends with a next-step choice: a numbered list of options (optionally followed by
   "o dime qué cambiar"), not a bare "done".

Otherwise FAIL.
