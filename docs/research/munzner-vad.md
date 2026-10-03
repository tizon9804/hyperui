# Munzner VAD: research notes for a chart/dashboard decision skill

Researched 2026-10-03. Sources: Munzner's official book page, the full official slide deck
(`vadallslides-2021.pdf`, 689 slides, "Last change: 4 Oct 2021"; I extracted its text and read it),
the Nested Model paper (InfoVis 2009, full text read), Brehmer & Munzner 2013 (full text read),
the official errata, and Munzner's UBC course pages.
I could not read the book text itself, because no free chapter PDF exists on the official site (see §5).
Tags: **[S]** = verified in the official slides; **[P09]** = Nested Model paper; **[B13]** = Brehmer &
Munzner 2013; **[E]** = official errata; **[2nd]** = secondary/teaching source only; **[UNVERIFIED]** = not
confirmed against a primary source.

---

## 1. Framework summary

### 1.1 Definition and premise [S p4–14]
- "Computer-based visualization systems provide visual representations of datasets designed to help
  people carry out tasks more effectively."
- Vis fits when the goal is to augment human capabilities rather than replace people with automatic
  decision-making. It is not needed when a trusted fully automatic solution exists.
- Show the data, not only summaries, because summaries hide things (Anscombe's quartet).
- There are three resource limits: computational, display ("pixels are precious"; information density),
  and human (time, memory, attention).

### 1.2 What–Why–How [S p17, p48, p105, p138]
- **What** = data abstraction. **Why** = task abstraction. **How** = idiom, which is the visual encoding plus the
  interaction design choices.
- A task is written as an **{action, target}** pair, for example "discover distribution", "compare trends",
  "locate outliers" or "browse topology" [S p106].
- Write it as a table (book Figure 3.9 does this: "what-why-how analysis" [E p60]) with
  rows *What* (In/Out), *Why* (actions + targets) and *How* (design choices). A complex task becomes a
  **chain of subtasks** in which the output of one is the input of the next. For example: Task 1 derives a
  quantitative attribute, and Task 2 uses it to Filter → Summarize topology [S p110].

### 1.3 Nested model (Ch 4; P09) [S p22–32, P09 §3]
Four levels. The output of each level is the input of the level below it.

| Level (book name) | 2009 paper name | Threat (P09 wording) | Immediate validation | Downstream validation |
|---|---|---|---|---|
| Domain situation: who the users are, their questions and data | domain problem characterization | **Wrong problem**: "they don't do that" (problem mischaracterized) | observe and interview target users | measure adoption rates (a weak signal) |
| Data/task abstraction: what is shown, why the user looks | data/operation abstraction design | **Wrong abstraction**: "you're showing them the wrong thing" | (none immediate) | target users doing *their own* work give anecdotes of utility; field study of the deployed system |
| Visual encoding/interaction idiom: how to draw and manipulate | encoding/interaction technique design | **Ineffective encoding/interaction**: "the way you show it doesn't work" | **justify the design against perceptual/cognitive principles** (heuristic eval, expert review) | lab study (time/errors); qualitative or quantitative analysis of result images |
| Algorithm: efficient computation | algorithm design | **Wrong algorithm**: "your code is too slow" | analyze computational complexity | measure system time and memory |

- An upstream error "inevitably cascades to all downstream levels". Downstream effects cascade, and
  upstream refinement is iterative [S p24].
- **Avoid mismatches** [S p32]: "computational benchmarks do not confirm idiom design" and "lab studies do
  not confirm task abstraction".
- P09: immediate validations "only offer partial evidence of success". Informal usability studies are
  *not* validation.
- Design process order [S p119]: characterize domain → map domain task to abstract task and domain data to
  data abstraction → identify or create the idiom → identify or create the algorithm.
- *For a skill:* the model can only do the **immediate** validations: question the domain assumption,
  justify encoding against principles (§1.6) and estimate cost. It should say plainly that downstream
  validation (real users, adoption) has not happened.

### 1.4 What: data abstraction (Ch 2) [S p46–48, p62–69, p242]
- **Data types:** items, attributes, links, positions, grids. These are not programming types.
- **Dataset types:** **tables** (flat: item per row, attribute per column; multidimensional: several
  keys), **networks & trees** (nodes = items, links), **fields** (continuous; grid of positions with values
  per cell), **geometry** (spatial; positions/shape), **clusters, sets, lists** (items only). The slide p46
  title says "Three major datatypes" (tables, networks, spatial), while the summary figure lists all five
  (see §5).
- **Dataset availability:** static vs dynamic (streaming).
- **Attribute types:** **categorical** vs **ordered** → **ordinal** | **quantitative**.
  **Ordering direction:** sequential, diverging, cyclic.
- **Keys vs values** [S p242]: a key is an independent attribute used as a unique index (1 key = simple
  table; several keys = multidimensional table). A value is a dependent attribute. Table arrangements
  are classified by the number of keys: 0 keys (scatterplot), 1 key (bar, line), 2 keys (heatmap/matrix),
  many keys (recursive subdivision). Quantitative attributes are "typically unsuitable as keys" [E p34].
- **Semantics vs type:** the same numbers mean different things. Domain meaning has to be stated explicitly [S p59].
- **Derive** [S p109]: "don't necessarily just draw what you're given!" Example: trade balance = exports −
  imports. Derive is one of the four strategies for handling complexity (derive, manipulate, facet, reduce).

### 1.5 Why: task abstraction (Ch 3) [S p105–137; B13 §3]
**Actions** are three *independent* choices, one per level [S p131].
- **Analyze**
  - **Consume:** *discover* (aka explore; generate/verify hypotheses), *present* (aka explain;
    communicate or tell a story), *enjoy* (casual or social use).
  - **Produce:** *annotate*, *record*, *derive*. Slides list "tag" as an example under annotate.
- **Search**: a 2×2 of whether the target is known and whether its location is known [S p125–129; B13]

  |  | target known | target unknown |
  |---|---|---|
  | **location known** | **lookup** (word in a dictionary) | **browse** (books on a shelf) |
  | **location unknown** | **locate** (keys in your house; a node in a network) | **explore** (cool neighbourhood in a new city) |
- **Query**: how much of the data matters? *identify* = one target, *compare* = some, *summarize* = all
  (also called overview). B13 note: after lookup/locate, identify returns *characteristics*; after
  browse/explore it returns *references*.

**Targets** [S p105, p111]:
- *All data*: trends, outliers, features
- *Attributes*: one attribute → distribution, extremes; many → dependency, correlation, similarity
- *Network data*: topology, paths
- *Spatial data*: shape

Rule of thumb [S p137]: "systematically remove all domain jargon". Iterate between data and task abstraction (first pass data, first pass
task, second pass data, and so on). The task may require transforming or deriving the data.

### 1.6 Marks and channels (Ch 5) [S p143–195]
- **Marks** are geometric primitives for items: points (0D), lines (1D), areas (2D); volume (3D) is rare. Marks for
  **links** are *connection* (lines) and *containment* (nested areas).
- **Channels** control mark appearance from attributes: position (horizontal, vertical, both), color, shape,
  tilt, size (length, area, volume), and others.
- **Marks constrain channels** [S p158]: points leave size and shape free; lines fix one size dimension (width is still
  free); **interlocking areas** (e.g. choropleth, treemap) fix size, shape and position, so nothing else
  can be size-coded. Quick check: "can you size-code another attribute?"
- **Redundant encoding** (e.g. length + luminance) sends a stronger message but uses up channels.
- **Expressiveness:** match channel type to data type. Use *magnitude* channels ("how much?") for **ordered**
  attributes and *identity* channels ("what?") for **categorical** ones [S p161–164]. Book wording, as quoted
  by Munzner-based teaching notes [2nd]: "the visual encoding should express all of, and only, the
  information in the dataset attributes."
- **Effectiveness:** some channels are better than others, because they differ in perceptual accuracy [S p161–165].
  Book wording [2nd]: "the importance of the attribute should match the salience of the channel". Put
  the most important attribute on the best channel.
- **Effectiveness rankings (verbatim order, slide p162 = book Fig 5.1/5.6):**
  - *Magnitude channels (ordered attributes)*: position on common scale > position on unaligned scale >
    length (1D size) > tilt/angle > area (2D size) > depth (3D position) > color luminance > color
    saturation > curvature > volume (3D size).
  - *Identity channels (categorical attributes)*: spatial region > color hue > motion > shape.
  - "Spatial position ranks high for both" [S p166].
- **Channel properties** [S p169]:
  - accuracy (Stevens' power law; Cleveland & McGill 1984; Heer & Bostock 2010)
  - discriminability: how many usable steps the channel offers (e.g. linewidth gives only a few bins)
  - separability vs integrality: position+hue are fully separable, size+hue have some interference, width+height
    are integral (perceived as area), red+green have major interference
  - **popout**: parallel, preattentive search on a *single* channel; combinations need serial search
- **Grouping:** containment, connection, proximity (same spatial region), similarity (same categorical channel
  values) [S p167].
- **Accuracy factors:** alignment, distractors, distance, common scale. Perception is mostly relative (Weber's
  law), so alignment to a common frame and scale improves accuracy [S p187–191].

### 1.7 Rules of thumb (Ch 6) [S p197–239, summary p239]
"Guidelines and considerations, not absolute rules."
1. **No unjustified 3D.** The reasons are power of the plane, disparity of depth (we see in "2.05D"), occlusion hides
   information, perspective distortion interferes with every size channel, and tilted text isn't legible. 3D bars are
   "very difficult to justify"; faceting into 2D is almost always better. 3D is legitimate for true 3D
   spatial data when the task is shape perception, and needs careful justification for abstract data.
2. **No unjustified 2D.** Don't draw a network layout when a text list serves the task, because a list has higher density
   and easier label lookup. A layout earns its place when topology or context matters to the task. Be careful
   with search results, document collections and ontologies.
3. **Eyes beat memory.** Comparing side-by-side views is easier than comparing against memory. Animation is
   good for choreographed storytelling and for transitions between two states, and poor for many states with changes
   everywhere. Consider small multiples instead.
4. **Resolution over immersion.** Pixels are the scarcest resource. VR is hard to justify for abstract data; AR/MR
   holds more promise.
5. **Overview first, zoom and filter, details on demand.** This is *Shneiderman's* mantra (1996), adopted as a rule
   of thumb. An overview is a summary and "a microcosm of the full vis design problem".
6. **Responsiveness is required.** Response time bands are 0.1 s for perceptual processing (hover highlight), 1 s for immediate response
   (click), and 10 s for brief tasks (dialog, file load). Highlight without a full redraw, use an hourglass or progress bar for
   multi-second work, and keep the frame rate when there are many items.
7. **Function first, form next.** It is usually impossible to add function after the fact, while aesthetics can be
   improved later and still matter (visual hierarchy, alignment, Gestalt). Labelling best practice [S p238]: a meaningful title,
   labelled axes and panes, a legend for everything plotted, and no scientific notation in most cases.

### 1.8 How: design-choice families (Ch 7–14) [S p387, p472, p605]
The book's *How?* tree has **four top-level families**, each with sub-choices:
- **Encode**
  - **Arrange space**: *express* values; *separate, order, align* regions; *use* given spatial
    data. Axis orientation is rectilinear, parallel or radial; layout density can be dense/space-filling.
  - **Map** color and other channels. Color = hue (identity), saturation and luminance (magnitude),
    transparency; also size, angle, curvature, shape, and motion (direction, rate, frequency).
- **Manipulate**
  - **Change** over time: change the encoding, parameters, order or alignment, and use animated transitions.
  - **Select**: click vs hover, highlight via color, outline, size or shape.
  - **Navigate**: item reduction by zoom (geometric or semantic), pan, or constrained navigation;
    attribute reduction by slice, cut or project.
- **Facet**
  - **Juxtapose** and coordinate views. Views share encoding (same or different = multiform), share data (all, subset or
    none) and share navigation. All + same = redundant; subset = overview/detail; none + same = small
    multiples; all + different = multiform with linked highlighting. Bidirectional linking is "almost always
    better".
  - **Partition** into views or regions by attribute. The order of splits decides which comparisons are easy.
  - **Superimpose** layers: two layers are achievable and three need careful design. Use different, non-overlapping channels for each
    layer. Superimpose suits local tasks, juxtapose suits global tasks (Javed 2010).
- **Reduce**
  - **Filter** (items or attributes). Pro: intuitive. Con: "out of sight, out of mind".
  - **Aggregate**: histogram, boxplot, clustering, dimensionality reduction. Con: signal loss. For maps, beware
    MAUP (zone and scale effects).
  - **Embed** (focus+context): elide data, superimpose a layer, or distort geometry. Distortion impairs length
    comparisons but leaves topology readable.

**Color specifics** [S p393–447]:
- Decompose color into luminance, saturation and hue.
- Categorical color: **6–12 bins** including background and highlights. For small separated regions use saturation or luminance with 2 bins (3–4 maximum).
- Rainbow is a poor default for ordered data (perceptually unordered and nonlinear). Use monotone-luminance maps (viridis/magma). A segmented saturated rainbow is fine for categorical data.
- Diverging maps need a meaningful midpoint, a neutral midpoint color and saturated ends.
- Bivariate maps are best when one direction is binary.
- About 8% of men are red/green color deficient. Don't encode by hue alone; add luminance or shape redundantly. Blue/orange is a safe pair.
- Luminance contrast is needed for fine detail and legible text.
- Size: aligned length is best, area is acceptable, volume is poor.

---

## 2. Procedure for a model (data + question → chart)

1. **Domain (level 1).** Restate who will use it, the decision they are making, and the domain question in their words.
   Flag the *wrong-problem* risk: "is this a question they actually ask?" If unknown, state it as an assumption.
2. **What (data abstraction).** List the dataset type (table, network/tree, field, geometry, set/list) and whether it is static or dynamic.
   For each attribute give: name → categorical / ordinal / quantitative (with sequential, diverging or cyclic direction), key or value,
   cardinality (number of levels) and item count. Note what could be **derived** (rates, differences, index-to-baseline,
   ranks, bins, clusters, totals). The data to show is often derived.
3. **Why (task abstraction).** Remove jargon and write one or more {action, target} pairs:
   analyze (discover / present / enjoy / produce), search (lookup / locate / browse / explore, decided by target and location known or
   unknown), query (identify = 1, compare = some, summarize = all) + target (trend, outlier, feature,
   distribution, extreme, correlation, dependency, similarity, topology, path, shape). For dashboards or
   complex questions, write a **task chain** in which each step's output feeds the next.
4. **Write the what–why–how table** with columns What (In / Out, including derived) | Why (actions; targets) | How
   (to be filled in). One row per subtask.
5. **Choose the idiom (How), with spatial position first.**
   a. Give the most important attribute for the task the best expressive channel: position on a common
   scale for ordered data, spatial region for categorical data. Assign the remaining attributes down the ranking (§1.6).
   b. Choose the arrangement by the number of keys: 0 → scatterplot; 1 → bar (categorical key) or line (ordered key);
   2 → heatmap/matrix; many → partition into small multiples, a trellis, or recursive subdivision.
   c. Check mark constraints: interlocking areas leave no free size channel.
   d. If items or attributes exceed what the idiom scales to (see §3), add **Reduce** (filter or aggregate) or
   **Facet** (partition or juxtapose) before adding more channels.
6. **Validate (the immediate validation the nested model allows).** Run this checklist:
   - Expressiveness: is any ordered attribute on an identity channel (hue for a quantity)? Is any categorical
     attribute on a magnitude channel (luminance ramp for unordered categories, or a line connecting
     unordered categories)? Does the encoding imply order or magnitude that the data does not have?
   - Effectiveness: is the key comparison of the task done by **aligned position or length**? If it relies on angle,
     area, volume or color, justify why.
   - Discriminability: are there more than 6–12 hues, or more than 3–4 levels of saturation/luminance on small marks?
   - Separability: is area combined with hue on small marks, or width with height?
   - Rules of thumb: unjustified 3D? Unjustified network layout where a list would do? Memory used where eyes
     could compare (animation instead of small multiples)? No overview?
   - Color: no rainbow for ordered data; diverging only with a real midpoint; not hue alone; luminance
     contrast for text.
   - Labels: title, axes, legend, number format.
   - Then name the **unvalidated downstream risks** (wrong problem or abstraction) honestly.
7. **Choose the interaction (Manipulate / Facet / Reduce)** only when the static view cannot answer the task:
   - overview → zoom/filter → details on demand. Tooltips are details *only* ("assume nobody will see it";
     never put overview information only in a tooltip).
   - linked highlighting (bidirectional) across juxtaposed views; cross-filtering with scented widgets.
   - reorder by a data attribute to find extremes or trends; change alignment of stacked bars for flexible
     comparison.
   - animated transitions between two states only; small multiples for many states.
   - meet the response budget of 0.1 s for hover, 1 s for click, 10 s for heavy operations (with progress).
   - for dashboards, remember that many users do not interact (NYT logs: about 90% didn't interact beyond scrolling
     [S p496]). Anything important must be visible without interaction.
8. **Algorithm level.** Check the data volume against the idiom's scalability and query or render cost (the "too slow" threat).

---

## 3. Mapping: analytical question → idiom → channels → pitfalls
Scalability figures are from the slides [S]. "Pitfalls" cites the slides where possible.

| Question (task) | Idiom(s) | Channels / marks | Pitfalls |
|---|---|---|---|
| How do values compare across categories? (compare/lookup values; 1 categorical key + 1 quantitative value) | **Bar chart**, sorted by value (or alphabetically for lookup) | line marks; aligned length; spatial region per key | 3D bars [S p206]; a non-zero baseline breaks length [UNVERIFIED in slides, standard practice]; dozens to hundreds of bars at most [S p257] |
| How does a value change over an ordered key or time? (find trend) | **Line chart** (dot/line) | points + connection marks; aligned position | connecting *categorical* keys implies a trend that isn't there [S p262]; hundreds of key levels |
| How do several series compare in relative change? | **Indexed line chart** (derive index to baseline) | as line chart, derived value | absolute vs normalized confusion; state the baseline [S p267] |
| Two measures on one time axis? | **Avoid dual-axis**; use juxtaposed aligned charts or a connected scatterplot | position | dual axes are "very easy to mislead", acceptable only if commensurate [S p304]; connected scatterplots are engaging but correlation is unclear [S p305] |
| What is the part-to-whole? (summarize; few parts) | **Normalized stacked bar**; **pie/donut** only for 2 to a few levels | length (aligned first segment) / angle-area | pies are "dubious for several levels, terrible for many" [S p285]; stacked segments other than the first are unaligned, so hard to compare (10–12 segments max) [S p258]; coxcomb is nonlinear in area [S p281] |
| How are values distributed? (summarize distribution, 1 attribute) | **Histogram**; **boxplot** (many items or groups) | derived bins → bar lengths; 5-number summary | bin size changes the pattern dramatically [S p538]; boxplots hide multimodality [UNVERIFIED as a slide claim, standard caveat] |
| Are two quantities related? (correlation, outliers, clusters) | **Scatterplot**; **continuous scatterplot / density** when overplotted | points; horizontal + vertical position (+ hue for category) | hundreds of items before overplotting [S p246]; use aggregation for millions [S p544] |
| How do many quantitative attributes relate? | **SPLOM** (≈ a dozen attributes); **parallel coordinates** (dozens; reorderable axes); **dimensionality reduction** → scatterplot | position | parallel coordinates show patterns only between neighbouring axes, need training, and axis order is hard [S p293–295]; DR axes have no meaning |
| Values over two categorical keys? (find clusters, outliers in a matrix) | **Heatmap**, **cluster heatmap** (reorder by hierarchy) | area marks in a matrix; color (sequential or diverging luminance) | color is a low-accuracy magnitude channel, so only about 10 discriminable levels [S p271]; order rows and columns by data |
| Change between two states or ranks? | **Slopegraph** | point + line; two vertical positions | dozens of items [S p269] |
| Schedule, durations, overlaps? | **Gantt** | line length = duration; horizontal position = start | dozens of rows [S p268] |
| How does the pattern differ across groups? (compare across subsets) | **Small multiples / trellis** (partition; order panels by median) | same encoding in every panel; shared aligned scales | the split order decides which comparison is easy (grouped vs small-multiple bars) [S p518]; superimposing works only up to a few dozen lines [S p526] |
| Cyclic pattern (hour of day, season)? | radial / star glyphs, cyclic colormap | angle, radial position | radar/radial plots: "avoid unless data is cyclic" [S p277]; angle < length in accuracy |
| Hierarchy with sizes (e.g. disk usage)? | **Treemap** (only leaves visible); **icicle/sunburst** (inner nodes visible) | containment/position; area | area is a mid-ranked channel; treemaps make leaf comparison hard [S p333–336] |
| Network structure, paths, clusters? (explore topology, locate paths) | **Node-link** (force-directed, about 1K–10K nodes); **adjacency matrix** when links ≫ nodes | connection marks; matrix cells | layout position has no meaning; long edges are salient; hairball. The matrix is better "when the number of links is more than roughly four times the number of nodes" [E p206]; "no unjustified 2D", so use a list if label lookup is the task [S p213] |
| Spatial pattern of a rate per region? | **Choropleth** (only if spatial relations are central) | given geometry; sequential *segmented* luminance | large areas dominate visually; MAUP [S p545]; map **rates, not raw counts** [UNVERIFIED in slides, standard cartography]; consider symbol maps [S p364] or grid cartograms [S p368] |
| Spatial counts or magnitudes? | **Proportional symbol map**, dot density | size (area) / dots; keep geography as background | area judgement is less accurate; overlap |
| Find a known item among many (lookup/locate)? | sorted/reorderable list or table, search + linked highlight | spatial position (order) | a fancy layout makes lookup slower than a text list [S p213, p515] |
| Dashboard: many measures, monitor and drill down | overview (aggregate) + detail views; linked highlighting; filters with scented widgets | aligned position wherever possible | overview only in tooltips; too many views ("open research question" [S p515]); hue reused across views with different meanings; animation for many states |

---

## 4. References (all opened during this research)

| Resource | URL | Free? | Notes |
|---|---|---|---|
| Book page | https://www.cs.ubc.ca/~tmm/vadbook/ | page free; **book not free** | links all slides and videos; no free chapter PDF |
| **All book slides (689)**, PDF/PPTX/Key | https://www.cs.ubc.ca/~tmm/talks/vad/vadallslides-2021.pdf (68 MB) | **free** | primary source used here; 16-up: `vadallslides-2021-4x4.pdf` |
| Shorter decks | https://www.cs.ubc.ca/~tmm/talks/vad/VAD-2021.pdf , https://www.cs.ubc.ca/~tmm/talks/vad/fullday-vis21.pdf , https://www.cs.ubc.ca/~tmm/talks/vad/436V-22.pdf | free | linked from the book page (listed, not individually opened) |
| Video lectures (6.5 h, 22 segments, whole book, Oct 2021) | https://www.youtube.com/watch?v=1GhZisgc6DI&list=PLT4XLHmqHJBeB5LwmRmo6ln-m7K3lGvrk | **free** | per chapter: Ch1 15:39, Ch2 27:34, Ch3 14:21, Ch4 9:06+4:57, Ch5 12:36+16:53, Ch6 31:42, Ch7 31:36+20:57 ... |
| IEEE VIS 2021 tutorial / 436V-22 playlist | https://www.youtube.com/watch?v=1GhZisgc6DI&list=PLT4XLHmqHJBdB24LAQPk_PV7wrwpJFh5a | free | the book page links this one URL for both |
| Book figures (113 diagrams, CC-BY-4.0) | https://www.cs.ubc.ca/~tmm/vadbook/eamonn-figs/alldiagrams.zip | free | includes the what/why/how and channel-ranking diagrams |
| Errata | https://www.cs.ubc.ca/~tmm/vadbook/errata.html | free | (the `talks/vad/errata.html` link returns 404) |
| Nested Model paper (InfoVis 2009) | https://www.cs.ubc.ca/labs/imager/tr/2009/NestedModel/ → `NestedModel.pdf` | **free** | read in full |
| Brehmer & Munzner 2013 typology | https://www.cs.ubc.ca/labs/imager/tr/2013/MultiLevelTaskTypology/brehmer_infovis13.pdf | **free** | read in full; the `~brehmer/` URL returns 403 |
| CPSC 547 (2022) grad course | https://www.cs.ubc.ca/~tmm/courses/547-22/ | free page | the book is free via the UBC library for students only; readings are free papers |
| CPSC 436V (2020) ugrad course | https://www.cs.ubc.ca/~tmm/courses/436V-20/ | free page | 2022 page links from 547-22 (436V-22 dir returned 404 to curl) |
| Talks index | https://www.cs.ubc.ca/~tmm/talks.html | free | |
| Munzner-based lecture notes (Univ. Vienna) | https://teaching.vda.univie.ac.at/vis/23s/LectureNotes/04_visual_encoding_principles.pdf | free | [2nd] source of the expressiveness/effectiveness wording |
| Publisher TOC | https://www.routledge.com/Visualization-Analysis-and-Design/Munzner/p/book/9781466508910 | paid book | (not opened, only linked) |

Do **not** point the skill at the Scribd, kupdf, dokumen.pub or GitHub copies that web search returns for "free pdf".
Those are unauthorized copies of the book.

---

## 5. Where popular summaries differ from the book (don't propagate)

1. **Task typology versions differ.** In **Brehmer & Munzner 2013**, *discover* means "generate / verify";
   *annotate, import, derive, record* are **how → introduce** methods; and *how* = encode | manipulate (select,
   navigate, arrange, change, filter, aggregate) | introduce. The **book** moved annotate/record/derive under
   **why → analyze → produce**, dropped "introduce/import", and reorganized *how* into Encode / Manipulate /
   Facet / Reduce. Summaries often mix the two. The skill should use the **book** version and cite B13
   only for the definitions of search and query.
2. **"Five families".** The book's How tree has **four** top-level families (Encode [arrange, map], Manipulate,
   Facet, Reduce). "Arrange space" and "map color" are the two halves of Encode. Separately, the four
   *strategies for handling complexity* are **derive, manipulate, facet, reduce** [S p109].
3. **Dataset types count.** Slide p46 says "three major datatypes" (tables, networks, spatial), while the
   summary figure shows **tables, networks & trees, fields, geometry, clusters/sets/lists**. Many
   summaries say "four". Use the five-item figure.
4. **Channel ranking.**
   - Luminance and saturation are listed as **two consecutive entries** (luminance first) and are
     explicitly *not separable* from each other [S p411].
   - Summaries sometimes list hue as a magnitude channel, or put "direction" or "texture" in the list. Munzner's list has
     neither: texture and density are not ranked [UNVERIFIED for the book text, absent from the slides].
   - The ranking is Munzner's synthesis of Cleveland & McGill 1984, Heer & Bostock 2010 and Mackinlay. The
     exact order below the top few (e.g. motion vs shape, curvature vs volume) is **not** individually
     established by experiments [UNVERIFIED claim of strict ordering]. Treat it as tiers, not a total order.
5. **Overview-first mantra** is **Shneiderman (1996)**, not Munzner. She adopts it as a rule of thumb.
6. **Expressiveness/effectiveness** derive from Mackinlay (1986). Some teaching notes pair them with
   Tufte's lie factor and data-ink ratio (e.g. the Vienna notes). Those are **not** Munzner's framing.
7. **Nested-model level names changed.** P09 used "domain problem characterization / data-operation
   abstraction / encoding-interaction technique / algorithm"; the book uses "domain situation / data-task
   abstraction / visual encoding-interaction idiom / algorithm". Errata p76: delete the claim that red-line
   length in Fig 4.5 shows the magnitude of dependencies, which the 2009 paper still contains.
8. **Matrix vs node-link threshold**: the book originally inverted it. Per the errata the matrix wins "when the
   number of links is more than roughly four times the number of nodes" (slide: force-directed is fine for
   E < 4N).
9. **Pie charts**: the slides are nuanced. Pies are "not so bad for two (or few) levels" in part-to-whole tasks,
   "dubious for several levels", "terrible for many", and donuts are no worse than pies (Skau & Kosara 2016).
   Summaries that say "never pie" overstate it.
10. **Free chapter**: no free chapter-1 PDF is on the official site (as of this check). Free official
    material is the slides, videos, figures and the two papers. The UBC library ebook is free only for UBC users.

### Items still unverified against the book text
- The exact book wording of the expressiveness/effectiveness principles (corroborated only by [2nd] teaching notes).
- Book figure numbers (5.1/5.6 for the rankings, 3.9 for what-why-how) are inferred from errata and memory, not seen.
- Pitfalls marked [UNVERIFIED] in §3 (boxplot multimodality, choropleth rates vs counts) are standard practice and not
  taken from Munzner's slides.
