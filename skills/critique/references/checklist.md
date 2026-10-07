# Critique checklist — the 22 merged checks

Merged and de-duplicated from Norman's *DOET* principles (N), Nielsen's 10 heuristics (H#), ISO 9241-110:2020
interaction principles (ISO-#) and Shneiderman's 8 golden rules (S#). Full derivation and sources:
`docs/research/hci-ux-foundations.md` §2; URLs in `sources.md` (same folder).

ISO numbering: 1 suitability for the task · 2 self-descriptiveness · 3 conformity with user expectations ·
4 learnability · 5 controllability · 6 use-error robustness · 7 user engagement.

Run every check per screen/state. A check that cannot be run from the evidence at hand (static mock, no
interaction) is reported as "to verify", never as a violation.

| # | Check | How to test on a screen | Typical violation | Principle / source |
|---|---|---|---|---|
| C1 | Status always visible | Trigger every async action and time it; look for loading, saving, offline, empty states. | No loading state > 1 s; no progress > 10 s; silent save; spinner forever on error. | H1 visibility of status · N feedback · S3 · ISO-2 · Nielsen response-time limits (0.1 / 1 / 10 s) |
| C2 | Every action acknowledged | Click or tap each control; a pressed/hover/focus state must appear within 0.1 s. | Dead-feeling buttons; double submits because nothing happened. | N feedback · S3 informative feedback |
| C3 | Speaks the user's language | Read labels aloud to a non-team person; flag internal terms, codes, jargon. | "Entity", "sync job failed: 409", SKU codes as titles. | H2 match with the real world · ISO-3 · Grice (manner) |
| C4 | Labels predict outcomes | For each button say what will happen, then click and compare. | "OK / Yes / Submit" on destructive or costly actions; a "Continue" that charges the card. | H2 · N mapping · ISO-2 · NN/g OK–Cancel (verb labels) |
| C5 | Consistent words, places, order | Inventory every dialog and button; diff wording and position. | Crossed OK/Cancel between dialogs; one action named two ways; primary button switches sides. | H4 consistency · S1 · ISO-3 · capture slips (Norman) |
| C6 | Platform conventions | Compare with Apple HIG / Material / web norms for the target surface. | Cancel on the wrong side for the platform; custom scrollbars; non-standard back; no Cancel in an alert. | H4 · ISO-3 · Apple HIG alerts · Material dialogs |
| C7 | Clickable looks clickable (signifiers) | Screenshot test: mark what looks clickable, compare with what is. | Flat text buttons; underlined non-links; hover-only actions; hidden swipe. | N signifiers / affordances / discoverability · NN/g flat design, clickable elements |
| C8 | Controls map to effects | Is each control adjacent to or aligned with what it changes? | Global "Apply" far from the filters it applies; a toggle whose label states the opposite state. | N natural mapping |
| C9 | Coherent conceptual model | Could a newcomer explain the system's objects and verbs after one minute? | Two names for one thing; settings in three places; "Archive" vs "Delete" unclear. | N conceptual model · NN/g mental models · ISO-3 |
| C10 | Constraints before errors | Try invalid input: is it prevented, or caught late? | Free-text dates; Submit enabled with invalid fields then a server error. | H5 error prevention · S5 · N constraints · ISO-6 |
| C11 | Recognition over recall | List what the user must remember between screens; count it (Cowan ≈ 4 chunks). | Re-typing an order number from the previous page; step-1 options needed on step 3. | H6 · S8 · Cowan 2010 · WCAG 3.3.7 redundant entry |
| C12 | Hierarchy and focus | Squint test; count competing primary actions and equal-weight choices per view. | > 1 primary CTA; > ~5 equal choices with no default; decoration louder than content. | H8 aesthetic & minimalist · NN/g visual hierarchy · Hick–Hyman · Sweller extraneous load |
| C13 | Easy reversal | Perform each destructive or significant action: is there undo or back without data loss? | Delete with no undo; irreversible bulk actions; "back" loses the form. | H3 user control · S6 easy reversal · ISO-5 |
| C14 | Confirm only what is costly, with consequences | For each confirmation: object named? verb buttons? safe default? | "Are you sure?" + Yes/No; confirmations on routine actions (habituation); focus on Delete. | H5 · S5 · NN/g confirmation dialogs |
| C15 | User in control (exits, pace, no surprises) | Look for an exit on every step and modal; any auto-advance or auto-play? | Modal without close; forced tour; carousel that cannot stop; timeout without warning. | H3 · S7 · ISO-5 · Tognazzini "protect users' work" |
| C16 | Errors: recognize, diagnose, recover | Cause each error; check placement, wording, and that input is preserved. | "An error occurred"; message far from the field; form cleared on error; no next step. | H9 · ISO-6 · NN/g error-message guidelines · repair model |
| C17 | Closure | At the end of each task: explicit completion state + what happens next. | Payment done but the page just reloads; no confirmation number; no "what now". | S4 dialogs yield closure · Laurel (arc and ending) |
| C18 | Modes visible or absent | Find states that change what input means; is the state shown at the point of action? | Edit vs view indistinguishable; silent toggles; "test mode" not flagged. | Mode errors (Tesler, Raskin) · ISO-3 |
| C19 | Efficiency for experts | Repeat a frequent task three times: shortcuts, remembered defaults, bulk operations? | No keyboard path; no bulk edit; defaults that ignore the last choice. | H7 flexibility · S2 universal usability · ISO-1 · KLM |
| C20 | Help where needed | Find help for the hardest step without leaving the flow. | Docs only on a separate site; tooltip-only critical info; help in a different place per page. | H10 · ISO-2 · ISO-4 · WCAG 3.2.6 consistent help |
| C21 | Universal usability / accessibility | Keyboard-only pass; contrast; target size; zoom 200 %; labels on inputs and icons. | Contrast < 4.5:1 (1.4.3); focus hidden (2.4.11); targets < 24 px (2.5.8); drag-only (2.5.7). | S2 · ISO-1 · WCAG 2.2 AA |
| C22 | Engagement without manipulation | Does the UI invite continued use honestly? Cross-check the dark-pattern list. | Confirmshaming, nagging, fake urgency, pre-selected add-ons, hidden costs. | ISO-7 · deceptive.design taxonomy · DSA Art. 25 · FTC 2022 |

## Cognitive-load pass (runs with C11–C12)

- **Primary actions per view**: one. Count them; every extra one competes (Hick–Hyman: decision time grows with the
  number of choices; a recommended default shortens it).
- **Chunks held across steps**: ≤ 3–4 (Cowan). More → external memory: summary, compare table, persisted cart.
- **Grouping**: proximity and common region must match the real relationships (Gestalt, NN/g); a label sits closer to
  its own field than to the next; no boxes around things that are not a group.
- **Hierarchy**: ≤ 3 type sizes; the squint test shows exactly one thing first; order of attention = order of importance.
- **Scan path**: first words of headings and links carry the information; key facts in the first lines; the left edge
  is informative. The F-pattern is a symptom of unformatted text, not a layout goal.
- **Fitts**: the primary target is large and near the last input; destructive targets are small and far from frequent
  ones; touch targets ≥ 24 CSS px (WCAG 2.5.8), 44 px recommended; screen edges are "infinite" for a mouse, not for touch.

## Platform-convention quick table (C5–C6)

| Surface | Confirming action | Cancel | Labels | Destructive |
|---|---|---|---|---|
| macOS / iOS (Apple HIG) | right | left, always present in alerts | verbs naming the outcome ("Delete file") | destructive style, never the default |
| Windows | left ("OK · Cancel") | right | verbs preferred | not the default |
| Material (Android, web) | right | left of it | verbs, sentence case | emphasised but not pre-focused |
| Web (no platform) | pick one order and keep it on every dialog | always present | verbs | no primary styling |

There is no universally right OK/Cancel order; the violation is inconsistency or the wrong order for the target platform.

## Misreadings never to propagate

Miller's 7 is not a cap on visible items (visible items are recognised, not recalled; the working estimate is ~4
chunks). The "3-click rule" has no data behind it: judge information scent. "Make everything big" misreads Fitts
(distance matters, and dangerous targets should be harder to hit). On screens you design signifiers, not
affordances. Confirmations for everything cause habituation: undo is the stronger fix.
