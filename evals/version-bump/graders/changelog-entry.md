---
type: regex
target: { source: file, path: CHANGELOG.md }
pattern: '^##\s*\[?0\.3\.2\]?\s*[-—–]\s*2026-\d{2}-\d{2}'
flags: m
---

`CHANGELOG.md` has a block for the new version with today's date in Keep a Changelog form
(`## [0.3.2] - 2026-MM-DD`, or the project's `## 0.3.2 — 2026-MM-DD` variant).
