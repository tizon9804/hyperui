# README assets

- `logo.svg` — hand-written SVG wordmark + mark; `prefers-color-scheme` switches ink/emerald for GitHub light and dark. Font stack `Sora, Inter, system-ui` (weight 800); GitHub shows the system fallback.
- `logo-dark.png`, `logo-light.png` — 2x renders (1040×240) of `logo.svg` with the media query forced to `@media all` (dark, on #0b0d12) or `@media not all` (light, on #fff), via headless Chrome.
- `journey.svg` — hand-written diagram (960×250): `/hyperui` door → Design · Spec · Build · Review · Ship · Infra, `.hyperui/` memory bar underneath. Same light/dark handling; edit the SVG directly.
- `demo.webp`, `demo.mp4` — the animated hero of the README: a 9-second loop recorded from `demo/index.html` (below). `demo.webp` is 960×600, 24 fps, libwebp quality 76, infinite loop (GitHub renders animated WebP); `demo.mp4` is the 1280×800 30 fps H.264 master (CRF 20).
- `demo/` — `index.html` + `demo.css` + `demo.js`: a fictional "Acme Notes" landing in the hyperui brand (graphite `#0b0d12`, surfaces `#141822`/`#1c2130`, emerald `#3ecf8e`, Sora 800 from Google Fonts with a system fallback). One deterministic, time-driven timeline (0–9 s): headline words stagger in with y + blur; a 3D card tilts in with `perspective(1200px) rotateX/rotateY` and an emerald glow follows a simulated pointer; a scripted scroll reveals three feature cards (scroll-linked, staggered) while three blurred blobs parallax at different depths; a button hover + tap spring; a tab indicator slides with a shared-layout feel; the `built with hyperui` wordmark fades in at the end. Only `transform`/`opacity`/`filter` animate. After the timeline the page goes live: wheel scroll with parallax, pointer-driven tilt and glow, hover springs, clickable tabs; click the wordmark to replay. `prefers-reduced-motion` jumps to the resting state and disables the tilt. `?record` in the URL loads it paused at t = 0 and exposes `window.__seek(t)` / `window.__duration` for frame-exact rendering. Tuned for a 1280×800 viewport.
- `examples/dashboard-ventas.png` — 1280×1400 headless-Chrome screenshot of `examples/dashboard-ventas.html` (output of the `viz` skill in a test run, data in `ventas.csv`).
- `examples/directions-strip.png` — 1800×669 composite of `examples/{ledger,monolith,atelier}-1280.png`, each scaled to 568 px wide, 24 px gutters on #0b0d12, built with Python Pillow.
- `examples/*-1280.png`, `*-390.png` — design-direction screenshots (desktop / mobile) from a test run of the `design` skill.

Regenerate a PNG: `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --hide-scrollbars --force-device-scale-factor=2 --window-size=520,120 --screenshot=out.png file:///path/to/page.html` (wrap a forced-scheme copy of the SVG in an `<img>` page for the logo; use scale 1 and 1280,1400 for the dashboard).
Rebuild the strip: in a venv with `pillow`, open the three `-1280.png`, `resize((568, 621))`, paste at x = 24 + i·592, y = 24 on an 1800×669 `#0b0d12` canvas.

Regenerate the demo (Playwright drives the installed Chrome, no browser download; ffmpeg comes from `ffmpeg-static`):

```bash
mkdir -p /tmp/demo-rec && cd /tmp/demo-rec && npm init -y >/dev/null && npm i playwright ffmpeg-static
# render 270 frames at 30 fps by seeking the page's timeline (deterministic, identical every run)
node -e '
const { chromium } = require("playwright"); const fs = require("fs");
(async () => {
  const b = await chromium.launch({ channel: "chrome" });
  const p = await b.newPage({ viewport: { width: 1280, height: 800 }, deviceScaleFactor: 1 });
  await p.goto("file://" + process.env.HOME + "/personal/hyperui/docs/assets/demo/index.html?record");
  await p.evaluate(() => window.__ready); fs.mkdirSync("frames", { recursive: true });
  for (let i = 0; i < 270; i++) {
    await p.evaluate((t) => { window.__seek(t); return new Promise((r) => requestAnimationFrame(r)); }, i / 30);
    await p.screenshot({ path: `frames/f${String(i).padStart(4, "0")}.png` });
  }
  await b.close();
})();'
FF=$(node -p "require('ffmpeg-static')")
$FF -y -framerate 30 -i frames/f%04d.png -c:v libx264 -pix_fmt yuv420p -crf 20 -preset slow -movflags +faststart demo.mp4
$FF -y -framerate 30 -i frames/f%04d.png -vf "fps=24,scale=960:-1:flags=lanczos" -c:v libwebp_anim -quality 76 -compression_level 6 -loop 0 demo.webp
```

Keep `demo.webp` under 4 MB (lower `fps=` or the width first, quality last). Then run `scripts/check.sh`: its company-agnostic grep also scans binaries, and a WebP encode can hit the pattern by chance (quality 75 did) — nudge `-quality` by one and re-encode until it is clean. Adjust the repo path in the `goto` line if the checkout is elsewhere.
