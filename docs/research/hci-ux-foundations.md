# HCI / UX foundations for a UI critic

Research notes to ground a future hyperui skill that **diagnoses and critiques UIs** (live products,
new designs, a designer's mock) against established HCI/UX theory plus conversion goals, and that
applies the same theory when building. Compiled 2026-10-06.

Sourcing rule: every claim links a page that was actually opened. "(unverified)" = could not open a
primary or secondary page that states it; "(search only)" = seen in search-result metadata, page not
opened. Data visualization (Munzner) is already covered in `munzner-vad.md` and the `viz` skill; Tufte
is listed below only for completeness.

---

## 1. Concept map — Javier's memories → canonical names

### Memory 1: "the eye can't take more than ~10 elements on a screen"

| Canonical concept | Author / source | One-line definition | How to check it on a screen |
|---|---|---|---|
| **Miller's "magical number seven"** | G. A. Miller, "The Magical Number Seven, Plus or Minus Two", *Psychological Review* 63, 81–97 (1956) — [psychclassics](https://psychclassics.yorku.ca/Miller/) | Two separate limits: ~7 categories for *absolute judgment* of one sensory dimension, and a memory span limited in **chunks**, not bits; recoding into bigger chunks extends it. | Not a cap on visible items. Ask: does the task make the user *hold* more than a few things in mind between screens? |
| **Cowan's 4 (3–5 chunks)** | N. Cowan, "The Magical Mystery Four" (2010), restating Cowan 2001 (*BBS*) — [PMC2864034](https://pmc.ncbi.nlm.nih.gov/articles/PMC2864034/) | When rehearsal and grouping are blocked, working memory holds ~3–5 chunks; capacity varies between people. | Count things the user must remember across steps (codes, prices, options on the previous page). >3–4 → give external memory (summary, compare table, cart). |
| **Working memory as UI constraint** | NN/g — [working memory & external memory](https://www.nngroup.com/articles/working-memory-external-memory/) | Your team has a larger span than your users; provide external memory instead of designing to a number. | Look for compare tables, persisted selections, visible order summary. |
| **Hick–Hyman law** | Hick & Hyman (1952, per Laws of UX) — [lawsofux.com/hicks-law](https://lawsofux.com/hicks-law/) | Decision time grows with number and complexity of choices (logarithmically; formula (unverified)). | Count competing **primary** choices per decision point; check for a recommended default and staged flows. |
| **Cognitive load theory** | J. Sweller, late 1980s — [Wikipedia: Cognitive load](https://en.wikipedia.org/wiki/Cognitive_load); primary paper "Cognitive load during problem solving", *Cognitive Science* 12 (1988) (unverified, publisher 403) | Intrinsic (task), extraneous (presentation), germane (learning) load; design removes extraneous load. NN/g UX version — [minimize cognitive load](https://www.nngroup.com/articles/minimize-cognitive-load/). | Remove clutter, reuse familiar patterns, prefill/default, show instead of tell. |
| **Gestalt grouping** | NN/g — [proximity](https://www.nngroup.com/articles/gestalt-proximity/), [common region](https://www.nngroup.com/articles/common-region/) (similarity, closure, figure/ground linked from those) | Near things = same group; things inside a boundary = same group. Overused boxes create clutter and "false floors". | Do spacing and containers match the real relationships? Labels closer to their own field than to the next one? |
| **Visual hierarchy** | NN/g — [visual hierarchy](https://www.nngroup.com/articles/visual-hierarchy-ux-definition/) | Order of attention = order of importance, via color/contrast, scale (≤3 sizes), grouping. | **Squint/blur test**: the one thing that should stand out does; nothing else competes. |
| **Scan patterns (F, layer-cake, spotted…)** | NN/g eyetracking, 2006 study, updated — [F-shaped pattern](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/) | Unformatted text gets scanned in an F; headings get layer-cake scanning. F is a symptom of poor formatting, not a target. "Z-pattern" is popular lore (unverified as NN/g research). | First words of headings/links carry the information; key info in the first lines; left edge informative. |
| **Fitts's law** | P. Fitts, 1950s (1954 paper (unverified)) — [NN/g Fitts's law](https://www.nngroup.com/articles/fitts-law/) | Movement time depends on distance and target size (logarithmic). Screen edges are "infinite" targets for mouse, not for touch. | Primary target large and near the last input (Submit next to last field); destructive targets small/far from frequent ones. Touch: WCAG 2.5.8 ≥24×24 CSS px ([WCAG 2.2](https://www.w3.org/WAI/WCAG22/quickref/)). |

### Memory 2: "a button must do what it says; crossed OK/Cancel makes people err"

| Canonical concept | Author / source | Definition | How to check |
|---|---|---|---|
| **Match between system and real world** (H2) | Nielsen — [10 heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/) | Users' language and real-world conventions, not internal jargon. | Labels in user words; order follows real-world sequence. |
| **Consistency and standards** (H4) | Nielsen, same | "Users should not have to wonder whether different words, situations, or actions mean the same thing." | Same action = same word/position everywhere; platform conventions respected. |
| **Mapping (natural mapping)** | Norman, *DOET* rev. 2013 — principles via [ybrikman review](https://www.ybrikman.com/blog/2015/01/26/the-design-of-everyday-things/) | Relationship between controls and their effects is predictable from layout/timing. | Control sits next to what it changes; direction matches effect. |
| **Conceptual model / mental model** | Norman (same); NN/g — [mental models](https://www.nngroup.com/articles/mental-models/) | The design must project a model the user can form; mental model = what the user believes. | Can a first-time user predict what each control does before clicking? |
| **Platform button order** | NN/g — [OK–Cancel or Cancel–OK?](https://www.nngroup.com/articles/ok-cancel-or-cancel-ok/); Material — [dialogs (M2)](https://m2.material.io/components/dialogs); Apple HIG — [alerts](https://developer.apple.com/design/human-interface-guidelines/alerts) | Windows: OK then Cancel; Mac: Cancel then OK; Material: confirming action on the right. Convention beats local optimization; use verb labels ("Delete file"), not OK/Yes. Apple: destructive button style, always a Cancel. | Order matches the target platform; **same order across all dialogs of the product**; labels are verbs naming the outcome. |
| **Slips vs mistakes** | Norman; NN/g — [user mistakes](https://www.nngroup.com/articles/user-mistakes/), [slips](https://www.nngroup.com/articles/slips/) | Slip = right goal, wrong action on autopilot; mistake = wrong goal from wrong mental model. | Slips → constraints, good defaults, forgiving formats, undo. Mistakes → conventions, signifiers, previews. |
| **Mode errors** | Tesler, Raskin — [Wikipedia: Mode (UI)](https://en.wikipedia.org/wiki/Mode_(user_interface)) | Input interpreted differently depending on a state the user misjudged. Remedies: avoid modes, quasimodes (hold-to-activate), clear state indicators. | Is current mode always visible? Does the same key/gesture do different things silently? |
| **Capture / description errors** | Norman *DOET*; J. Reason *Human Error* (1990) (both unverified — books not reachable; NN/g slip pages do not name them) | Capture: a frequent routine hijacks a similar rarer one. Description: similar controls confused. | Rare destructive action shares the position/look of a frequent one → violation. |

### Memory 3: "everything must give feedback like the real world (the elevator button sinks)"

| Canonical concept | Author / source | Definition | How to check |
|---|---|---|---|
| **Feedback** | Norman *DOET* 2013 (via [ybrikman](https://www.ybrikman.com/blog/2015/01/26/the-design-of-everyday-things/)); Shneiderman rule 3 — [8 golden rules](https://www.cs.umd.edu/users/ben/goldenrules.html) | Full and continuous information about results of actions and current state. "For every user action, there should be an interface feedback." | Every click/tap: pressed state, then result or progress. |
| **Visibility of system status** (H1) | Nielsen — [10 heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/) | Keep users informed through appropriate feedback within reasonable time. | Loading, saving, syncing, offline, empty states all visible. |
| **Affordance** | J. J. Gibson (ecological psychology; *The Ecological Approach to Visual Perception*, 1979 (unverified)) → Norman — [jnd.org: affordances and design](https://jnd.org/affordances-and-design/) | Gibson: actionable relationship between world and actor, exists even if unseen. In screens designers control only *perceived* affordances. | — (use signifiers below) |
| **Signifier** | Norman, *Interactions* 15(6), 2008 — [jnd.org: signifiers, not affordances](https://jnd.org/signifiers-not-affordances/) | "The perceivable part of an affordance is a signifier": any perceivable cue that says what to do and where. | Can you tell clickable from static without hovering? NN/g — [clickable elements](https://www.nngroup.com/articles/clickable-elements/). |
| **Constraints** | Norman *DOET* 2013 (via ybrikman) | Physical, logical, semantic, cultural constraints trim possible actions. | Disabled until valid, pickers instead of free text, input masks. |
| **Discoverability** | Norman *DOET* 2013 (via ybrikman) | Possible to determine what actions are possible and the current state. | Hidden gestures/hover-only actions with no signifier → violation. |
| **Response-time limits** | Nielsen — [3 limits](https://www.nngroup.com/articles/response-times-3-important-limits/), citing R. B. Miller 1968 and Card, Robertson & Mackinlay 1991 | 0.1 s feels instant; 1 s keeps flow; 10 s keeps attention — beyond needs progress + way out. | >1 s without indicator, >10 s without percent/ETA and cancel → violation. |
| **Doherty threshold** | Doherty & Thadani, *IBM Systems Journal* 1982 — [lawsofux.com/doherty-threshold](https://lawsofux.com/doherty-threshold/) | Productivity soars when the system responds in <400 ms. | Interaction response; on the web measured as INP ≤200 ms ([web.dev vitals](https://web.dev/articles/vitals)). |
| **KLM / GOMS** | Card, Moran & Newell 1980; book *The Psychology of Human-Computer Interaction* 1983 — [Wikipedia: KLM](https://en.wikipedia.org/wiki/Keystroke-level_model) | Predict expert task time from operators (K, P≈1.1 s, H≈0.4 s, M≈1.35 s, R). | See §5 method. |
| **Skeuomorphism → flat → flat 2.0** | NN/g — [flat design](https://www.nngroup.com/articles/flat-design/) | Flat (Metro/Win 8 2011, Apple ~2013) removed signifiers → "click uncertainty"; flat 2.0 restores subtle shadows/layers. | Buttons look like buttons; links distinguishable from text. |

### Memory 4: "a web page is a conversation; it must help repair misunderstandings, not drop the conversation"

| Canonical concept | Author / source | Definition | How to check |
|---|---|---|---|
| **ISO 9241-110:2020 interaction principles** (7) | ISO — [iso.org/standard/75258](https://www.iso.org/standard/75258.html) (403 to fetch); list verified at [Wikipedia: ISO 9241](https://en.wikipedia.org/wiki/ISO_9241) | 1 Suitability for the user's tasks · 2 Self-descriptiveness · 3 Conformity with user expectations · 4 Learnability · 5 Controllability · 6 Use error robustness · 7 User engagement. 2020 folded "individualization" into controllability and added user engagement (the 2006 edition said "dialogue principles", incl. error tolerance). | §2 checklist rows tagged ISO. |
| **Gulfs of execution / evaluation** | Hutchins, Hollan & Norman, "Direct Manipulation Interfaces", in Norman & Draper (eds.) *User Centered System Design* (1986) — [NN/g two gulfs](https://www.nngroup.com/articles/two-ux-gulfs-evaluation-execution/) | Execution: gap between intention and allowed actions. Evaluation: effort to perceive and interpret system state. | Can the user find *how* (execution) and tell *whether it worked* (evaluation)? |
| **Seven stages of action** | Norman *DOET* — [Wikipedia: Seven stages of action](https://en.wikipedia.org/wiki/Seven_stages_of_action) | Goal → plan (intention) → specify → perform \| perceive → interpret → compare with goal. | Walk each stage per task step; a broken stage names the defect. |
| **Grounding / common ground** | H. H. Clark & S. E. Brennan, "Grounding in communication", in Resnick, Levine & Teasley (eds.) *Perspectives on Socially Shared Cognition*, APA 1991 — [PDF (Stanford)](https://web.stanford.edu/~clark/1990s/Clark,%20H.H.%20_%20Brennan,%20S.E.%20_Grounding%20in%20communication_%201991.pdf) | Common ground = mutual knowledge, beliefs, assumptions. Grounding criterion: partners mutually believe they understood "to a criterion sufficient for current purposes". **Least collaborative effort**. Evidence of understanding: acknowledgement, relevant next turn, continued attention. | Does the UI give positive evidence it understood (echo the parsed input, "Saved 3 items to Trip A")? |
| **Conversational repair** | Schegloff, Jefferson & Sacks, "The Preference for Self-Correction in the Organization of Repair in Conversation", *Language* 53(2), 361–382 (1977) — [PDF](https://conversationanalysis.org/mp-files/preference-for-self-correction-in-the-organization-of-repair-in-conversation.pdf); overview [Wikipedia: Conversation analysis](https://en.wikipedia.org/wiki/Conversation_analysis) | Repair handles problems in speaking, hearing, understanding; classified by who initiates and who repairs; strong **preference for self-repair**; other-initiation via "Huh?", "What?". | UI version: the system initiates ("didn't understand X"), the **user** repairs in place with their input preserved. |
| **Cooperative principle / Grice's maxims** | H. P. Grice, "Logic and Conversation" (1975; collected 1989) — [SEP: Grice](https://plato.stanford.edu/entries/grice/) | Quantity (as informative as required, not more), Quality (true), Relation (relevant), Manner (perspicuous). | UI copy: no padding, no false promises, says what matters now, unambiguous. |
| **Shneiderman's 8 golden rules** | Shneiderman, Plaisant, Cohen, Jacobs & Elmqvist, *Designing the User Interface* 6th ed. (Pearson 2016) — [cs.umd.edu](https://www.cs.umd.edu/users/ben/goldenrules.html) | Consistency; universal usability; informative feedback; dialogs yield closure; prevent errors; easy reversal; keep users in control; reduce short-term memory load. | §2 rows tagged S. |
| **Computers as Theatre** | Brenda Laurel, 1991; 2nd ed. 2013 — [Norman's foreword, jnd.org](https://jnd.org/foreword-computers-as-theater-brenda-laurel/) | Interaction as drama unfolding over time (tension, resolution), not static screens. | Does the flow have a clear arc and an ending (closure)? |
| **The Media Equation / CASA** | Reeves & Nass, 1996 — [Wikipedia](https://en.wikipedia.org/wiki/The_Media_Equation) | People apply social rules (politeness, personality) to computers automatically. | Tone of errors and prompts matters as if a person said it — blame, rudeness, nagging are social failures. |

---

## 2. Merged critic checklist (~20 checks)

Sources merged and de-duplicated: Norman 7 (N), Nielsen 10 (H#), ISO 9241-110:2020 (ISO), Shneiderman 8 (S#).
Links: [Nielsen](https://www.nngroup.com/articles/ten-usability-heuristics/) · [Shneiderman](https://www.cs.umd.edu/users/ben/goldenrules.html) · [ISO list](https://en.wikipedia.org/wiki/ISO_9241) · [Norman via ybrikman](https://www.ybrikman.com/blog/2015/01/26/the-design-of-everyday-things/).

| # | Check | Covers | Concrete test | Typical violations |
|---|---|---|---|---|
| C1 | **Status always visible** | H1, N-feedback, S3, ISO-2 | Trigger every async action; time it. | No loading state >1 s; no progress >10 s; silent save; spinner forever on error. |
| C2 | **Every action acknowledged** | N-feedback, S3 | Click each control; pressed/hover/focus state within 0.1 s. | Dead-feeling buttons; double submits because nothing happened. |
| C3 | **Speaks the user's language** | H2, ISO-3 | Read labels to a non-team person; flag internal terms. | "Entity", "sync job failed: 409", SKU codes as titles. |
| C4 | **Labels predict outcomes** | H2, N-mapping, ISO-2 | For each button: say what will happen; then click and compare. | "OK/Yes/Submit" for destructive or costly actions; "Continue" that charges the card. |
| C5 | **Consistent words, places, order** | H4, S1, ISO-3 | Inventory dialogs/buttons; diff order and wording. | Crossed OK/Cancel between dialogs; same action named two ways; primary button switches sides. |
| C6 | **Platform conventions** | H4, ISO-3 | Compare against Apple HIG / Material / web norms for that surface. | Cancel on the wrong side for the platform; custom scrollbars; non-standard back behavior. |
| C7 | **Clickable looks clickable (signifiers)** | N-signifiers, N-affordances, N-discoverability | Screenshot test: mark what you think is clickable; compare to DOM. | Flat text buttons, underlined non-links, hover-only actions, hidden swipe. |
| C8 | **Controls map to effects** | N-mapping | Is each control adjacent to / spatially aligned with what it changes? | Global "Apply" far from the filters it applies; toggles whose label states the wrong thing. |
| C9 | **Coherent conceptual model** | N-conceptual model, ISO-3 | Can a newcomer explain the system's objects and verbs after 1 minute? | Two names for one thing; settings in three places; unclear what "Archive" vs "Delete" do. |
| C10 | **Constraints before errors** | H5, S5, N-constraints, ISO-6 | Try invalid input; does the UI prevent it or catch it late? | Free-text dates; enabling Submit with invalid fields then failing server-side. |
| C11 | **Recognition over recall / memory load** | H6, S8 | List what the user must remember between screens; count it (Cowan ~4). | Re-typing order number from a previous page; options described on step 1 needed on step 3. WCAG 3.3.7 redundant entry. |
| C12 | **Hierarchy and focus** | H8 | Squint test; count competing primary actions per view. | >1 primary CTA; >~5 equal-weight choices at one decision point with no default; decoration louder than content. |
| C13 | **Easy reversal** | H3, S6, ISO-5 | Perform each destructive/significant action: is there undo? | Delete with no undo; irreversible bulk actions; no "back" without losing data. |
| C14 | **Confirm only what's costly, with consequences** | H5, S5 | For each confirmation: specific object named? verb buttons? default is safe? | "Are you sure?" + Yes/No; confirmations on routine actions (alert fatigue); default focus on Delete. |
| C15 | **User in control (exits, pace, no surprises)** | H3, S7, ISO-5 | Look for exits on every step/modal; any auto-advance? | Modals without close; forced tours; carousels you can't stop; session timeouts without warning. |
| C16 | **Errors: recognize, diagnose, recover** | H9, ISO-6 | Cause each error; check message placement, wording, and that input is preserved. | "An error occurred"; message far from field; form cleared on error; no next step. |
| C17 | **Closure** | S4 | At the end of each task: explicit completion state + what next. | Payment done but page just reloads; no confirmation number; no "what happens now". |
| C18 | **Modes are visible or absent** | Mode errors, ISO-3 | Find states that change input meaning; is the state shown at the point of action? | Edit vs view mode indistinguishable; caps-like toggles; "test mode" not flagged. |
| C19 | **Efficiency for experts** | H7, S2, ISO-1 | Repeat a frequent task 3×; are there shortcuts, defaults, bulk ops? | No keyboard path; no bulk edit; defaults that ignore last choice. |
| C20 | **Help where needed** | H10, ISO-2, ISO-4 | Find help for the hardest step without leaving the flow. | Docs only in a separate site; tooltip-only critical info; WCAG 3.2.6 help location inconsistent. |
| C21 | **Universal usability / accessibility** | S2, ISO-1 | Keyboard-only pass; contrast check; target size; zoom 200 %. | Contrast <4.5:1 (1.4.3); focus hidden (2.4.11); targets <24×24 (2.5.8); drag-only (2.5.7). [WCAG 2.2](https://www.w3.org/WAI/WCAG22/quickref/) |
| C22 | **Engagement without manipulation** | ISO-7 | Does the UI invite continued use honestly? Cross-check §4 dark patterns. | Confirmshaming, nagging, fake urgency (see §4). |

---

## 3. Conversation & repair model for UI

Frame: each user action is a **contribution**; the system must **ground** it (give evidence it was
understood), detect **breakdown**, and support **repair** that keeps the conversation alive
([Clark & Brennan 1991](https://web.stanford.edu/~clark/1990s/Clark,%20H.H.%20_%20Brennan,%20S.E.%20_Grounding%20in%20communication_%201991.pdf);
[Schegloff et al. 1977](https://conversationanalysis.org/mp-files/preference-for-self-correction-in-the-organization-of-repair-in-conversation.pdf)).

| Phase | Conversation analogue | UI obligation | Patterns (source) |
|---|---|---|---|
| **Grounding** | Acknowledgement, relevant next turn, continued attention | Show you heard *and* understood: echo the interpreted input, state the result in user terms. | Pressed state + specific success message ("Moved 3 files to Archive"); positive inline validation checkmarks ([Baymard](https://baymard.com/blog/inline-form-validation)). |
| **Pre-empting trouble** | Speaker designs utterance for recipient | Constraints, defaults, format hints, stated rules. | State password/phone rules up front; forgiving formats; good defaults ([NN/g slips](https://www.nngroup.com/articles/slips/); [NN/g forms](https://www.nngroup.com/articles/web-form-design/)). |
| **Breakdown detection** | "Huh?" / "What?" (other-initiated repair) | Detect early and *locally*, but not prematurely. | Inline validation after leaving a field, not on empty fields; clear the error keystroke-by-keystroke once fixed ([Baymard](https://baymard.com/blog/inline-form-validation)). |
| **Repair initiation** | Point at the trouble source | Message next to the source, says what and why, in plain language, no blame. | [NN/g error-message guidelines](https://www.nngroup.com/articles/error-message-guidelines/); H9. |
| **Self-repair by the user** | Preference for self-correction | Let the user fix it themselves, in place, with their input **preserved**. | Keep form values on error; "did you mean …?" suggestions; editable summaries. |
| **Reversal** | "Sorry, I meant…" | Undo instead of interrogation for routine actions. | Undo toast; trash/recycle bin; versioning (S6; [NN/g confirmation dialogs](https://www.nngroup.com/articles/confirmation-dialog/)). |
| **Confirm with consequences** | "Just to be sure: you want X, which means Y?" | Only for costly/irreversible; name the object and effect; verb buttons; safe default; typed confirmation for severe. | [NN/g confirmation dialogs](https://www.nngroup.com/articles/confirmation-dialog/); [Apple alerts](https://developer.apple.com/design/human-interface-guidelines/alerts). |
| **Pacing / not overwhelming** | Turn-taking, one topic at a time | Show the essential first; advanced on request (≤2 levels). | [NN/g progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/). |
| **Not dropping the conversation** | Conversation resumes after interruption | Interruptions (timeout, crash, navigation away, slow network) must not destroy state. | Drafts autosave, resumable checkout, warn before timeout, retry with preserved payload (Tognazzini "Protect users' work" — [asktog](https://asktog.com/atc/principles-of-interaction-design/)); WCAG 3.3.7 redundant entry. |
| **Closure** | "Great, done — see you" | Explicit end + next step. | Shneiderman rule 4 ([golden rules](https://www.cs.umd.edu/users/ben/goldenrules.html)). |
| **Tone** | Politeness, cooperative principle | Copy obeys Grice: enough but not more, true, relevant, clear. People treat it as social ([Media Equation](https://en.wikipedia.org/wiki/The_Media_Equation)). | No "invalid/illegal"; no false "almost done"; no jargon. |

Critic test for any flow: induce one error per step (wrong format, empty, network off, back button,
timeout) and ask: *Did the system say what it understood? Did it point at the trouble? Could I fix it
myself without retyping? Could I undo? Did the conversation survive?*

---

## 4. Conversion-goal lens

Models to apply on top of usability:

- **Fogg Behavior Model, B = MAP** — behavior happens when Motivation, Ability and a Prompt converge at the same moment; if it doesn't happen, one is missing ([behaviormodel.org](https://behaviormodel.org/)). Critic question: which of M, A, P is weakest at the CTA?
- **LIFT model** (Chris Goward, WiderFunnel/Conversion, 2009) — Value proposition at the center; Relevance and Clarity amplify; Anxiety and Distraction drag; Urgency pushes ([conversion.com](https://conversion.com/blog/the-six-landing-page-conversion-rate-factors/)).
- **Cialdini's 7 principles** — reciprocity, scarcity, authority, consistency, liking, social proof, unity ([Influence at Work](https://www.influenceatwork.com/7-principles-of-persuasion/)). Use honestly; faked versions are dark patterns.
- **HEART + Goals–Signals–Metrics** — Happiness, Engagement, Adoption, Retention, Task success; map each goal → signal → metric (Rodden, Hutchinson & Fu, CHI 2010 — [Google Research](https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/), [PDF](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/36299.pdf)). Engagement may be meaningless for enterprise tools.
- **Performance** — Core Web Vitals good at p75: LCP ≤2.5 s, INP ≤200 ms, CLS ≤0.1 ([web.dev](https://web.dev/articles/vitals)). Case studies: Vodafone LCP −31 % → +8 % sales; iCook CLS −15 % → +10 % ad revenue; Tokopedia LCP −55 % → +23 % session duration ([web.dev business impact](https://web.dev/case-studies/vitals-business-impact)).
- **Accessibility** — WCAG 2.2 AA as a baseline ([quickref](https://www.w3.org/WAI/WCAG22/quickref/)). That accessibility raises conversion is a common claim; no opened source quantified it (unverified).

| Goal | What to check (beyond §2) | Evidence / source |
|---|---|---|
| **Sign-up / lead** | Value prop above the fold and specific (LIFT); one primary CTA; minimum fields, optional marked; labels not placeholders; single column; password rules stated; social login vs anxiety; no forced account before value. | NN/g forms: guideline-compliant forms 78 % one-try submissions vs 42 % ([NN/g](https://www.nngroup.com/articles/web-form-design/)); Fogg Ability. |
| **Purchase / checkout** | Total cost visible early (no surprise fees); guest checkout; 12–14 form elements ideal vs 23.48 avg; trust near card fields; inline validation; delivery time shown; resumable cart. | Baymard: 70.22 % avg abandonment; reasons: extra costs 40 %, slow delivery 20 %, card-security distrust 19 %, forced account 18 %, too long/complex 17 %, errors 17 %; +35.26 % conversion possible from better checkout ([Baymard](https://baymard.com/lists/cart-abandonment-rate)). |
| **Download / install** | Right build auto-detected; size, version, requirements stated; what happens after click (closure); no disguised ad buttons. | Deceptive patterns: disguised ads ([deceptive.design](https://www.deceptive.design/types)); S4 closure. |
| **Read / learn** | Headings front-loaded, scannable; first lines carry key info; readable width/contrast; no interstitials blocking content; fast LCP, no CLS. | NN/g F-pattern ([link](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/)); web.dev CWV. |
| **Trust** | Who is behind it, real contact, honest social proof, authority signals, security cues at the risk moment, clear pricing and cancellation; consistency of visual quality. | Cialdini authority/social proof; LIFT anxiety; Baymard security 19 %. |

**Dark patterns to flag (blocking in a critique).** Brignull's taxonomy ([deceptive.design/types](https://www.deceptive.design/types)): sneaking, forced action, hard to cancel, preselection, obstruction, hidden subscription, hidden costs, trick wording, visual interference, fake social proof, fake urgency, nagging, fake scarcity, disguised ads, confirmshaming, comparison prevention, addictive design, currency confusion.
Regulation: EU Digital Services Act Art. 25 bans interfaces that deceive, manipulate or "materially distort or impair" free and informed decisions; examples: giving prominence to one choice, repeatedly asking after a choice was made, making termination harder than sign-up ([Reg. (EU) 2022/2065](https://eur-lex.europa.eu/eli/reg/2022/2065/oj)). US: FTC staff report "Bringing Dark Patterns to Light", Sept 2022 ([ftc.gov](https://www.ftc.gov/reports/bringing-dark-patterns-light)).

---

## 5. Evaluation procedure, severity rubric, report template

### Methods the skill can run

| Method | Source | Input it needs | Output |
|---|---|---|---|
| **Heuristic evaluation** | Nielsen; 3–5 evaluators, two passes, 1–2 h each, independent then debrief ([how to conduct](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/)); 1 evaluator ≈35 % of problems, 5 ≈85 % ([theory](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/theory-heuristic-evaluations/)) | Screenshots or live URL + target tasks | Findings with severity |
| **Cognitive walkthrough** | Lewis et al. 1990; Wharton et al. streamlined ([NN/g](https://www.nngroup.com/articles/cognitive-walkthroughs/)) | Task + correct action sequence | Per step: 4 questions — will they try the right goal? notice the action? associate it with the goal? see progress? |
| **5-second test** | Christine Perfetti, mid-2000s; duration is convention, adjust to complexity ([Smashing](https://www.smashingmagazine.com/2023/12/five-second-testing-case-study/)) | Screenshot | Recall/first-impression answers (needs real people; skill can only simulate as a heuristic). |
| **SUS** | John Brooke, 1986; 10 items, 5-point; score = ((odd−1)+(5−even))×2.5; average 68 ([MeasuringU](https://measuringu.com/sus/)) | Real participants | 0–100 score (not a percentile). |
| **KLM / GOMS** | Card, Moran & Newell ([Wikipedia](https://en.wikipedia.org/wiki/Keystroke-level_model)) | Expert action sequence | Predicted time: sum K, P(1.1 s), H(0.4 s), M(1.35 s), R. Compare designs, not absolute truth; expert, error-free only. |
| **Think-aloud test** | Nielsen ([NN/g](https://www.nngroup.com/articles/thinking-aloud-the-1-usability-tool/)) | ~5 real users | Observed breakdowns (skill can prepare the script, not replace users). |

### Heuristic evaluation from screenshots or a live URL — steps

1. **Scope**: product, audience, platform (iOS/Android/web/desktop → which conventions), the **goal** (§4 row), and 3–5 key tasks.
2. **Capture**: live URL → walk each task in a browser, screenshot every state including loading, empty, error, success; record timings (CWV if web). Screenshots only → list states that are missing as findings-to-verify, not as violations.
3. **Pass 1 (familiarize)**: complete each task without judging; note the conceptual model you formed.
4. **Pass 2 (judge)**: per screen/state run §2 checks C1–C22; per task run the cognitive-walkthrough 4 questions; run the §3 error-injection test; run the §4 goal lens and dark-pattern list.
5. **Independent lenses**: emulate multiple evaluators by running passes with different personas (novice, expert, keyboard/screen-reader user, skeptical buyer) and merging — fewer than 3 lenses misses most problems.
6. **Rate** every finding with the rubric below (frequency × impact × persistence, plus market impact).
7. **Consolidate**: merge duplicates, group by task/screen, sort by severity; add 1–3 strengths (what works, keep it).
8. **Fix**: one concrete fix per finding, preferring a known pattern (verb label, undo toast, inline validation…).

### Severity rubric (Nielsen 0–4 — [NN/g](https://www.nngroup.com/articles/how-to-rate-the-severity-of-usability-problems/))

| Score | Label | Use when | Example |
|---|---|---|---|
| 0 | Not a problem | Evaluators disagree it's an issue | Stylistic preference |
| 1 | Cosmetic | Fix if time allows | Inconsistent icon stroke |
| 2 | Minor | Low priority; slows but doesn't block | Missing positive validation |
| 3 | Major | High priority; frequent or hard to overcome; hurts the goal | No loading state on Pay; error clears the form |
| 4 | Catastrophe | Must fix before release; blocks task, loses data/money, or deceptive | Crossed Delete/Cancel with no undo; hidden fees; dark pattern |

Factors: frequency, impact, persistence, market impact. Average several raters/lenses.

### Report template

```
# UI critique — <product/screen> — <date>
Goal: <sign-up | purchase | download | read | trust>   Platform: <…>   Tasks: <…>
Method: heuristic eval (N lenses) + cognitive walkthrough + error-injection + goal lens
Summary: <3 lines: biggest risk to the goal, top 3 fixes>
Strengths: <1–3>

| # | Finding | Principle violated | Evidence | Sev | Fix |
|---|---------|--------------------|----------|-----|-----|
| 1 | Delete and Cancel swap sides between the two dialogs | C5 Consistency (H4, S1); capture slip | screens 3 & 7 (screenshot refs) | 4 | Same order everywhere per platform; verb label "Delete project"; add undo |
| 2 | Pay button gives no feedback for ~3 s | C1 Status (H1, S3); 1 s limit | recording at 00:42 | 3 | Pressed state + spinner in button; disable to prevent double charge |
```

---

## 6. Reading list (free first) and common misreadings

**Free, primary or authoritative**
- Nielsen, 10 usability heuristics (1994, updated 2024) — https://www.nngroup.com/articles/ten-usability-heuristics/
- NN/g heuristic evaluation how-to & severity — https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/ · https://www.nngroup.com/articles/how-to-rate-the-severity-of-usability-problems/
- NN/g response times — https://www.nngroup.com/articles/response-times-3-important-limits/
- NN/g two gulfs — https://www.nngroup.com/articles/two-ux-gulfs-evaluation-execution/
- Shneiderman's 8 golden rules — https://www.cs.umd.edu/users/ben/goldenrules.html
- Norman: affordances — https://jnd.org/affordances-and-design/ · signifiers — https://jnd.org/signifiers-not-affordances/
- Miller 1956 full text — https://psychclassics.yorku.ca/Miller/ · Cowan 2010 — https://pmc.ncbi.nlm.nih.gov/articles/PMC2864034/
- Clark & Brennan 1991 — https://web.stanford.edu/~clark/1990s/ (PDF above) · Schegloff et al. 1977 — https://conversationanalysis.org/mp-files/preference-for-self-correction-in-the-organization-of-repair-in-conversation.pdf
- Grice (SEP) — https://plato.stanford.edu/entries/grice/
- Tognazzini, First Principles of Interaction Design (rev. 2014) — https://asktog.com/atc/principles-of-interaction-design/
- ISO 9241-110:2020 (paywalled) — https://www.iso.org/standard/75258.html; summary — https://en.wikipedia.org/wiki/ISO_9241
- Baymard checkout stats & inline validation — https://baymard.com/lists/cart-abandonment-rate · https://baymard.com/blog/inline-form-validation
- NN/g forms — https://www.nngroup.com/articles/web-form-design/ · error messages — https://www.nngroup.com/articles/error-message-guidelines/
- web.dev Core Web Vitals & business impact — https://web.dev/articles/vitals · https://web.dev/case-studies/vitals-business-impact
- WCAG 2.2 quick reference — https://www.w3.org/WAI/WCAG22/quickref/
- HEART paper — https://research.google/pubs/measuring-the-user-experience-on-a-large-scale-user-centered-metrics-for-web-applications/
- Fogg — https://behaviormodel.org/ · LIFT — https://conversion.com/blog/the-six-landing-page-conversion-rate-factors/ · Cialdini — https://www.influenceatwork.com/7-principles-of-persuasion/
- Deceptive patterns — https://www.deceptive.design/types · DSA Art. 25 — https://eur-lex.europa.eu/eli/reg/2022/2065/oj · FTC 2022 — https://www.ftc.gov/reports/bringing-dark-patterns-light
- Platform: Apple alerts — https://developer.apple.com/design/human-interface-guidelines/alerts · Material dialogs — https://m2.material.io/components/dialogs
- Laws of UX (secondary, handy) — https://lawsofux.com/

**Textbook canon (books)**

| Book | Authors / edition | Source |
|---|---|---|
| *The Design of Everyday Things* | Don Norman, revised & expanded 2013 (Basic Books) | Principles via [review](https://www.ybrikman.com/blog/2015/01/26/the-design-of-everyday-things/); publisher page 403 |
| *Usability Engineering* | Jakob Nielsen, 1993, Morgan Kaufmann | [nngroup.com/books](https://www.nngroup.com/books/usability-engineering/) |
| *Designing the User Interface* | Shneiderman, Plaisant, Cohen, Jacobs, Elmqvist — 6th ed. 2016 | [cs.umd.edu](https://www.cs.umd.edu/users/ben/goldenrules.html) |
| *Human–Computer Interaction* | Dix, Finlay, Abowd, Beale — 3rd ed. 2004, Prentice Hall | [hcibook.com](https://hcibook.com/) |
| *Interaction Design: beyond HCI* | Rogers, Sharp, Preece (author order (unverified)) — site lists 6th ed. 2026, Wiley | [id-book.com](https://www.id-book.com/) |
| *Don't Make Me Think, Revisited* | Steve Krug — 3rd ed. 2014, New Riders | [sensible.com](https://sensible.com/dont-make-me-think/) |
| *About Face* | Cooper, Reimann, Cronin, Noessel, Csizmadi, LeMoine — 4th ed. 2014, Wiley | [wiley.com](https://www.wiley.com/en-us/About+Face%3A+The+Essentials+of+Interaction+Design%2C+4th+Edition-p-9781118766576) |
| *100 Things Every Designer Needs to Know About People* | Susan Weinschenk — 2nd ed. 2020, New Riders | (search only) [Pearson](https://www.pearson.com/store/en-gb/p/100-things-every-designer-needs-to-know-about-people/P200000000675) |
| *Universal Principles of Design* | Lidwell, Holden, Butler — rev. 2010 (125 principles); 3rd ed. exists | (search only) [O'Reilly](https://oreilly.com/library/view/universal-principles-of/9780760375174) |
| *Computers as Theatre* | Brenda Laurel — 1991; 2nd ed. 2013 | [jnd.org foreword](https://jnd.org/foreword-computers-as-theater-brenda-laurel/) |
| *The Media Equation* | Reeves & Nass — 1996 | [Wikipedia](https://en.wikipedia.org/wiki/The_Media_Equation) |
| *The Visual Display of Quantitative Information* | Edward Tufte — 1983, 2nd ed. 2001 (data-ink, chartjunk, lie factor) | [edwardtufte.com](https://www.edwardtufte.com/book/the-visual-display-of-quantitative-information/) — Munzner already in `munzner-vad.md` |

**Where popular summaries get it wrong**
- **"7±2 items per screen."** Miller's 7 is the span of *absolute judgment* and of *immediate memory in chunks*; it says nothing about how many items may be *visible* — visible items are recognized, not recalled ([Miller](https://psychclassics.yorku.ca/Miller/)). Laws of UX itself warns against using it to cap menus at seven ([lawsofux](https://lawsofux.com/millers-law/)). Modern estimate is ~4 chunks ([Cowan](https://pmc.ncbi.nlm.nih.gov/articles/PMC2864034/)). Javier's "~10 elements" intuition is better explained by Hick (choices per decision), hierarchy and extraneous load.
- **"3-click rule."** A myth: no published data; Porter's study found no drop-off or satisfaction loss beyond 3 clicks; origin is an unsupported assertion (Zeldman 2001) ([NN/g](https://www.nngroup.com/articles/3-click-rule/)). Judge information scent instead.
- **Fitts's law misuse.** It's about size *and distance* along the movement, logarithmic; "make everything big" ignores that; edge/corner advantage holds for mouse, not touch ([NN/g](https://www.nngroup.com/articles/fitts-law/)). Also: make dangerous targets *harder* to hit.
- **"Affordance" for every visual cue.** On screens you design *signifiers*; Norman himself says so ([jnd.org](https://jnd.org/signifiers-not-affordances/)).
- **F-pattern as a layout goal.** NN/g describes it as what happens to poorly formatted text; design so people don't need it ([NN/g](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/)).
- **"Always confirm destructive actions."** Overused confirmations cause habituation; undo is the stronger fix ([NN/g](https://www.nngroup.com/articles/confirmation-dialog/)).
- **"One right OK/Cancel order."** There isn't one; follow the platform and be consistent ([NN/g](https://www.nngroup.com/articles/ok-cancel-or-cancel-ok/)).
- **"5 seconds" is magic.** It's a convention, not a finding; adjust to visual complexity ([Smashing](https://www.smashingmagazine.com/2023/12/five-second-testing-case-study/)).
- **SUS 70 = 70th percentile.** No; 68 is the average, convert to percentiles ([MeasuringU](https://measuringu.com/sus/)).
