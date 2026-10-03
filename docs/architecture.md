# hyperui architecture

> Skeleton — filled in TASK-013.

## Component tree (0.3)

```
hyperui/
├── .claude-plugin/
│   ├── plugin.json              # 0.3.0, dependencies: ["frontend-design@claude-plugins-official"]
│   └── marketplace.json         # tizonai → hyperui 0.3.0
├── SKILL.md                     # /hyperui — the only visible entry (greet · profile · route · thread)
├── hooks/
│   └── hooks.json               # SessionStart(startup) → scripts/welcome.sh
├── skills/
│   ├── setup/   SKILL.md        # manual (disable-model-invocation) — unchanged role
│   ├── doctor/  SKILL.md        # manual — unchanged role
│   ├── design/  SKILL.md  references/sources.md
│   ├── motion/  SKILL.md  references/sources.md
│   ├── video/   SKILL.md  references/sources.md
│   ├── spec/    SKILL.md  references/{prd-template,requirements-template,design-template,tasks-template,sdd-lite-template}.md
│   ├── build/   SKILL.md  references/rules-{go,python,typescript,javascript,nextjs,swift,dart-flutter,rust,java}.md  references/docs-mcps.md
│   ├── review/  SKILL.md  references/{security-checklist,complexity-checklist,code-review-tone}.md
│   ├── patterns/SKILL.md  references/{ddd,cqrs,hexagonal,gof,resilience}.md
│   ├── ship/    SKILL.md  references/{providers,domains-dns,deploy-recipes,payments-by-country,mobile-desktop}.md
│   ├── infra/   SKILL.md  references/{terraform,containers,ci}.md
│   ├── viz/     SKILL.md  references/{munzner-procedure,question-to-idiom,munzner-references,munzner-pitfalls}.md
│   └── git/     SKILL.md  references/{conventional-commits,pr-template,release,hotfix,branching}.md
├── templates/hyperui/           # seeds for .hyperui/: profile.md brief.md state.md decisions.md design.md ship.md
├── scripts/
│   ├── setup.sh  doctor.sh      # existing
│   ├── welcome.sh               # SessionStart: prints additionalContext JSON only if .hyperui/ missing
│   ├── profile.sh               # init | get <key> | set <key> <value> | private  (yaml frontmatter ops)
│   └── check.sh                 # validate + bash -n + frontmatter lint + sources lint + company-agnostic grep
├── evals/
│   ├── nontech-landing-es/case.yaml
│   ├── expert-redesign-next/case.yaml
│   ├── business-budget/case.yaml
│   ├── dashboard-munzner/case.yaml
│   └── graders/*.md
├── docs/architecture.md
├── README.md  LICENSE  .gitignore
```
