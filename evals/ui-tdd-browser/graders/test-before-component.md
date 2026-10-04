---
type: regex
target: trace
match: not_contains
pattern: '^(?:(?!"name":"(?:Write|Edit)","input":\{"file_path":"[^"]*(?:\.(?:test|spec)\.[jt]sx?|__tests__/[^"]*\.[jt]sx?)")[\s\S])*"name":"(?:Write|Edit)","input":\{"file_path":"(?![^"]*__tests__/)[^"]*(?<!\.test|\.spec)\.[jt]sx"'
---

Deterministic TDD ordering check over the whole trace (JSON, one message per line). The
pattern matches when a Write/Edit of a React component file (`*.jsx` / `*.tsx` that is not a
`*.test.*` / `*.spec.*` file) appears BEFORE any Write/Edit of a test file (`*.test.jsx`,
`*.spec.tsx`, `__tests__/*.jsx`…). `match: not_contains` therefore passes only when the test
comes first (or no component file is written at all). Writes to `.hyperui/*.md`, CSS and
config files do not count either way.
