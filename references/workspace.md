# Several repos from one directory (workspace mode)

Read this when `profile.sh roots` prints more than one path. Nothing here applies to the
single-root case.

## Model

- The mapping for the current directory is a **list of roots**; the first is the **primary**.
  `profile.sh root` prints the primary, `roots` prints all, `root-set <a> <b>` appends,
  `root-set --replace <a> <b>` resets the list, `root-set .` forgets it.
- **Each repo keeps its own `.hyperui/`** (profile, brief, design, spec, decisions, state,
  ship): `profile.sh --repo <that root> init|get|set` targets it. Nothing product-specific is
  shared by copying; the shared decisions are written once, in the workspace file, and each
  repo's `decisions.md` links to it in one line.
- **`<primary>/.hyperui/workspace.md`** is the only cross-repo file. Create it with the Edit tool
  the first time a second root appears (allowed without a prompt under any root's `.hyperui/`):

  ```markdown
  # Workspace

  | Root | Role | Stack |
  |---|---|---|
  | /abs/path/web | web | nextjs · typescript · tailwind |
  | /abs/path/mobile | mobile | expo · react-native |

  shared: design tokens, auth provider        # what is decided once for all repos
  next: <one line — the cross-repo next step>
  last_updated: YYYY-MM-DD
  ```

  Roles are one word the user would use: `web`, `mobile`, `api`, `admin`, `docs`, `shared`.
  Infer them from the manifest (`next`/`astro` → web, `expo`/`react-native`/`pubspec.yaml` →
  mobile, `fastapi`/`gin`/`spring` → api); ask only when two repos would get the same role.

## Routing

1. **The request names a repo** (its path, folder name, or role word: "en la web", "the mobile
   app", "el api") → run the specialist on that root only; pass the root in the Skill `args`
   (`root=/abs/path`), and the specialist reads that repo's `.hyperui/`.
2. **Ambiguous and more than one root** → exactly ONE question: "which one: web or mobile?".
   Never list paths; use the roles.
3. **Cross-cutting** (shared identity, same auth, one release) → the journey per repo, in
   workspace order (primary first), then ONE summary and ONE done/next line. Design first
   produces the shared tokens once and applies them per repo; spec writes one SDD-lite per repo
   with a `shared:` line pointing at `workspace.md`.
4. **Onboarding happens once per repo**, with the same three questions asked once: answers that
   are the same for every repo (archetype, purpose, country, conversation language) are written
   to each `profile.md`; stack and platform are inferred per repo from its own manifest.

## Specialists

- Resolve the root **per file you touch**: a file under `/abs/path/mobile/...` belongs to the
  `mobile` repo, so its `.hyperui/` is `/abs/path/mobile/.hyperui/`. Never write one repo's
  memory into another's.
- Never ask where the repo is: the roots are already known. If a path the user mentions is not
  among the roots, say so in one line and let the entry skill add it (`root-set`).
- `git` runs per repo (one commit series per root); `ship`/`infra` write their files in the repo
  they belong to and the shared steps (domain, DNS, a monorepo pipeline) in the primary's
  `ship.md` / infra files, saying which.

## Close

The done/next line names every root touched this turn, by role, once:
"Done: tokens applied in web and mobile · Next: spec for the login flow (web)".
