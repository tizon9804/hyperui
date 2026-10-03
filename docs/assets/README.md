# README assets

- `logo.svg` — hand-written SVG wordmark + mark; `prefers-color-scheme` switches ink/emerald for GitHub light and dark. Font stack `Sora, Inter, system-ui` (weight 800); GitHub shows the system fallback.
- `logo-dark.png`, `logo-light.png` — 2x renders (1040×240) of `logo.svg` with the media query forced to `@media all` (dark, on #0b0d12) or `@media not all` (light, on #fff), via headless Chrome.
- `journey.svg` — hand-written diagram (960×250): `/hyperui` door → Design · Spec · Build · Review · Ship · Infra, `.hyperui/` memory bar underneath. Same light/dark handling; edit the SVG directly.
- `examples/dashboard-ventas.png` — 1280×1400 headless-Chrome screenshot of `examples/dashboard-ventas.html` (output of the `viz` skill in a test run, data in `ventas.csv`).
- `examples/directions-strip.png` — 1800×669 composite of `examples/{ledger,monolith,atelier}-1280.png`, each scaled to 568 px wide, 24 px gutters on #0b0d12, built with Python Pillow.
- `examples/*-1280.png`, `*-390.png` — design-direction screenshots (desktop / mobile) from a test run of the `design` skill.

Regenerate a PNG: `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --hide-scrollbars --force-device-scale-factor=2 --window-size=520,120 --screenshot=out.png file:///path/to/page.html` (wrap a forced-scheme copy of the SVG in an `<img>` page for the logo; use scale 1 and 1280,1400 for the dashboard).
Rebuild the strip: in a venv with `pillow`, open the three `-1280.png`, `resize((568, 621))`, paste at x = 24 + i·592, y = 24 on an 1800×669 `#0b0d12` canvas.
