---
type: regex
target: trace
pattern: '##\s*Browser evidence|no browser tool|without a browser|browser tool (?:is|was) not available|sin (?:una? )?(?:herramienta de )?navegador|no (?:hay|tengo|dispongo de) (?:acceso a )?(?:una? )?(?:herramienta de )?navegador|ning[uú]n navegador|no pude (?:abrir|verificar|ver)[^\n"]{0,40}navegador|headless'
flags: i
---

Either the `## Browser evidence` section was written (design.md) or the assistant said plainly
that no browser tool was available (Spanish or English), or a headless capture was attempted.
