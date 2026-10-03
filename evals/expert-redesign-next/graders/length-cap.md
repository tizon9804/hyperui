---
type: regex
target: last_message
match: not_contains
pattern: '(?:[ \t]*\S[^\n]*\n(?:[ \t]*\n)*){16}[ \t]*\S'
---

Deterministic ceiling on the senior-tone reply: fails when the final message has 17 or more
non-empty lines (the ~12-line cap plus a 3-direction table's header/separator and one short
code fence). The LLM rubric judges the 12-unit rule; this regex only catches runaway replies.
