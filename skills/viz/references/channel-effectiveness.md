# Channel effectiveness, principles, rules of thumb, color

From Munzner, *Visualization Analysis and Design*, Ch 5 (marks and channels), Ch 6 (rules of
thumb) and Ch 10 (color), as stated in the official slide deck. Tags: [S pN] = slide page,
[2nd] = wording confirmed only in Munzner-based teaching notes (not against the book text),
[UNVERIFIED] = not confirmed against a primary source.

## 1. Marks and channels [S p143–195]

- **Marks** encode items: points (0D), lines (1D), areas (2D); volume (3D) is rare. Marks for
  links: *connection* (lines) and *containment* (nested areas).
- **Channels** control a mark's appearance from an attribute: position (horizontal, vertical,
  both), color (hue, luminance, saturation), shape, tilt, size (length, area, volume), motion…
- **Marks constrain channels** [S p158]: points leave size and shape free; a line fixes one size
  dimension (width stays free); interlocking areas (choropleth, treemap) fix size, shape and
  position. Quick test: "can you size-code another attribute?"
- **Redundant encoding** (length + luminance for the same attribute) strengthens the message but
  consumes channels.

## 2. Effectiveness rankings — exactly as the slides state them [S p162; book Fig 5.1 / 5.6]

**Magnitude channels, for ordered attributes** (ordinal and quantitative), best first:

1. position on a common scale
2. position on an unaligned scale
3. length (1D size)
4. tilt / angle
5. area (2D size)
6. depth (3D position)
7. color luminance
8. color saturation
9. curvature
10. volume (3D size)

**Identity channels, for categorical attributes**, best first:

1. spatial region
2. color hue
3. motion
4. shape

"Spatial position ranks high for both" [S p166]. Luminance and saturation are consecutive
entries and are *not* separable from each other [S p411]. Hue is **not** a magnitude channel;
texture and density are not in the list. The ranking synthesizes Cleveland & McGill 1984,
Heer & Bostock 2010 and Mackinlay 1986; the order below the top few entries is not individually
established by experiments [UNVERIFIED as a strict total order] — treat it as **tiers**.

### Expressiveness and effectiveness principles [S p161–165]

- **Expressiveness** — match channel type to attribute type: magnitude channels ("how much?") for
  ordered attributes, identity channels ("what?") for categorical attributes. Book wording as
  quoted in Munzner-based teaching notes [2nd]: *"the visual encoding should express all of, and
  only, the information in the dataset attributes."*
- **Effectiveness** — channels differ in perceptual accuracy, so put the most important attribute
  on the best channel of its type. Book wording [2nd]: *"the importance of the attribute should
  match the salience of the channel."*
- Both principles come from Mackinlay (1986); Munzner adopts them. They are **not** paired in
  the book with Tufte's lie factor or data-ink ratio (see `munzner-pitfalls.md`).

### Channel properties [S p169, p187–191]

- **Accuracy**: Stevens' power law; Cleveland & McGill 1984; Heer & Bostock 2010. Perception is
  mostly relative (Weber's law), so **alignment to a common frame and scale** improves accuracy;
  distractors and distance reduce it.
- **Discriminability**: how many usable steps a channel offers (line width: only a few bins).
- **Separability vs integrality**: position + hue fully separable; size + hue some interference;
  width + height integral (read as area); red + green major interference.
- **Popout**: preattentive, parallel search works on a *single* channel; a combination of
  channels forces serial search.
- **Grouping** [S p167]: containment, connection, proximity (same region), similarity (same
  categorical channel value).

## 3. The seven rules of thumb (Ch 6) [S p197–239, summary p239]

"Guidelines and considerations, not absolute rules."

1. **No unjustified 3D.** Power of the plane; we see in "2.05D" (disparity of depth); occlusion
   hides data; perspective distortion breaks every size channel; tilted text is illegible. 3D
   bars are "very difficult to justify"; facet into 2D instead. 3D is legitimate for true 3D
   spatial data when the task is shape perception.
2. **No unjustified 2D.** A text list beats a network layout for label lookup (higher density,
   easier search). A layout earns its place only when topology or context matters to the task.
3. **Eyes beat memory.** Side-by-side views beat comparing against memory. Animation suits
   storytelling and a transition between two states; it fails for many states with changes
   everywhere — use small multiples.
4. **Resolution over immersion.** Pixels are the scarcest resource; VR is hard to justify for
   abstract data.
5. **Overview first, zoom and filter, details on demand.** Shneiderman's mantra (1996), adopted as
   a rule of thumb. An overview is a summary and "a microcosm of the full vis design problem".
6. **Responsiveness is required.** 0.1 s for perceptual processing (hover highlight), 1 s for an
   immediate response (click), 10 s for brief tasks (dialog, file load). Highlight without a full
   redraw; show progress for multi-second work; keep the frame rate with many items.
7. **Function first, form next.** Function cannot be added after the fact; aesthetics can be
   refined later and still matter (visual hierarchy, alignment, Gestalt). Labelling [S p238]:
   a meaningful title, labelled axes and panes, a legend for everything plotted, no scientific
   notation in most cases.

## 4. Color guidance (Ch 10) [S p393–447]

- Decompose color into **luminance**, **saturation** and **hue**; hue is identity, luminance and
  saturation are magnitude.
- **Categorical**: 6–12 bins including background and highlight colors. For small, separated
  regions use saturation or luminance with 2 bins (3–4 at most).
- **Ordered**: rainbow is a poor default (perceptually unordered and nonlinear); use a
  monotone-luminance map (viridis, magma). A segmented, saturated rainbow is fine for
  *categorical* data.
- **Diverging**: needs a meaningful midpoint, a neutral midpoint color and saturated ends.
- **Bivariate** maps work best when one of the two directions is binary.
- **Color deficiency**: about 8 % of men are red/green deficient. Never encode by hue alone; add
  luminance, shape or direct labels. Blue/orange is a safe pair.
- **Luminance contrast** is required for fine detail and legible text.
- **Size as a reminder**: aligned length is best, area acceptable, volume poor.

When the session's `dataviz` skill is present, its palette and validator decide the exact
colors; the rules above are the constraints those colors must satisfy.
