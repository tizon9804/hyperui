---
type: regex
target: last_message
match: not_contains
pattern: '\?[\s\S]*\?'
---

Senior tone, REQ-017: at most one question per reply. Fails when the final message contains
two or more question marks.
