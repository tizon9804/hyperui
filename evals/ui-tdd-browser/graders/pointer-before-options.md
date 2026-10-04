---
type: regex
target: last_message
match: not_contains
pattern: '^(?:(?!localhost:\d+|127\.0\.0\.1:\d+|npm run dev|vite(?: preview)?\b|\.(?:png|gif|webp)\b|\.hyperui/evidence|claude\.ai/artifact)[\s\S])*\n[ \t]*1\.[ \t]'
---

"Show before you ask" (root §7), deterministic ordering: the pattern matches when the reply
reaches its first numbered option (`1. …`, the choice prompt) WITHOUT having given, earlier in
the message, a way to see the result — a local URL, the dev-server command (`npm run dev`),
screenshot paths (.png/.gif/.webp, `.hyperui/evidence`) or an artifact link. `match:
not_contains` therefore passes only when the pointer precedes the options (or there is no
numbered list at all; `shows-where-to-see-it` still requires the pointer somewhere).
