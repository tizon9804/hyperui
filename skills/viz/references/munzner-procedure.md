# Munzner procedure: data + question → chart (8 steps)

Checklist form of Munzner's *Visualization Analysis and Design*, Chapters 1–6 and the nested
model (InfoVis 2009). Follow it literally, in order. Tags: [S pN] = official slide deck page,
[P09] = Nested Model paper, [B13] = Brehmer & Munzner 2013, [E pN] = errata, [2nd] = Munzner-based
teaching notes only. **The what–why–how table (step 4) is produced before any chart code.**

Vocabulary: **What** = data abstraction. **Why** = task abstraction. **How** = idiom = visual
encoding + interaction design choices [S p17, p48, p105, p138].

---

## Step 1 — Domain (nested-model level 1)

- [ ] Restate who will use the view, which decision they make with it, and their question in their
      own words.
- [ ] Flag the *wrong-problem* threat ("they don't do that" [P09]): is this a question they actually
      ask? If unknown, write it as an explicit assumption in the reply.

## Step 2 — What: data abstraction (Ch 2) [S p46–48, p62–69, p242]

- [ ] **Dataset type**: table (flat = one key; multidimensional = several keys) · network / tree ·
      field (grid of positions with a value per cell) · geometry (spatial) · cluster / set / list.
- [ ] **Availability**: static or dynamic (streaming).
- [ ] **Per attribute**: name → **categorical** | **ordered → ordinal** | **ordered → quantitative**;
      ordering direction sequential / diverging / cyclic; **key** (independent, unique index) or
      **value** (dependent); cardinality (number of levels) and item count.
      Quantitative attributes are "typically unsuitable as keys" [E p34].
- [ ] **Semantics**: say what the numbers mean in the domain; the type alone does not [S p59].
- [ ] **Derive** ("don't necessarily just draw what you're given" [S p109]): rates, differences,
      index to a baseline, ranks, bins, clusters, totals. The data to show is often derived.

## Step 3 — Why: task abstraction (Ch 3) [S p105–137; B13 §3]

- [ ] Remove all domain jargon [S p137].
- [ ] Write one or more **{action, target}** pairs. Actions are three independent choices [S p131]:
  - **analyze** → consume: *discover* (generate / verify hypotheses) · *present* (communicate) ·
    *enjoy*; produce: *annotate* · *record* · *derive*;
  - **search** (2×2 by target known / location known [S p125–129; B13]):
    *lookup* (both known) · *locate* (target known, location unknown) ·
    *browse* (location known, target unknown) · *explore* (neither known);
  - **query**: *identify* (one) · *compare* (some) · *summarize* (all).
- [ ] **Targets** [S p105, p111]: all data → trends, outliers, features; one attribute →
      distribution, extremes; many attributes → dependency, correlation, similarity; network →
      topology, paths; spatial → shape.
- [ ] For a dashboard or a compound question, write a **task chain**: the output of one subtask is
      the input of the next (e.g. derive a rate → filter → summarize) [S p110].
- [ ] Iterate: first pass data, first pass task, second pass data…

## Step 4 — Write the what–why–how table

```
| # | What (in → out) | Why (action; target) | How (marks · channels · arrange/map · manipulate/facet/reduce) |
```
- [ ] One row per subtask; derived attributes marked "(derived)" in *What*.
- [ ] *How* is left to fill in step 5. Deliver the table before writing any chart code.

## Step 5 — How: choose the idiom, spatial position first (Ch 5, 7–14)

- [ ] **a.** Give the attribute most important to the task the best channel of its type: ordered →
      **position on a common scale**; categorical → **spatial region**. Assign the remaining
      attributes down the effectiveness ranking (`channel-effectiveness.md`). "Spatial position
      ranks high for both" [S p166].
- [ ] **b.** Arrangement by **number of keys** [S p242]: 0 → scatterplot; 1 → bar (categorical key)
      or line (ordered key); 2 → heatmap / matrix; many → partition into small multiples, a
      trellis, or recursive subdivision.
- [ ] **c.** Mark constraints [S p158]: points leave size and shape free; lines fix one size
      dimension; interlocking areas (choropleth, treemap) fix size, shape and position, so nothing
      else can be size-coded. Ask: "can I size-code another attribute?"
- [ ] **d.** If items or attributes exceed what the idiom scales to (`question-to-idiom.md`),
      add **Reduce** (filter, aggregate) or **Facet** (partition, juxtapose) before adding channels.
- [ ] **e.** Name the design-choice family used in *How*: Encode (arrange space; map color and
      other channels) · Manipulate (change, select, navigate) · Facet (juxtapose, partition,
      superimpose) · Reduce (filter, aggregate, embed) [S p387, p472, p605].

## Step 6 — Validate: the immediate validation the nested model allows [P09; S p22–32]

- [ ] **Expressiveness**: no ordered attribute on an identity channel (hue for a quantity); no
      categorical attribute on a magnitude channel (luminance ramp for unordered categories, a
      line connecting unordered categories); the encoding implies no order or magnitude the data
      lacks.
- [ ] **Effectiveness**: the task's key comparison uses **aligned position or length**. If it uses
      angle, area, volume or color, write the justification.
- [ ] **Discriminability**: ≤ 6–12 hues including background and highlights; ≤ 3–4 levels of
      saturation or luminance on small marks [S p169, color slides].
- [ ] **Separability**: no area + hue on small marks (interference); no width + height carrying
      two attributes (perceived as one area); no red + green pair.
- [ ] **Rules of thumb** (`channel-effectiveness.md` §3): unjustified 3D? Unjustified 2D layout
      where a list serves lookup? Memory used where eyes could compare (animation instead of
      small multiples)? No overview?
- [ ] **Color**: no rainbow for ordered data; diverging only with a real midpoint; never hue
      alone; luminance contrast for text and fine detail.
- [ ] **Labels** [S p238]: meaningful title, labelled axes and panes, legend for everything
      plotted, no scientific notation.
- [ ] Then write the **unvalidated downstream threats** honestly: *wrong problem* (level 1) and
      *wrong abstraction* (level 2) can only be checked with real users doing their own work; a
      lab study or adoption measurement has not happened. Do not call a heuristic pass "validated"
      [P09: immediate validations "only offer partial evidence of success"; "computational
      benchmarks do not confirm idiom design", "lab studies do not confirm task abstraction" S p32].

## Step 7 — Interaction (Manipulate / Facet / Reduce), only if the static view cannot answer

- [ ] Overview → zoom / filter → details on demand (Shneiderman 1996, adopted by Munzner as a rule
      of thumb). Tooltips are **details only**: "assume nobody will see it"; never put overview
      information only in a tooltip.
- [ ] Linked highlighting, bidirectional, across juxtaposed views ("almost always better");
      cross-filtering with scented widgets.
- [ ] Reorder by a data attribute to find extremes or trends; change the alignment of stacked bars
      for flexible comparison.
- [ ] Animated transitions between **two** states only; small multiples for many states.
- [ ] Response budget [S Ch 6]: 0.1 s hover highlight · 1 s click · 10 s heavy work, with progress.
- [ ] Dashboards: most readers do not interact (NYT logs: about 90 % never went beyond scrolling
      [S p496]). Everything important is visible with zero interaction.

## Step 8 — Algorithm (nested-model level 4)

- [ ] Check the data volume against the idiom's scalability limit (`question-to-idiom.md`, last
      column) and the query / render cost: the "too slow" threat [P09]. Aggregate or sample server-side
      before rendering millions of marks.

---

## Output contract

1. The table (step 4, with *How* filled after step 5) appears in the reply **before** the chart.
2. The validation result (step 6) is one short paragraph: what passed, what was justified, and
   the explicit sentence that downstream validation has not happened.
3. Interaction (step 7) is listed only where it was added, with the task it serves.
