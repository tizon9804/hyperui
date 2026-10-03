---
type: regex
target: last_message
match: not_contains
pattern: 'hyperui:setup[\s\S]*hyperui:setup'
---

Passes when `/hyperui:setup` is mentioned at most once (zero or one time) in the final reply.
