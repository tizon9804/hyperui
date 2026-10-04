---
type: regex
target: { source: file, path: package.json }
pattern: '"version"\s*:\s*"0\.3\.2"'
---

The change is a code change with no new feature → PATCH: `package.json` goes from 0.3.1 to
exactly 0.3.2 (versioning.md §1). 0.3.1 (no bump), 0.4.0 (minor for a copy change) or 0.3.3
(bumped twice) all fail.
