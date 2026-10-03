---
name: viz
description: "Decide how to visualize data before drawing anything: Munzner's what–why–how analysis, idiom choice by channel effectiveness, interaction and validation. Use for dashboards, charts, analytics views, reports, KPI pages, metrics, any CSV or table about to become a graphic — also when asked in Spanish (dashboard de ventas, tablero, gráfica, reporte). Invoke it FIRST, before any chart code and before a rendering skill such as dataviz: viz decides what to draw and writes the what–why–how table; the rendering skill only decides how it looks."
user-invocable: false
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/profile.sh *)
  - Read(//${CLAUDE_PLUGIN_ROOT}/**)
  - Edit(.hyperui/**)
---

# hyperui:viz — decide the chart before drawing it

Framework: Tamara Munzner, *Visualization Analysis and Design* (VAD). This skill owns the
**decision** (what data, which task, which idiom). The rendering rules (palette, dark mode,
accessibility, stat tiles) belong to the session's `dataviz` skill when it is available; do not
duplicate them here. Nothing is drawn until the what–why–how table exists.

## 1. Preflight

1. Resolve the project root with `${CLAUDE_PLUGIN_ROOT}/scripts/profile.sh root` and use it (absolute paths) for `.hyperui/` and for every repo read/write. If `<root>/.hyperui/profile.md` is missing, invoke the `hyperui` skill first (it onboards and routes); otherwise read `profile.md` and `state.md` and never re-ask what they hold. With several roots (`profile.sh roots`), work in the repo the request or the touched file belongs to, with that repo's `.hyperui/` (rules: `${CLAUDE_PLUGIN_ROOT}/references/workspace.md`).
   Profile fields used: `archetype` (sets the tone, §4), `conversation_language` (reply
   language), `product_languages` (language of chart titles, axis labels and legends — the first
   entry; if the list is empty, use the conversation language and say so in one line),
   `design.palette` (reuse the product's accent as the categorical anchor when it exists).
2. Read `brief.md` and `design.md` if present; never re-ask what they hold.
3. Check whether a skill named `dataviz` is listed in this session. If yes, charts follow its
   form, color and interaction rules and the reply says "chart follows the dataviz rules". If
   not, fall back to the color guidance in `references/channel-effectiveness.md`.
4. Load the references as you go: `references/munzner-procedure.md` (always, it is the
   checklist), `references/question-to-idiom.md` (step 5), `references/channel-effectiveness.md`
   (steps 5–6), `references/munzner-pitfalls.md` (before explaining the framework to anyone),
   `references/munzner-references.md` (when citing). They are verified against the official
   slides, the 2009 and 2013 papers and the errata. A claim that is not in them is stated only
   after opening the source listed in `munzner-references.md`, or marked "(unverified)".

## 2. Procedure (the literal checklist is `references/munzner-procedure.md`)

1. **Domain** — who uses it, which decision, the question in their words; flag the wrong-problem risk.
2. **What** — dataset type; per attribute: categorical / ordinal / quantitative, key or value,
   cardinality; what to **derive** (rates, deltas, index to baseline, ranks, bins, totals).
3. **Why** — jargon removed; `{action, target}` pairs; a task chain for dashboards.
4. **The what–why–how table** — one row per subtask (§3). **Hard gate: externalise it first** —
   write the `## Visualization` table into `.hyperui/design.md` (and show it in the reply) BEFORE
   creating or editing ANY chart file (.html/.svg/.js/.tsx/.py). Chart code written before that
   write is a defect; if it happened, delete the file and start again from this step.
5. **How** — spatial position first; arrangement by number of keys (0 scatter · 1 bar/line ·
   2 heatmap · many → small multiples); check mark constraints; Reduce/Facet before more channels.
6. **Validate** — expressiveness, effectiveness, discriminability, separability, rules of thumb,
   color, labels; then state that only *immediate* validation happened (see §6).
7. **Interaction** — only when the static view cannot answer; overview visible without hovering.
8. **Algorithm** — data volume vs the idiom's scalability limit and render cost.

## 3. The table

```
| # | What (in → out)                         | Why (action; target)      | How (marks · channels · arrange/map · manipulate/facet/reduce) |
|---|-----------------------------------------|---------------------------|-----------------------------------------------------------------|
| 1 | table: date (ordinal key), revenue (Q) → monthly total (derived) | present; trend | line mark · aligned vertical position · 1 key → line chart · hover for exact values |
```

Columns are fixed. Derived data is marked as such in *What*. *Why* uses the book's vocabulary:
analyze (discover / present / enjoy / produce), search (lookup / locate / browse / explore),
query (identify / compare / summarize) + target (trend, outlier, feature, distribution, extreme,
correlation, dependency, similarity, topology, path, shape). *How* names the mark, the channel
per attribute and the design-choice family used (Encode: arrange, map · Manipulate · Facet · Reduce).

## 4. Tone per archetype (REQ-017)

- **non-tech** — two sentences before the table: what the data is, what they want to find, and
  that each chart answers one of those questions. The table stays short (plain words in *Why*,
  e.g. "see the trend", "compare regions"); the jargon lives in the references, not in the reply.
  Then the chart. One question at most, with a recommended answer. Cap ~15 lines of prose.
- **dev** — the table, plus one line of *why* per idiom (the ranking fact that decided it).
- **senior** — the table is the answer. Options only when asked. Cap ~12 lines unless detail was requested.

Always lead with the result or next step, never with "I'm going to…". Reply in
`conversation_language`; keep chart text in the product language.

## 5. Delivering the chart

- Charts are **HTML artifacts** (Artifact tool when available; else an `.html` file the user
  opens). When `dataviz` is present, its palette, mark specs, dark-mode and accessibility rules
  apply — say so, do not restate them. Load `artifact-design` before writing the page if the
  session lists it.
- Munzner non-negotiables, enforced regardless of which rendering skill is present:
  - the task's key comparison sits on **aligned position or length** (bars/lines on a common
    scale); angle, area or color for the key comparison requires a written justification;
  - **no 3D** for abstract data; **no rainbow** for ordered data (monotone-luminance ramp
    instead); diverging ramps only around a real midpoint;
  - categorical hue: 6–12 bins including background and highlight; never hue alone (add
    luminance, shape or a direct label — about 8 % of men are red/green deficient);
  - stacked segments beyond the first are unaligned: use them for part-to-whole, not for
    comparing series; pies only for two to a few parts; dual axes avoided;
  - line marks only over an ordered key; bars start at zero;
  - title, labelled axes, a legend for everything plotted, no scientific notation;
  - overview visible without interaction; tooltips carry details only;
  - small multiples instead of animation when more than two states must be compared.
- Dashboards: an overview (aggregate) first, then detail views; the same hue means the same
  category in every panel; shared aligned scales within a small-multiple row.

## 6. Record and close

1. Append to `.hyperui/design.md` a `## Visualization` section: the what–why–how table, the
   idiom per row, the artifact URL(s), rejected idioms in one line each.
2. Add one line per non-obvious choice to `.hyperui/decisions.md`
   (`YYYY-MM-DD · region comparison = sorted bar, not pie · 5 levels, length > angle · <source url>`).
3. Update `.hyperui/state.md`: `next:` the single next step (e.g. "connect the CSV to the live
   source", "user confirms the regional question is the one they ask").
4. State plainly, once: *only the immediate validation of the nested model was done (design
   justified against perceptual principles, cost estimated); the downstream validation —
   real users doing their own work, adoption — has not happened.*
5. Name the sources in the reply, one line at the end, every time a chart or table is delivered:
   *Idiom choices follow Munzner, Visualization Analysis and Design — slides
   https://www.cs.ubc.ca/~tmm/talks/vad/vadallslides-2021.pdf · nested model (InfoVis 2009) ·
   task typology (Brehmer & Munzner, InfoVis 2013).* Add "(slides pN)" next to any specific claim.

## 7. Never propagate (details in `references/munzner-pitfalls.md`)

The book's *How* tree has **four** families (Encode, Manipulate, Facet, Reduce), not five.
Annotate/record/derive are *Why → produce* in the book (the 2013 paper had them under *how →
introduce*). "Overview first, zoom and filter, details on demand" is Shneiderman's mantra;
lie factor and data-ink ratio are Tufte's. The matrix beats node-link when links exceed
roughly 4× the nodes (errata). The channel ranking is tiers, not a proven total order.

## Sources

Cite only URLs that are listed in a skill/reference or that you opened this session; never construct or guess a URL.

- Book page (slides, videos, figures, errata linked): https://www.cs.ubc.ca/~tmm/vadbook/
- Official full slide deck (689 slides, free): https://www.cs.ubc.ca/~tmm/talks/vad/vadallslides-2021.pdf
- Lecture videos, 6.5 h, 22 segments (free): https://www.youtube.com/watch?v=1GhZisgc6DI&list=PLT4XLHmqHJBeB5LwmRmo6ln-m7K3lGvrk
- Munzner, "A Nested Model for Visualization Design and Validation", InfoVis 2009 (free): https://www.cs.ubc.ca/labs/imager/tr/2009/NestedModel/
- Brehmer & Munzner, "A Multi-Level Typology of Abstract Visualization Tasks", InfoVis 2013 (free): https://www.cs.ubc.ca/labs/imager/tr/2013/MultiLevelTaskTypology/brehmer_infovis13.pdf
- Book figures, CC-BY-4.0: https://www.cs.ubc.ca/~tmm/vadbook/eamonn-figs/alldiagrams.zip
- Errata: https://www.cs.ubc.ca/~tmm/vadbook/errata.html
- Full list, free/paid marked and unauthorized copies flagged: `references/munzner-references.md`
