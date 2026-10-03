# Question → idiom → channels → pitfalls (with scalability limits)

Eighteen rows from Munzner's *Visualization Analysis and Design* (Ch 7–14). Tags: [S pN] =
official slide deck page, [E pN] = errata, [UNVERIFIED] = standard practice not taken from the
slides. Use it in step 5 of `munzner-procedure.md`: find the row whose question matches the
{action, target} pair, then run the channels through `channel-effectiveness.md`.

Reading the *Scales to* column: when the data exceeds it, add Reduce (filter, aggregate) or Facet
(partition, juxtapose) before adding channels.

| # | Question (task) | Idiom(s) | Channels / marks | Pitfalls | Scales to |
|---|---|---|---|---|---|
| 1 | How do values compare across categories? (compare / lookup values; 1 categorical key + 1 quantitative value) | **Bar chart**, sorted by value (alphabetical only when the task is lookup by name) | line marks; aligned length; one spatial region per key | 3D bars [S p206]; a non-zero baseline breaks the length channel [UNVERIFIED, standard practice] | dozens to hundreds of bars [S p257] |
| 2 | How does a value change over an ordered key or time? (find trend) | **Line chart** (dot + line) | point marks + connection marks; aligned vertical position over an ordered horizontal key | connecting *categorical* keys implies a trend that does not exist [S p262] | hundreds of key levels |
| 3 | How do several series compare in relative change? | **Indexed line chart** (derive index to a baseline, e.g. = 100 at t0) | as line chart, on the derived value | absolute vs normalized confusion; state the baseline in the title [S p267] | a few to a dozen series |
| 4 | Two measures on one time axis? | **Avoid dual axes**; juxtaposed aligned charts (shared x), or a connected scatterplot | position; shared horizontal scale | dual axes are "very easy to mislead", acceptable only when the measures are commensurate [S p304]; connected scatterplots are engaging but the correlation reads poorly [S p305] | two measures |
| 5 | What is the part-to-whole? (summarize; few parts) | **Normalized stacked bar**; **pie / donut** only for two to a few levels | length (the first segment is aligned) / angle + area | pies: "not so bad" for few levels, "dubious for several, terrible for many" [S p285]; stacked segments other than the first are unaligned, hence hard to compare [S p258]; coxcomb / polar area is nonlinear [S p281] | pie: 2–few parts; stacked: 10–12 segments max [S p258] |
| 6 | How are values distributed? (summarize distribution, 1 attribute) | **Histogram**; **boxplot** for many items or many groups | derived bins → aligned bar lengths; five-number summary as line + area | bin size changes the picture dramatically [S p538]; boxplots hide multimodality [UNVERIFIED, standard caveat] — add a violin or dot strip when it matters | histogram: any n (bins fixed); boxplot: dozens of groups |
| 7 | Are two quantities related? (correlation, outliers, clusters) | **Scatterplot**; continuous scatterplot / density when overplotted | point marks; horizontal + vertical position; hue for one categorical attribute | overplotting [S p246]; aggregation needed for millions [S p544] | hundreds of items before overplotting |
| 8 | How do many quantitative attributes relate? | **SPLOM** (≈ a dozen attributes); **parallel coordinates** (dozens, reorderable axes); **dimensionality reduction** → scatterplot | position | parallel coordinates show patterns only between neighbouring axes, need training, and axis order is hard [S p293–295]; DR axes carry no meaning | SPLOM ~12 attributes; PC dozens of attributes, hundreds of items |
| 9 | Values over two categorical keys? (clusters, outliers in a matrix) | **Heatmap**; **cluster heatmap** (rows and columns reordered by a hierarchy) | area marks in a matrix; color (sequential or diverging luminance) | color is a low-accuracy magnitude channel: about 10 discriminable levels [S p271]; order rows and columns by the data, not alphabetically | hundreds × hundreds cells; ~10 color levels |
| 10 | Change between two states or two rankings? | **Slopegraph** | point + line marks; two aligned vertical positions | crossing lines get hard to follow past a few dozen items | dozens of items [S p269] |
| 11 | Schedule, durations, overlaps? | **Gantt** | line length = duration; horizontal position = start; one row per item | row count; use grouping or filtering past dozens | dozens of rows [S p268] |
| 12 | How does the pattern differ across groups? (compare across subsets) | **Small multiples / trellis** (partition; order panels by a data value such as median) | the same encoding in every panel; shared aligned scales | the split order decides which comparison is easy (grouped bars vs small-multiple bars) [S p518]; superimposing works only up to a few dozen lines [S p526] | dozens of panels; a few dozen superimposed lines |
| 13 | Cyclic pattern (hour of day, weekday, season)? | radial / star layout, cyclic colormap | angle, radial position | radial and radar plots: "avoid unless data is cyclic" [S p277]; angle is less accurate than length | one cycle of ≤ 24 steps reads well; otherwise a line chart with the cycle on x |
| 14 | Hierarchy with sizes (disk usage, budget tree)? | **Treemap** (only leaves visible); **icicle / sunburst** (inner nodes visible too) | containment / position; area for size | area is a mid-ranked channel; comparing leaves in a treemap is hard [S p333–336]; interlocking areas leave no free size channel | treemap: thousands of leaves; icicle: a few levels deep |
| 15 | Network structure, paths, clusters? (explore topology, locate paths) | **Node-link** (force-directed) for sparse graphs; **adjacency matrix** when links ≫ nodes | connection marks; matrix cells (area + color) | layout position carries no meaning; long edges are salient; hairball. Matrix wins "when the number of links is more than roughly four times the number of nodes" [E p206]; "no unjustified 2D": a list serves label lookup better [S p213] | node-link: about 1K–10K nodes while links < 4× nodes |
| 16 | Spatial pattern of a rate per region? | **Choropleth** (only if the spatial relations are central to the task) | given geometry; sequential *segmented* luminance ramp | large areas dominate visually; MAUP (zone and scale effects) [S p545]; map **rates, not raw counts** [UNVERIFIED in slides, standard cartography]; consider symbol maps [S p364] or grid cartograms [S p368] | a few hundred regions; 5–7 color classes |
| 17 | Spatial counts or magnitudes? | **Proportional symbol map**, dot density | size (area) for magnitude; dots for counts; geography as background | area judgement is less accurate; symbol overlap | hundreds of symbols |
| 18 | Find a known item among many (lookup / locate)? | sorted or reorderable **list / table**, search box + linked highlight | spatial position (order); text | a fancy layout makes lookup slower than a text list [S p213, p515] | thousands of rows with sort and search |

## Dashboard composition (many measures: monitor, then drill down)

- Overview (aggregates, derived KPIs) first, visible without any interaction; detail views
  below or beside it; linked highlighting; filters with scented widgets.
- Aligned position wherever possible; one hue = one category in every panel; shared scales inside
  a row of small multiples.
- Pitfalls: overview only in tooltips; too many views (how many is "an open research question"
  [S p515]); hue reused with different meanings across views; animation to compare many states.
