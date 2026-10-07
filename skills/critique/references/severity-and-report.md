# Severity rubric and report template

## Severity 0–4 (Nielsen's scale)

| Score | Label | Use when | Example |
|---|---|---|---|
| 0 | Not a problem | Evaluators would disagree it is an issue | Stylistic preference |
| 1 | Cosmetic | Fix if time allows | Inconsistent icon stroke |
| 2 | Minor | Low priority; slows the user, does not block | Missing positive validation |
| 3 | Major | High priority; frequent or hard to overcome; hurts the goal | No loading state on Pay; error clears the form |
| 4 | Catastrophe | Must fix before release; blocks the task, loses data or money, or deceives | Crossed Delete/Cancel with no undo; hidden fees; any dark pattern |

Factors: frequency × impact × persistence, plus market impact. Rate from several lenses (novice, expert, keyboard / screen-reader user,
skeptical buyer) and average; one lens finds about a third of the problems.

**Each finding carries five fields, none optional.** **Principle violated** (check id + name + source: `C16 Errors: recognize, diagnose, recover (H9, ISO-6)`) ·
**evidence** (viewport, theme, element, screenshot or file ref; nothing seen = "to verify", not a finding) ·
**severity** (0–4) · **concrete fix** (one known pattern — verb label, undo toast, inline validation, sticky summary) ·
**effect on the goal** (one clause: "→ fewer downloads").

**The "done well" rule.** 2–4 **specific** strengths before the findings: element · why it works · principle satisfied ("the download button
names the detected OS — C4, Fogg Ability"). Not "nice design". A critique without strengths is unfair and gets
ignored; a strength also tells the builder what not to break.

## Report template (`.hyperui/critique/<yyyy-mm-dd>-<target>.md`; the artifact is the same content through `spec-page-template.html`, title `Critique — <target>`, track `critique`, status `draft`)

```
---
artifact_url: <artifact url or the fallback .html path>
---
# Critique — <product / screen / mock> — <yyyy-mm-dd>
**Goal:** <sign-up | purchase | download | read | contact | trust>  **Platform:** <web / iOS / …>  **Tasks walked:** <…>
**Evidence:** <live URL · tool · viewports × themes | screenshots · n files | mock · file> — <what could NOT be seen>
**Method:** 22-check heuristic pass · conversation/repair walk-through · cognitive-load pass · [Munzner pass] · a11y quick pass · conversion lens (<goal>) · platform conventions

## Verdict
Will this achieve <goal>? **likely | at risk | no** — because <one sentence>.
## Top 3 by impact on the goal
1. <finding title> — <effect on the goal>
## Done well
- <specific strength · principle satisfied>
## Findings
| # | Finding | Principle | Evidence | Sev | Fix | Effect on the goal |
|---|---|---|---|---|---|---|
## To verify (not seen in this evidence)
- <state or interaction that needs a live session or another viewport>
## Sources
- <principle → URL from references/sources.md, only those cited above>
```
