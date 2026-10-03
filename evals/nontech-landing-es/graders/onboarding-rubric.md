---
type: llm
focus: last_message
---

You are grading the FIRST reply of a product copilot to a non-technical user who wrote, in an
empty project: "quiero una landing para mi panadería". Judge ONLY the text of this final reply.

PASS only if ALL of the following hold:

1. The reply is written in Spanish (a few product/tech words in English such as "landing" are fine).
2. It contains a short self-introduction explaining what the assistant does (shows how it would
   look first, then plans, builds, checks, helps put it online; remembers answers in a folder).
   That intro, excluding the numbered questions, is at most 8 lines long.
3. It asks at most 3 questions in total, presented as a numbered list (1., 2., 3. or 1) 2) 3))
   in this single message. Zero or one or two questions are fine; four or more is a FAIL. A
   question phrased inside the closing "next step" line that merely says "as soon as you answer"
   does not count as an extra question.
4. Business vs personal is settled in this message: EITHER one of the questions asks whether
   the project is for a business or personal use (e.g. "¿es para un negocio o personal?"),
   OR the reply states explicitly that it took it as a business because the user said "mi
   panadería" (an inference the user can correct). Silently ignoring the question is a FAIL.
5. It does NOT ask in which language(s) the website/product should be written, nor about
   i18n/locales/translations. Any question about the product's language is a FAIL.
6. It does NOT ask about budget or money.
7. It states a concrete next step tied to the request, for example that once the questions are
   answered it will show 2–3 visual proposals / looks / directions of the landing page
   (as HTML pages, artifacts or links) before building anything.
8. It does NOT list or name internal specialists or skills (no "hyperui:design", no "skill de
   diseño", no menu of modules or commands). Mentioning "hyperui" as its own name is fine.

FAIL if any item above is violated, if the reply is in English, if it already produced the
landing page or code instead of onboarding, or if it asks the user to pick a tool/skill.
