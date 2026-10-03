# Where popular summaries diverge from Munzner's book — never propagate these

Checked against the official slide deck (`vadallslides-2021.pdf`), the Nested Model paper
(2009), Brehmer & Munzner (2013) and the official errata. When explaining the framework or
justifying an idiom, use the **book** version described here. Tags: [S pN] slide page,
[E pN] errata page, [B13] 2013 paper, [P09] 2009 paper, [UNVERIFIED] not confirmed against a
primary source.

1. **Four *How* families, not five.** The book's *How?* tree is **Encode · Manipulate · Facet ·
   Reduce** [S p387, p472, p605]. "Arrange space" and "map color/channels" are the two halves of
   *Encode*, not families of their own. A different list of four is the **strategies for handling
   complexity**: derive, manipulate, facet, reduce [S p109]. Do not merge the two lists.

2. **Annotate / record / derive are *Why → analyze → produce*** in the book. In **Brehmer &
   Munzner 2013** they sat under *how → introduce* (annotate, import, derive, record), and *how*
   was encode | manipulate (select, navigate, arrange, change, filter, aggregate) | introduce.
   The book moved them, dropped "introduce / import", and reorganized *how* into the four
   families above. Summaries mix the two versions. Use the book's; cite B13 **only** for the
   definitions of search (lookup, locate, browse, explore) and query (identify, compare,
   summarize). In B13 *discover* is spelled out as "generate / verify" hypotheses.

3. **"Overview first, zoom and filter, then details on demand" is Shneiderman's (1996)**, not
   Munzner's. She adopts it as rule of thumb #5 [S Ch 6]. Attribute it correctly.

4. **Lie factor and data-ink ratio are Tufte's**, not part of Munzner's framework. Some teaching
   notes (e.g. the Vienna lecture notes) pair them with expressiveness / effectiveness, which
   themselves come from **Mackinlay (1986)**. Do not present Tufte's metrics as Munzner's.

5. **Nested-model level names changed between 2009 and the book.** P09: *domain problem
   characterization · data/operation abstraction design · encoding/interaction technique design ·
   algorithm design*. Book: *domain situation · data/task abstraction · visual encoding/interaction
   idiom · algorithm*. Use the book names; mention the paper's when citing P09. Errata p76 deletes
   the claim that the red-line length in Fig 4.5 shows the magnitude of dependencies — the 2009
   paper still contains it.

6. **Matrix vs node-link threshold (errata).** The book's first printing inverted it. Correct
   statement: the adjacency **matrix wins "when the number of links is more than roughly four
   times the number of nodes"** [E p206]; force-directed node-link is fine while E < 4N.

7. **Dataset types: use the five-item figure.** Slide p46 is titled "three major datatypes"
   (tables, networks, spatial), while the summary figure lists **tables · networks & trees ·
   fields · geometry · clusters/sets/lists**. Many summaries say "four". Use five.

8. **Channel ranking details.**
   - Luminance and saturation are **two consecutive entries** (luminance first) and are not
     separable from each other [S p411].
   - **Hue is not a magnitude channel**; "direction" and "texture" are not in Munzner's list
     [UNVERIFIED for the book text; absent from the slides].
   - The order below the top few entries (motion vs shape, curvature vs volume) is **not**
     individually established by experiments [UNVERIFIED as a strict total order]. Present the
     ranking as tiers, and never argue "angle beats area" as if it were a measured gap.

9. **Pie charts: the slides are nuanced, "never pie" overstates it.** Pies are "not so bad for two
   (or few) levels" in a part-to-whole task, "dubious for several levels", "terrible for many"
   [S p285]; donuts are no worse than pies (Skau & Kosara 2016). The real reason to prefer a bar
   for comparing parts is that angle and area rank below aligned length.

10. **There is no free chapter PDF** on the official site. Free official material = the full slide
    deck, the videos, the CC-BY figures and the two papers. The UBC library ebook is free only for
    UBC users. "Free PDF" search results are unauthorized copies (see `munzner-references.md`).

## Still unverified against the book text (say "(unverified)" if you must state them)

- The exact book wording of the expressiveness / effectiveness principles (only corroborated by
  Munzner-based teaching notes).
- Book figure numbers 5.1 / 5.6 (rankings) and 3.9 (what–why–how table): inferred from the
  errata and memory, not seen in the book.
- Two pitfalls in `question-to-idiom.md` — boxplots hiding multimodality, choropleths needing
  rates rather than counts — are standard practice, not Munzner's slides.
