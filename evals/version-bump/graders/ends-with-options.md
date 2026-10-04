---
type: regex
target: last_message
pattern: '\n[ \t]*1[.)][ \t][^\n]+\n[ \t]*2[.)][ \t][^\n]+(?:\n[ \t]*\d[.)][ \t][^\n]+)*(?:\n+[^\n]*(?:dime|cambiar|cambie|cambio|indícame|cuéntame)[^\n]*)?\s*$'
---

Root §9 in a headless run: the reply ends with a numbered list of 2–4 options (commit with this
message · edit it · also push · not yet), optionally followed by one closing line such as
"o dime qué cambiar". A reply that ends with a bare question or a "done" fails.
