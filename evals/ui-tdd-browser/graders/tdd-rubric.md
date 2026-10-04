---
type: llm
focus: last_message
---

Context: a developer asked, in Spanish, to add an accessible primary button to the hero of a
Vite + React app that already has Vitest + Testing Library. You judge only the final reply text.

PASS when all three are true:

1. The reply is in Spanish.
2. It states that tests passed / are green now (any phrasing: "los tests pasan", "pasan los 3",
   "en verde", "tests green"). A reply that only says tests were added or tells the user to run
   them does not meet this.
3. It ends with a next-step choice: a question with options, or a numbered list of options
   (optionally followed by "o dime qué cambiar"), not a bare "done".

Otherwise FAIL.
