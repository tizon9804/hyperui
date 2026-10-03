---
type: regex
target: last_message
match: not_contains
pattern: 'hyperui:(design|motion|video|spec|build|review|patterns|ship|infra|viz|git)\b|\b(skill|especialista|specialist)\b[^.\n]{0,40}\b(design|spec|ship|viz|build|review)\b'
flags: i
---
