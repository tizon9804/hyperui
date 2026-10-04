---
type: regex
target: last_message
pattern: '\b(tests?|pruebas?)\b'
flags: i
---

The reply mentions tests (the root §9 care line lists `tests` only when tests ran green; the
LLM rubric checks that the mention is truthful).
