---
name: motion
description: "Animate React/Next.js UI with the `motion` package (Framer Motion's successor): entrances, stagger, hover/tap feedback, layout and shared-element transitions, AnimatePresence, scroll-linked effects, reduced-motion. Use when adding or fixing animations, transitions or micro-interactions."
---

# Motion — animation for React / Next.js

## 1. Install and import

```sh
npm install motion
```

```tsx
"use client"; // required in Next.js App Router for any file that uses motion components/hooks
import { motion, AnimatePresence, MotionConfig, useReducedMotion, useScroll, useTransform, useInView } from "motion/react";
```

- `motion/react` is the current import path. The legacy `framer-motion` package still works and
  exposes the same API; prefer `motion/react` in new code and do not mix both in one project.
- Vanilla / non-React code: `import { animate, scroll, inView, stagger } from "motion"`.
- `stagger()` from `"motion"` is the standalone helper; inside React variants use
  `transition: { staggerChildren }` (see recipe A).
- Before using an API not listed here, check https://motion.dev/docs with WebFetch. Do not guess
  prop names.

## 2. Motion language

- **Durations:** 150–250 ms for micro-feedback (hover, press, toggle), 300–500 ms for entrances,
  ≤ 800 ms for a hero sequence. Nothing a user waits for takes longer than 500 ms.
- **Easing:** ease-out (`[0.16, 1, 0.3, 1]`) for things entering, ease-in-out for things moving
  between places, springs for things the user touches (`stiffness` 300–500, `damping` 25–35).
- **Properties:** animate `transform` (x, y, scale, rotate) and `opacity` only; `clip-path` and
  `filter` sparingly. Never animate width/height/top/left directly — use the `layout` prop.
- **Distances:** entrances travel 8–24 px. Scale from 0.96–0.98, never from 0.
- **Stagger:** 40–80 ms between siblings; cap the visible staggered set at ~8 items.
- **One choreography per view.** The hero gets a sequence; everything below gets at most a
  quiet reveal. If everything moves, nothing does.
- **Reason, in priority order:** orientation (where did this come from) → feedback (did my action
  register) → continuity (same object, new place) → delight. No reason, no animation.
- **Reduced motion is not optional:** `useReducedMotion()` → drop transforms, keep opacity fades,
  shorten durations. Wire it once at the root with `MotionConfig` (recipe H).

## 3. Recipes

**A. Variants + stagger for a hero or list**
```tsx
const list = { hidden: {}, show: { transition: { staggerChildren: 0.06, delayChildren: 0.1 } } };
const item = { hidden: { opacity: 0, y: 16 }, show: { opacity: 1, y: 0, transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] } } };

<motion.ul variants={list} initial="hidden" animate="show">
  {items.map((it) => <motion.li key={it.id} variants={item}>{it.label}</motion.li>)}
</motion.ul>
```

**B. Button with spring feedback**
```tsx
<motion.button
  whileHover={{ scale: 1.02, y: -1 }}
  whileTap={{ scale: 0.97 }}
  transition={{ type: "spring", stiffness: 400, damping: 28 }}
>
  Download
</motion.button>
```

**C. AnimatePresence for swapped content (modal, step, tab panel)**
```tsx
<AnimatePresence mode="wait" initial={false}>
  <motion.div
    key={step}                      // a stable, unique key per state is mandatory
    initial={{ opacity: 0, y: 8 }}
    animate={{ opacity: 1, y: 0 }}
    exit={{ opacity: 0, y: -8 }}
    transition={{ duration: 0.2 }}
  >
    {content[step]}
  </motion.div>
</AnimatePresence>
```

**D. Shared-element tab indicator**
```tsx
{tabs.map((t) => (
  <button key={t} onClick={() => setActive(t)} style={{ position: "relative" }}>
    {t}
    {active === t && (
      <motion.span layoutId="tab-indicator" style={{ position: "absolute", inset: "auto 0 0 0", height: 2, background: "var(--accent)" }}
        transition={{ type: "spring", stiffness: 500, damping: 35 }} />
    )}
  </button>
))}
```

**E. Scroll reveal (once, slightly before fully in view)**
```tsx
<motion.section
  initial={{ opacity: 0, y: 24 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: "-10%" }}
  transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
/>
```

**F. Scroll-linked progress bar and parallax**
```tsx
const { scrollYProgress } = useScroll();                       // page progress 0..1
<motion.div style={{ scaleX: scrollYProgress, transformOrigin: "0 0", height: 2, background: "var(--accent)", position: "fixed", top: 0, left: 0, right: 0 }} />

const ref = useRef(null);
const { scrollYProgress: p } = useScroll({ target: ref, offset: ["start end", "end start"] });
const y = useTransform(p, [0, 1], [-40, 40]);                  // parallax drift in px
<motion.img ref={ref} style={{ y }} src="/hero.png" alt="" />
```

**G. Reduced-motion-safe variants**
```tsx
export function useMotionSafe() {
  const reduce = useReducedMotion();
  const item = reduce
    ? { hidden: { opacity: 0 }, show: { opacity: 1, transition: { duration: 0.2 } } }
    : { hidden: { opacity: 0, y: 16 }, show: { opacity: 1, y: 0, transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] } } };
  const list = { hidden: {}, show: { transition: { staggerChildren: reduce ? 0 : 0.06 } } };
  return { item, list, reduce };
}
```

**H. Root config (do this once, in the app layout's client provider)**
```tsx
<MotionConfig reducedMotion="user" transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}>
  {children}
</MotionConfig>
```
`reducedMotion="user"` makes Motion skip transform/layout animations automatically when the OS
setting is on; recipe G is for cases where you want explicit control of the fallback.

## 4. Performance and pitfalls

- Let Motion manage `will-change`; do not sprinkle it in CSS — it costs memory on every element.
- Do not animate hundreds of nodes individually; animate the container, or virtualize and only
  animate what is visible (`whileInView`).
- Hydration flicker on mount: pass `initial={false}` to `AnimatePresence` or to the component so
  the first paint is the final state.
- SSR: `motion.*` components render their static markup on the server; the `initial` state is
  applied as inline style, so a hidden `initial` means the element is invisible until JS runs.
  Use it only on elements that are fine being hidden briefly, never on the main heading/CTA
  without a short duration.
- `AnimatePresence` needs stable, unique `key`s on direct children; without them exit animations
  never run.
- `layout` animations inside scroll containers: mark the scroller with `layoutScroll`; for
  independent layout groups use `LayoutGroup` (verify on motion.dev).
- Images and video inside `layout` elements distort during the transition; put `layout` on a
  wrapper and keep the media `layout="position"`.
- Test with CPU throttling 4× and on a real phone; if anything drops frames, remove the
  animation rather than tuning it for an hour.

## 5. QA checklist

1. OS "Reduce motion" on → no transforms, only short fades; nothing becomes unreachable.
2. Every interactive element gives feedback within 150 ms on hover and tap.
3. No animation blocks reading or clicking; no entrance runs longer than 500 ms except the hero.
4. 60 fps at 4× CPU throttle on the heaviest page; no layout thrash in the Performance panel.
5. `AnimatePresence` exits actually play (keys are stable), and nothing flickers on first paint.
