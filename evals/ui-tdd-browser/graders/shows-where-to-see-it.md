---
type: regex
target: last_message
pattern: 'localhost:\d+|127\.0\.0\.1:\d+|\.(?:png|gif|webp)\b|\.hyperui/evidence|claude\.ai/artifact|npm run dev|vite(?: preview)?\b'
flags: i
---

"Show before you ask" (root §7): the reply tells the user where to SEE the result — a local URL
(dev server left running, or the command that starts it in a headless run), screenshot paths or
an artifact link — instead of only asking for approval.
