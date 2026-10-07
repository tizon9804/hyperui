# Conversion lens — judge the UI against what the visitor is supposed to do

Usability is necessary, not sufficient: a flawless page that does not move the visitor toward the goal fails.
Apply this lens after the checklist, once the goal is known (sign-up · purchase · download · read · contact ·
trust). Models and URLs: `docs/research/hci-ux-foundations.md` §4, `sources.md`.

## Models to apply at the primary CTA

- **Fogg Behavior Model, B = MAP** — behaviour happens when Motivation, Ability and a Prompt converge. Critic
  question: which of M, A, P is weakest at the CTA? (No visible prompt above the fold = P; a six-field form = A;
  a vague value proposition = M.)
- **LIFT** (Goward) — the Value proposition in the centre; Relevance and Clarity amplify it; Anxiety and
  Distraction drag it down; Urgency pushes. Name the factor each finding touches.
- **Cialdini's principles** — reciprocity, scarcity, authority, consistency, liking, social proof, unity. Only
  honest versions count; a faked one is a dark pattern (below).
- **Core Web Vitals** (good at p75): LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1. Measure when a live URL exists; a
  slow or shifting page lowers Ability for everyone.
- **WCAG 2.2 AA** as the baseline: excluded visitors cannot convert. (That accessibility raises conversion is a
  common claim no opened source quantified — say "(unverified)" if you state it.)

## Per goal — what to check beyond the 22 checks

| Goal | Check | Evidence behind it |
|---|---|---|
| **Sign-up / lead** | Value proposition above the fold and specific; ONE primary CTA; minimum fields with optional ones marked; labels (not placeholders); single column; password rules stated before typing; no forced account before any value; social login weighed against anxiety. | NN/g web-form guidelines (compliant forms: 78 % one-try submissions vs 42 %); Fogg Ability |
| **Purchase / checkout** | Total cost visible early (no surprise fees); guest checkout; 12–14 form elements (average sites have ~23); trust cues next to the card fields; inline validation; delivery time shown; cart resumable. | Baymard cart-abandonment list: ~70 % average abandonment; top reasons extra costs 40 %, slow delivery 20 %, card-security distrust 19 %, forced account 18 %, too long 17 %, errors 17 % |
| **Download / install** | Right build auto-detected (OS, chip); size, version, requirements stated; what happens after the click (closure: where the file is, how to open it, Gatekeeper/SmartScreen note); no disguised ad buttons; a fallback for the other platforms. | Deceptive patterns: disguised ads; Shneiderman S4 closure |
| **Read / learn** | Front-loaded, scannable headings; key facts in the first lines; readable measure (≤ 80ch) and contrast; no interstitial blocking the content; fast LCP, no CLS. | NN/g F-pattern and layer-cake scanning; web.dev CWV |
| **Contact** | The channel is visible on every page; the form asks only what a reply needs; response expectation stated ("we answer within a day"); confirmation after sending. | NN/g forms; S4 closure |
| **Trust** | Who is behind it, real contact, honest social proof, authority signals, security cues at the risk moment, clear pricing and cancellation, consistent visual quality. | Cialdini authority / social proof; LIFT anxiety; Baymard security distrust 19 % |

## Dark patterns — flag as severity 4, always

Brignull's taxonomy (deceptive.design): sneaking · forced action · hard to cancel · preselection · obstruction ·
hidden subscription · hidden costs · trick wording · visual interference · fake social proof · fake urgency ·
nagging · fake scarcity · disguised ads · confirmshaming · comparison prevention · addictive design · currency
confusion.

Regulation to cite when relevant: EU Digital Services Act Art. 25 (interfaces that deceive, manipulate or
materially distort free and informed decisions — e.g. giving prominence to one choice, repeatedly asking after a
choice was made, making termination harder than sign-up); US FTC staff report "Bringing Dark Patterns to Light"
(2022). A dark pattern is reported even when it would "help" the goal: the critique's job is the honest version.

## How the lens changes the ranking

Every finding ends with its **effect on the goal** in one clause ("visitors cannot tell which button downloads
→ fewer downloads", "price appears only at step 3 → abandonment"). The top 3 are the findings with the largest
effect on the goal, not the highest heuristic severity alone; a severity-2 finding sitting on the CTA can
outrank a severity-3 finding in the footer.
