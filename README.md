# hyperui — Claude Code plugin

A portable frontend craft kit for [Claude Code](https://code.claude.com). One command
installs the tools that make UI work look deliberate instead of templated — then the
plugin's own skills tell Claude how to use them well.

| Component | What it is | Source |
|---|---|---|
| **HyperFrames** | Write HTML/CSS, render deterministic MP4s. Promo clips from your real components. | https://github.com/heygen-com/hyperframes |
| **Motion** | Framer Motion's current package (`motion`), animations for React and vanilla JS. | https://motion.dev |
| **UI UX Pro Max** | Searchable design intelligence: styles, palettes, font pairings, UX rules. | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill |
| **21st.dev MCP** | 10k+ React/Tailwind components, searchable and generated from the editor. | https://21st.dev/mcp |
| **frontend-design** | Anthropic's official design-direction skill. | `frontend-design@claude-plugins-official` |

## Install on any machine

```
claude plugin marketplace add tizon9804/hyperui
claude plugin install hyperui@tizonai
```

Then, inside the project you are working on:

```
/hyperui:setup                       # project scope: skills → ./.claude/skills, motion → package.json
/hyperui:setup --global              # skills → ~/.claude/skills (once per machine)
/hyperui:setup --21st-key <key>      # also register the 21st.dev MCP (user scope, key never committed)
/hyperui:setup --skip-motion         # any of: --skip-hyperframes --skip-uipro --skip-motion --skip-21st --skip-frontend-design
/hyperui:setup --dry-run             # print the commands, install nothing
```

The 21st.dev key is free at https://21st.dev/mcp. You can also `export TWENTY_FIRST_API_KEY=...`
before running setup.

## Skills

| Skill | Use |
|---|---|
| `/hyperui:setup` | Install the stack into the current project (manual only). |
| `/hyperui:doctor` | Report what is installed and where (read-only). |
| `/hyperui:design` | The design brief and build workflow for a screen, page or component. |
| `/hyperui:motion` | Motion language: easing, durations, choreography, `motion` recipes. |
| `/hyperui:video` | Promo/demo clip with HyperFrames from the project's real tokens and assets. |

After setup the installed third-party skills are available too: `/hyperframes`,
`/ui-ux-pro-max`, `/frontend-design`.

## Requirements

Node ≥ 18 and npm. `python3` for UI UX Pro Max's search scripts. The `claude` CLI for
the frontend-design plugin and the 21st MCP registration.

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
