---
type: regex
target: last_message
pattern: '(?:feat|fix|chore|refactor|style|perf|docs)(?:\([^)\n]*\))?!?:\s[^\n]+[\s\S]*?v?0\.3\.2(?!\d)'
---

The reply shows a proposed Conventional Commit message (`type(scope): subject`) and, after it,
names the new version 0.3.2 (`Bumps to v0.3.2.` in the body, or `chore(release): v0.3.2`).
