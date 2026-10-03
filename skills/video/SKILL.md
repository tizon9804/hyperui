---
name: video
description: "Make a short promo/demo video of a web product with HyperFrames (HTML → MP4), reusing the project's real brand tokens and components. Use when asked for a promo, teaser, product video, launch clip, social clip."
---

# hyperui:video — promo clip with HyperFrames

HyperFrames renders HTML/CSS/JS compositions to deterministic MP4. This skill owns the
*brief and the brand*; the installed `/hyperframes` skills own the framework. Never
reimplement their API or project layout — hand the composition to them.

## 1. Preflight

Check that the HyperFrames skills exist in `.claude/skills/hyperframes` (project) or
`~/.claude/skills/hyperframes` (global). If neither exists, tell the user to run
`/hyperui:setup` and stop here.

## 2. Brief (ask only what is missing)

- **Product** and the URL it points to.
- **One message**: the single sentence the viewer must leave with. One, not three.
- **Duration**: default 12 s. Anything over 20 s needs a reason.
- **Aspect**: 16:9 default (landing/YouTube); offer 9:16 for Stories/Reels/TikTok.
- **Brand tokens**: find where they live — `globals.css` custom properties, Tailwind
  config, a `tokens.*` file, a design-system package. Read them. Never invent a palette
  or typeface: if the project has none, ask for a reference or stop.
- **Real assets**: product screenshots, the actual icon/logo, real copy from the site.
  No lorem ipsum, no placeholder marks.

## 3. Composition rules (pass these to the `/hyperframes` skills)

- Real copy only, taken from the product's own pages.
- **≤ 15 s → max 3 scenes.** Hook (what it is) → proof (one real screen or demo moment)
  → end card.
- **Type-led scenes**: the headline is the hero; images support it. Type uses the
  project's display font and weight; sizes read at 50% playback size.
- **Motion on `transform` and `opacity` only** (translate, scale, clip reveals, fades).
  No layout-property animation, no bounces unless the brand already bounces.
- Easing language: see the `/hyperui:motion` skill (same curves on the site and in
  the video so they feel like one product).
- Brand colors from the tokens; one accent, generous negative space, safe margins ≥ 5%
  of the frame on every side.
- **End card**: logo/mark + product name + URL, held ≥ 2 s, static or near-static.
- Audio is optional. If a track is used, duck it under any voice and end on silence.

## 4. Build → preview → render

1. Let the installed `/hyperframes` skills scaffold the project in their layout (they
   choose folders, manifest, and timeline API).
2. Preview:

   ```
   npx hyperframes preview
   ```

   Check every scene at 50% size and at full size.
3. Render:

   ```
   npx hyperframes render --output <product>-<aspect>-<duration>s.mp4
   ```

4. Report: output path, duration, aspect, file size, and which tokens/assets were used.

## 5. QA checklist (before reporting done)

- [ ] Every headline legible at 50% size.
- [ ] Nothing clipped at the safe margins; no text touching the frame edge.
- [ ] Colors and type match the live product (open it side by side).
- [ ] Only `transform`/`opacity` animate; no janky layout shifts in preview.
- [ ] End card holds ≥ 2 s with the real URL.
- [ ] Duration matches the brief (±0.5 s).
- [ ] Audio, if any, does not clip and ends clean.

If any item fails, fix it in the composition and re-render; do not ship with a known miss.
