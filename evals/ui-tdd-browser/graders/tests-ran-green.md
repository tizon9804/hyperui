---
type: regex
target: trace
pattern: 'Tests\s+\d+\s+passed\s+\(\d+\)'
---

Vitest actually ran and reported a green run ("Tests  2 passed (2)" in a Bash tool result).
A plan to run tests, or a red run only, does not pass.
