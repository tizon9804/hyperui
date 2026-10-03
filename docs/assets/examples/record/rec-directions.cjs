// Deterministic recorder for the three design directions.
// Per direction: paused Playwright clock (JS timers), Web Animations API seeking (CSS animations/transitions),
// scripted scroll + real mouse hover, injected chip + cursor glyph. Frames -> frames/<name>/f%04d.png
const { chromium } = require("playwright"); const fs = require("fs");
const H = require("path").resolve(__dirname, "..", "directions") + "/";
const FPS = 24, SEG = 3.4, FRAMES = Math.round(SEG * FPS);
const VW = 1040, VH = 650;
const STILLS = process.env.STILLS ? [0.1, 0.6, 1.4, 2.0, 2.9] : null;
const DIRS = [
  { name: "ledger",   scheme: "light", pair: "Fraunces + Inter" },
  { name: "monolith", scheme: "dark",  pair: "Syne + IBM Plex" },
  { name: "atelier",  scheme: "light", pair: "Instrument Serif + Manrope" },
];
const easeOut = (x) => 1 - Math.pow(1 - x, 3);
const easeInOut = (x) => x < .5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2;
const clamp01 = (x) => Math.max(0, Math.min(1, x));
const T0 = new Date("2026-10-03T12:00:00Z").getTime();

(async () => {
  const b = await chromium.launch({ channel: "chrome" });
  for (const d of DIRS) {
    const ctx = await b.newContext({ viewport: { width: VW, height: VH }, deviceScaleFactor: 2, colorScheme: d.scheme });
    await ctx.clock.install({ time: T0 });
    await ctx.clock.pauseAt(T0 + 500);
    const p = await ctx.newPage();
    await p.goto("file://" + H + d.name + ".html", { waitUntil: "networkidle" });
    await p.addStyleTag({ content: `
      html{scroll-behavior:auto!important}
      @import url('https://fonts.googleapis.com/css2?family=Sora:wght@600;700&display=swap');
      #__bar{position:fixed;left:0;right:0;bottom:0;height:54px;z-index:99998;background:#0b0d12;border-top:1px solid #1c2130;display:flex;align-items:center;justify-content:space-between;padding:0 22px;font:600 14px/1 Sora,Inter,system-ui,sans-serif;color:#e6e9f0;pointer-events:none}
      #__bar .r{color:#6b7385;font-weight:500;font-size:13px;letter-spacing:.01em;display:flex;align-items:center;gap:8px}
      #__bar .r b{color:#9aa3b5;font-weight:600}
      #__bar .r kbd{font:600 11px/1 Sora,Inter,system-ui;color:#3ecf8e;border:1px solid #244a39;background:#10211a;border-radius:6px;padding:4px 7px}
      #__chip{display:flex;align-items:center;gap:10px;padding:9px 15px 9px 12px;border-radius:999px;background:#141822;border:1px solid #262c3a;letter-spacing:-.01em;will-change:transform,opacity}
      #__chip i{width:8px;height:8px;border-radius:50%;background:#3ecf8e;box-shadow:0 0 0 4px rgba(62,207,142,.22);flex:none}
      #__chip b{font-weight:700}
      #__chip span{color:#9aa3b5;font-weight:500}
      #__chip em{color:#3c4454;font-style:normal;margin:0 1px}
      #__cur{position:fixed;left:0;top:0;z-index:99999;width:22px;height:22px;pointer-events:none;will-change:transform;filter:drop-shadow(0 2px 3px rgba(0,0,0,.35))}
    `});
    await p.evaluate(({ name, pair, idx }) => {
      const bar = document.createElement("div"); bar.id = "__bar";
      bar.innerHTML = `<div id="__chip"><i></i><b>${name[0].toUpperCase() + name.slice(1)}</b><em>·</em><span>${pair}</span></div><div class="r"><kbd>/hyperui</kbd> design · direction <b>${idx + 1}</b> of 3</div>`;
      document.body.appendChild(bar);
      const cur = document.createElement("div"); cur.id = "__cur";
      cur.innerHTML = `<svg viewBox="0 0 24 24" width="22" height="22"><path d="M5 3l14 9.2-6.3.9 3.6 6.6-2.6 1.4-3.6-6.7L5 19.6z" fill="#fff" stroke="#0b0d12" stroke-width="1.6" stroke-linejoin="round"/></svg>`;
      document.body.appendChild(cur);
      window.__seen = new Map();
      window.__tick = ({ tMs, scrollY, chipP, cur: c }) => {
        window.scrollTo(0, scrollY);
        for (const a of document.getAnimations()) {
          if (!window.__seen.has(a)) { window.__seen.set(a, tMs); a.pause(); }
          try { a.currentTime = Math.max(0, tMs - window.__seen.get(a)); } catch (e) {}
        }
        const chip = document.getElementById("__chip");
        chip.style.opacity = chipP; chip.style.transform = `translateX(${(1 - chipP) * -12}px)`;
        const cur = document.getElementById("__cur");
        cur.style.opacity = c.o; cur.style.transform = `translate(${c.x - 5}px, ${c.y - 3}px)`;
      };
    }, { ...d, idx: DIRS.indexOf(d) });
    await p.evaluate(() => document.fonts.ready);
    // register every load animation at t=0, then measure the primary button in its resting state
    await p.evaluate(() => window.__tick({ tMs: 0, scrollY: 0, chipP: 0, cur: { o: 0, x: 0, y: 0 } }));
    await p.evaluate(() => { for (const a of document.getAnimations()) { try { a.currentTime = 5000; } catch (e) {} } });
    const btn = await p.evaluate(() => { const r = document.querySelector(".hero .btn-primary").getBoundingClientRect(); return { x: r.left + r.width / 2, y: r.top + r.height / 2 }; });
    await p.evaluate(() => window.__tick({ tMs: 0, scrollY: 0, chipP: 0, cur: { o: 0, x: 0, y: 0 } }));
    // stage-1 scroll brings the CTA 140px above the caption bar; stage-2 completes the ~500px scroll
    const s1 = Math.max(0, Math.min(500, Math.round(btn.y - (VH - 54 - 140))));
    const target = { x: btn.x, y: btn.y - s1 };
    const start = { x: target.x + 260, y: Math.max(40, target.y - 110) };
    await p.mouse.move(start.x, start.y);
    const out = `${process.env.OUT_DIR || "frames"}/${d.name}`; fs.rmSync(out, { recursive: true, force: true }); fs.mkdirSync(out, { recursive: true });
    const times = STILLS || Array.from({ length: FRAMES }, (_, i) => i / FPS);
    let lastT = 0;
    for (let i = 0; i < times.length; i++) {
      const t = times[i];
      const hoverP = easeOut(clamp01((t - 1.2) / 0.45));
      const cx = start.x + (target.x - start.x) * hoverP, cy = start.y + (target.y - start.y) * hoverP;
      const curO = clamp01((t - 1.05) / 0.2) * (1 - clamp01((t - 2.2) / 0.3));
      const scrollY = s1 * easeInOut(clamp01((t - 0.85) / 0.6)) + (500 - s1) * easeInOut(clamp01((t - 2.15) / 0.9));
      const chipP = easeOut(clamp01((t - 0.25) / 0.45));
      await p.evaluate((a) => window.__tick(a), { tMs: t * 1000, scrollY, chipP, cur: { o: curO, x: cx, y: cy } });
      await p.mouse.move(cx, cy);
      await ctx.clock.runFor(Math.max(1, Math.round((t - lastT) * 1000)) ); lastT = t;
      await p.screenshot({ path: `${out}/f${String(i).padStart(4, "0")}.png` });
    }
    await ctx.close();
    console.log(d.name, times.length, "frames", "s1=" + s1, "btn", JSON.stringify(btn));
  }
  await b.close();
})();
