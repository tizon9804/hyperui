# Code review tone

How findings are worded — in the report to the user and in any comment on a PR they ask for.

## Principles

- Criticize the **code, not the person**. Assume good intentions. Never open with a name.
- Explain the **why**: what breaks, and when — not only what to change.
- **Propose rather than impose.** When unsure whether something is wrong, ask instead of
  asserting: a confident false positive costs more trust than a missed nit.
- **One finding = one idea**, short and actionable, on the exact line (`file:line`, or the
  function name / snippet when there is no line).
- New code carries the standard; existing debt does not become this change's problem. Never
  ask to retrofit surrounding code the change did not make worse.
- Praise is allowed when something is genuinely good (a solid guard, the right data
  structure) — sparingly, so it keeps meaning something.

## Classes (internal triage)

- `blocking` — would ship a security hole, data loss or incorrect behavior. Fixed before "done".
- `should` — a real risk or cost worth fixing that is not a certain break.
- `nit` — minor, never for what the formatter or linter already covers.

On a PR the class label is **stripped before publishing**: the comment reads naturally, in the
user's voice ("Is this query bounded? With 10k rows it loads the whole table…").

## Finding format

```
<file>:<line> — <class>: <one-line claim>
  Why: <what breaks and when>
  Fix: <concrete change>
  Source: <cheat-sheet / RFC / checklist URL>
```

## Phrasing

Use: "I think…", "What do you think about…?", "Maybe we could…", "Would it be worth…?",
"Small detail…". Avoid: "This is wrong.", "Obviously.", "Just do X.", "That's bad practice.",
passive-aggressive or corporate filler.

- Weak: "You might want to consider handling the error case here."
- Better: "I think we're missing the case where the value comes in empty or null."

## What NOT to comment on

- Style the formatter or linter handles; personal preferences with no real impact.
- Code outside the scope under review — read it for context, comment only on what changed.
- Anything that follows the repo's own established pattern. If the pattern itself is risky,
  that is a separate note to the user, not a finding on this change.
- Hypothetical issues with no real path to exploit or trigger in this code.

Before keeping a finding, three questions: is it on code in scope? Can the author act on it?
If ignored, does anything happen (bug, hole, unmet requirement)? Any "no" → drop it.
A change can simply be fine: say so, with zero findings.

Source: Google engineering practices, review comments —
https://google.github.io/eng-practices/review/reviewer/comments.html
