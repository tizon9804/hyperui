# Browser verification — never say it looks right without a screenshot

UI is not done until it was **seen** in a browser and the evidence is on disk. A claim like
"looks good", "responsive", "verified" without a capture is a defect. Used by `design` (QA step,
direction pages), `build` (any task touching UI), `motion` and `viz`.

## 1. Detect the tool — in this order, by looking at THIS session's tool list

1. **Claude in Chrome** (the extension driving the user's real Chrome; MCP server
   `claude-in-chrome`). Tools such as `navigate_page`, `take_screenshot` (`save_to_disk`),
   `evaluate_script`, `record_browser_interactions` — read the exact prefixed names from this
   session's tool list (`/mcp` → claude-in-chrome → View tools), never assume one. Only in an
   **interactive** session (`claude --chrome`, or `/chrome` → "Enabled by default"); direct plan +
   `/login`, extension ≥ 1.0.36, Claude Code ≥ 2.1.211; one session per machine drives Chrome;
   prompts in plan mode; never in `-p`. Retina screenshots are downscaled — read sizes from the DOM.
2. **Playwright MCP** (`mcp__playwright__*`; headed by default, `--headless` for CI; registered with
   `claude mcp add playwright -- npx @playwright/mcp@latest --headless` or `/hyperui:setup --playwright-mcp`)
   or **Chrome DevTools MCP** (`npx -y chrome-devtools-mcp@latest`).
3. **Headless Chrome binary** via Bash: macOS
   `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"`, Linux `google-chrome` /
   `chromium`. One capture: `<chrome> --headless --screenshot=<png> --window-size=W,H <url>`;
   dark mode / reduced motion need `--force-dark-mode` or a `data-theme="dark"` page variant.
4. **None** → §6. Headless runs (`-p`), evals and subagents (`hyperui:builder`, `hyperui:reviewer`) never have 1; they use 2–3 or report "needs main-session browser check".

## 2. Get a URL

- Dev server: read `package.json` `scripts` (`dev` / `start`), `Makefile`, `pyproject` or the
  framework CLI; run it in the background (Bash `run_in_background`), then poll the port
  (`curl -sI http://localhost:<port>` until 200, ≤ 30 s). Reuse a server already listening. **Leave it
  running** when done — the user opens that URL — and say how to restart it. No server: a static `.html`
  (direction pages, chart artifacts) opens as `file://<abs path>`; prefer the Artifact URL when one exists.

## 3. Capture matrix (minimum)

| | Viewports | Themes | Interaction | GIF |
|---|---|---|---|---|
| App / component | 360 · 768 · 1280 | light + dark | one: hover, focus or open menu | with Claude in Chrome: `record_browser_interactions`, ≤ 10 s |
| Marketing page | 360 · 768 · 1280 · **1920** | light + dark | the primary CTA hover + one scroll | same |

Dark mode: `evaluate_script` → `document.documentElement.dataset.theme = 'dark'` (tokens
follow `:root[data-theme="dark"]`), or the tool's `prefers-color-scheme` emulation; headless →
`--force-dark-mode`. Reduced motion (motion skill): emulate `prefers-reduced-motion: reduce` or
set the same `data-*` switch the page uses, capture once. Save files under
`<root>/.hyperui/evidence/<yyyy-mm-dd>/<page>-<viewport>-<theme>.png` (gitignored if private).

## 4. Checks per capture — each is pass/fail, say which

1. **No horizontal scroll**: `document.documentElement.scrollWidth <= innerWidth` (evaluate_script
   or inspect the PNG edge). 2. **No clipped text**: headings and buttons fully visible, no `…`
   on CTAs. 3. **Contrast** AA on text and the accent (compute from the token values or an
   `axe` run when available). 4. **Visible focus**: tab to the primary action, capture it.
5. **Hero within the first 360 viewport**: headline + primary CTA above the fold on phone.
6. **Fonts loaded**: `document.fonts.status === 'loaded'`, no fallback flash in the capture.
7. **Images sized**: every `<img>` has width/height or `aspect-ratio`; none overflows.
8. Charts (viz): tooltip appears on hover; labels legible at 360 (no overlapping ticks).

## 5. Evidence — written, then said

Append to `<root>/.hyperui/design.md`:

```
## Browser evidence
- 2026-10-03 · tool: Claude in Chrome | Playwright MCP | headless Chrome
- <url or file> · 360 light ✓ · 360 dark ✓ · 768 light ✓ · 1280 light ✓ · 1280 dark ✗ (clipped CTA → fixed, recaptured ✓)
- interaction: CTA hover (gif: .hyperui/evidence/2026-10-03/hero-hover.gif)
- checks: scroll ✓ · clipped ✓ · contrast ✓ · focus ✓ · fold ✓ · fonts ✓ · images ✓
```

Then the care line carries **`verified in Chrome at 360/768/1280`** (or "verified headless at …") and the
reply **shows before it asks** (root §7): local URL + restart command, the screenshots (one artifact page when
the Artifact tool exists, else the paths), one line "what to look at" — then the choice. A failed check is fixed
and recaptured before "done" — or reported as open, never hidden. The evidence line names the tool that ran.

## 6. No browser tool — say so, verify what you can, claim nothing visual

Say in one line: "No browser tool in this session — not visually verified" (same when a sandbox blocks the port, `listen EPERM`, or
Chrome). Then run the static checks (tests, `build`, lint, type check), report only those, and still give where to look (`npm run dev` → the URL, or the file path). **Never** write
"looks right", "responsive", "verified" or a `## Browser evidence` section. Record in
`state.md` `open:` → `browser check pending: <url or file> at 360/768/1280 light+dark`, and
suggest once: `claude --chrome` (or `/hyperui:setup --playwright-mcp`). A subagent in the same
situation reports **"needs main-session browser check"** verbatim.

## Sources

Verified 2026-10-03: Claude in Chrome (requirements, `--chrome`, `/chrome`, tools, interactive-only,
one session per machine, Retina downscaling) https://code.claude.com/docs/en/chrome.md · CLI flags
https://code.claude.com/docs/en/cli-reference.md · Computer use / browser tools
https://code.claude.com/docs/en/computer-use.md · MCP servers (`claude mcp add`)
https://code.claude.com/docs/en/mcp.md · Playwright MCP https://github.com/microsoft/playwright-mcp ·
Chrome DevTools MCP https://github.com/ChromeDevTools/chrome-devtools-mcp
