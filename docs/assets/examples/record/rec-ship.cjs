// Ship terminal recorder: seeks docs/assets/examples/ship-terminal.html frame by frame (window.__seek). Frames -> frames/ship/f%04d.png
const { chromium } = require("playwright"); const fs = require("fs");
const FILE = "file://" + require("path").resolve(__dirname, "..", "ship-terminal.html") + "?record";
const FPS = 24, DUR = 8.0, FRAMES = Math.round(DUR * FPS);
const STILLS = process.env.STILLS ? [0.2, 1.5, 2.6, 4.2, 6.2, 7.6] : null;
(async () => {
  const b = await chromium.launch({ channel: "chrome" });
  const p = await b.newPage({ viewport: { width: 960, height: 420 }, deviceScaleFactor: 2, colorScheme: "dark" });
  await p.goto(FILE, { waitUntil: "networkidle" });
  await p.evaluate(() => window.__ready);
  const out = `${process.env.OUT_DIR || "frames"}/ship`; fs.rmSync(out, { recursive: true, force: true }); fs.mkdirSync(out, { recursive: true });
  const times = STILLS || Array.from({ length: FRAMES }, (_, i) => i / FPS);
  for (let i = 0; i < times.length; i++) {
    await p.evaluate((t) => { window.__seek(t); return new Promise((r) => requestAnimationFrame(r)); }, times[i]);
    await p.screenshot({ path: `${out}/f${String(i).padStart(4, "0")}.png` });
  }
  await b.close(); console.log("ship", times.length, "frames");
})();
