# hyperui — Claude Code plugin

A product copilot for [Claude Code](https://code.claude.com): one visible command takes a
product with a UI — web, mobile, macOS, Windows — from idea to shipped. It shows you how it
would look before writing code, plans it, builds and reviews it, and walks you to a domain,
hosting and payments. It profiles you in at most three questions and remembers the rest in a
`.hyperui/` folder in your project, so you never answer twice.

## Install on any machine

```
claude plugin marketplace add tizon9804/hyperui
claude plugin install hyperui@tizonai
```

## How to use

```
/hyperui                             # describe what you want in your own words — that is all
/hyperui:setup                       # install the stack (HyperFrames, Motion, UI UX Pro Max, Impeccable…) into this project
/hyperui:doctor                      # report what is installed and where (read-only)
```

`/hyperui` greets once, asks at most three things, then designs, plans, builds, reviews and
ships with you, in your language. Say `/hyperui --private` if `.hyperui/` must not be committed.

```
/hyperui --repo ~/path/to/project …  # work on a repo from any directory: that path becomes the project root
                                     # (.hyperui/, specs, code, ship files); remembered per directory, so say it once
/hyperui --repo .                    # forget it and work on the current directory again
```

You can also just say it ("el repo está en ~/x"), or give several repos (`--repo ~/web --repo ~/mobile`,
"the web is in ../web and the api in ../api") for one workspace with its own `.hyperui/` per repo.
hyperui reads that repo and writes its `.hyperui/` without prompts; to let it run shell commands there
(tests, builds) start Claude in the repo or run `/add-dir <path>` once (Claude Code's own rule).

Setup options:

```
/hyperui:setup                       # project scope: skills → ./.claude/skills, motion → package.json
/hyperui:setup --global              # skills → ~/.claude/skills (once per machine)
/hyperui:setup --21st-key <key>      # also register the 21st.dev MCP (user scope, key never committed)
/hyperui:setup --skip-motion         # any of: --skip-hyperframes --skip-uipro --skip-motion --skip-21st --skip-frontend-design --skip-impeccable
/hyperui:setup --dry-run             # print the commands, install nothing
```

The 21st.dev key is free at https://21st.dev/mcp. You can also `export TWENTY_FIRST_API_KEY=...`
before running setup.


## For power users

Every specialist is hidden from the slash menu (`user-invocable: false`) and routed to
automatically by `/hyperui`; call one by name if you want:

| Skill | Use |
|---|---|
| `/hyperui:design` | Brief → 2–3 visual directions as artifacts → tokens → components → QA. |
| `/hyperui:motion` | Motion language: easing, durations, choreography, `motion` recipes. |
| `/hyperui:video` | Promo/demo clip with HyperFrames from the project's real tokens and assets. |
| `/hyperui:spec` | Gated PRD → requirements → design → tasks, or a one-file SDD-lite. |
| `/hyperui:build` | One task at a time: test first, per-language rules, official docs over memory. |
| `/hyperui:review` | Security, complexity and safety pass before anything is called done. |
| `/hyperui:patterns` | DDD, CQRS, hexagonal, GoF, resilience — only when the spec needs one. |
| `/hyperui:ship` | Domain, DNS, hosting, payments by country, store/desktop distribution. |
| `/hyperui:infra` | Terraform/Terragrunt, ECS Fargate vs EKS, GitHub Actions OIDC, state and IAM first. |
| `/hyperui:viz` | Munzner what–why–how analysis before any chart. |
| `/hyperui:git` | Conventional Commits, PRs, releases, hotfixes. |

After setup the installed third-party skills are available too: `/hyperframes`,
`/ui-ux-pro-max`, `/frontend-design`, `/impeccable <command>`.

### What setup installs

| Component | What it is | Source |
|---|---|---|
| **HyperFrames** | Write HTML/CSS, render deterministic MP4s. Promo clips from your real components. | https://github.com/heygen-com/hyperframes |
| **Motion** | Framer Motion's current package (`motion`), animations for React and vanilla JS. | https://motion.dev |
| **UI UX Pro Max** | Searchable design intelligence: styles, palettes, font pairings, UX rules. | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill |
| **21st.dev MCP** | 10k+ React/Tailwind components, searchable and generated from the editor. | https://21st.dev/mcp |
| **frontend-design** | Anthropic's official design-direction skill. | `frontend-design@claude-plugins-official` |
| **Impeccable** | Design vocabulary for agents: `/impeccable audit`, `polish`, `typeset`, `critique`… anti-pattern detection. | https://impeccable.style · `pbakaus/impeccable` |

## How it remembers

Project memory lives in `<root>/.hyperui/` (profile, brief, design, spec, decisions, state, ship)
and is committed by default, so the next session — or a teammate — picks up the thread.
`/hyperui --private` adds `.hyperui/` to `.gitignore` instead. The root is the current directory
unless you said `--repo <path>` (or named the path in words): that mapping is stored per
directory in the per-machine file `~/.claude/plugins/data/hyperui/user.md` (`roots:`), which also keeps a
small profile (level, language, country) so you are not profiled again in a new project.
With several repos, each keeps its own `.hyperui/` and the first one holds `.hyperui/workspace.md`
(the repos, one role each, the cross-repo next step).

## Grounding

Advice comes from sources opened at the time (each skill lists them; snapshots in `docs/research/`).
When an official MCP would help, hyperui shows the exact `claude mcp add` line and asks — it never adds one.
`scripts/check.sh` keeps the plugin company-agnostic. How it fits together: [`docs/architecture.md`](docs/architecture.md) · research: [`docs/research/`](docs/research/README.md).

## Requirements

### You need before installing

hyperui does not install these. Each line ends with how to check.

| | Why | Check |
|---|---|---|
| **Claude Code CLI**, signed in to a Claude account (hyperui runs on your own Claude; no hyperui account, no telemetry). No documented minimum for the `"skills": ["./"]` manifest form hyperui uses (only the `"."` spelling needs v2.1.221+); **tested on 2.1.288** — stay current. | runs everything | `claude --version` |
| **macOS** (tested: 15+, Apple Silicon and Intel). Linux should work (bash + python3; untested). Windows only via WSL2 — the hooks and scripts are bash (untested). | hooks, scripts | `uname -s` |
| **git** | `git` specialist, plugin updates | `git --version` |
| **Node 24 LTS recommended, ≥ 20 required** (+ npm; `nvm` is the easiest way to manage versions) | `/hyperui:setup` components, `motion` | `node --version` |
| **python3** (macOS ships it) | `scripts/profile.sh` and `scripts/permit.sh`; without it profile.sh falls back to awk but permit.sh stays silent, so permission prompts appear; UI UX Pro Max search needs it too | `python3 --version` |

Node or python3 missing (or Node < 20)? `/hyperui:setup` prints the install line for your OS
(Node 24 via `brew install node@24` / `nvm install 24` / NodeSource 24.x) and offers to run it
(`--install-prereqs`, Homebrew on macOS; on Linux/WSL2 you run the printed line).

### hyperui installs for you when missing (nothing to do)

- **Via `/hyperui:setup`:** HyperFrames skills, UI UX Pro Max skill, Anthropic `frontend-design`
  plugin, Impeccable plugin, the `motion` npm package in the project.
- **Via `infra`, on first use:** Terraform — asks once, then `brew install hashicorp/tap/terraform`
  on macOS; on Linux it prints the official install line for you to run.
- **Optional, only if you want them:** the 21st.dev components MCP (free key you create at
  https://21st.dev/mcp; hyperui registers it when you pass `--21st-key`), provider MCPs (Vercel,
  Supabase, Stripe, Terraform MCP…: hyperui shows the exact `claude mcp add` line and asks before
  adding).

### Network and permissions

Outbound HTTPS to the official docs and provider pages the skills cite (`WebFetch` prompts for
permission in default mode — expected). The plugin pre-approves only its own skills, its
reference reads, `scripts/profile.sh` and writes under `<root>/.hyperui/`; everything else
follows your normal Claude Code permissions.

## Local development

```
git clone git@github.com:tizon9804/hyperui.git
cd hyperui
claude plugin validate .        # manifests + skills
claude --plugin-dir .           # load this checkout for one session
```

## Updating

Bump `version` in `.claude-plugin/plugin.json` **and** `.claude-plugin/marketplace.json`,
push to `main`, then on each machine:

```
claude plugin update hyperui@tizonai
```

## License

MIT — see `LICENSE`. Third-party components keep their own licenses.
