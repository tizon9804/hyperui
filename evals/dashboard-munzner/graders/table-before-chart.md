---
type: regex
target: trace
match: not_contains
pattern: '^(?:(?!\n\{"type":"assistant"[^\n]*?\|\s*(?:#\s*\|\s*)?(?:What|Qu(?:[eé]|\\u00e9))\b[^|]{0,80}\|\s*(?:Why|Por qu(?:[eé]|\\u00e9)|Para qu(?:[eé]|\\u00e9))\b[^|]{0,80}\|\s*(?:How|C(?:[oó]|\\u00f3)mo)\b)[\s\S])*"name":"(?:Write|Edit)","input":\{"file_path":"[^"]*\.(?:html|svg|jsx?|tsx?|py)"'
---

Deterministic ordering check over the whole trace (JSON, one message per line). The pattern
matches when a Write/Edit of chart code (an .html/.svg/.js/.tsx/.py file) appears BEFORE any
assistant-authored what–why–how table header (`| What | Why | How |`, or the Spanish
`| Qué | Por qué / Para qué | Cómo |`, optionally preceded by a `#` column) — whether that
table is in an assistant text message or inside a Write/Edit of `.hyperui/design.md`.
`match: not_contains` therefore passes only when the table comes first (or no chart file is
written at all). Tables inside tool RESULTS (skill text, references) are ignored because the
lookahead only inspects lines that start with `{"type":"assistant"`.
