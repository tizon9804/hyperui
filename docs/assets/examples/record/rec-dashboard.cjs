// Dashboard recorder: intro what-why-how card (injected), scroll to the KPI row + charts, two real tooltip hovers.
// Deterministic: every frame's state is a pure function of t. Frames -> frames/dashboard/f%04d.png
const { chromium } = require("playwright"); const fs = require("fs");
const FILE = "file://" + require("path").resolve(__dirname, "..", "dashboard-ventas.html");
const FPS = 24, DUR = 8.0, FRAMES = Math.round(DUR * FPS), VW = 1120, VH = 700;
const STILLS = process.env.STILLS ? [0.3, 1.6, 2.7, 3.6, 5.3, 7.5] : null;
const easeOut = (x) => 1 - Math.pow(1 - x, 3);
const easeInOut = (x) => x < .5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2;
const clamp01 = (x) => Math.max(0, Math.min(1, x));
const lerp = (a, b, p) => ({ x: a.x + (b.x - a.x) * p, y: a.y + (b.y - a.y) * p });

(async () => {
  const b = await chromium.launch({ channel: "chrome" });
  const p = await b.newPage({ viewport: { width: VW, height: VH }, deviceScaleFactor: 2, colorScheme: "dark" });
  await p.goto(FILE, { waitUntil: "networkidle" });
  await p.addStyleTag({ content: `
    @import url('https://fonts.googleapis.com/css2?family=Sora:wght@600;700&display=swap');
    html{scroll-behavior:auto!important}
    .card-head > div:first-child{flex:1 1 auto;min-width:0}.card-head .seg{flex:none}
    #__ov{position:fixed;inset:0;z-index:99990;background:rgba(11,13,18,.62);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);display:grid;place-items:center;pointer-events:none}
    #__card{width:860px;background:#12151c;border:1px solid rgba(255,255,255,.1);border-radius:16px;padding:26px 30px 24px;box-shadow:0 40px 90px -40px rgba(0,0,0,.8),0 0 0 1px rgba(255,255,255,.03) inset;color:#fff;font:400 14px/1.45 Inter,system-ui,-apple-system,sans-serif;will-change:transform,opacity}
    #__card .eyebrow{display:flex;align-items:center;gap:10px;font:600 12px/1 Sora,Inter,system-ui;letter-spacing:.08em;text-transform:uppercase;color:#3ecf8e}
    #__card .eyebrow i{width:8px;height:8px;border-radius:50%;background:#3ecf8e;box-shadow:0 0 0 4px rgba(62,207,142,.22)}
    #__card .eyebrow span{color:#6b7385;letter-spacing:0;text-transform:none;font-weight:500;margin-left:auto}
    #__card h2{font:700 26px/1.15 Sora,Inter,system-ui;letter-spacing:-.02em;margin:14px 0 4px}
    #__card h2 em{font-style:normal;color:#9aa3b5;font-weight:600}
    #__card p.sub{margin:0 0 18px;color:#9aa3b5;font-size:14px}
    #__card table{width:100%;border-collapse:collapse;font-variant-numeric:tabular-nums}
    #__card th.c1{width:22%}#__card th.c2{width:33%}#__card th.c3{width:21%}
    #__card th{text-align:left;font:600 11px/1 Sora,Inter,system-ui;letter-spacing:.08em;text-transform:uppercase;color:#6b7385;padding:0 12px 10px 0;border-bottom:1px solid rgba(255,255,255,.1)}
    #__card th.k{color:#3ecf8e}
    #__card td{padding:12px 12px 12px 0;border-bottom:1px solid rgba(255,255,255,.07);vertical-align:top;color:#c3c2b7;font-size:14px}
    #__card tr:last-child td{border-bottom:0}
    #__card td.n{color:#fff;font-weight:600;white-space:nowrap}
    #__card td.h{color:#fff}
    #__card td.h{white-space:nowrap}#__card td.h b{display:inline-block;font-weight:600;color:#3ecf8e;background:rgba(62,207,142,.1);border:1px solid rgba(62,207,142,.25);border-radius:6px;padding:2px 7px;margin-right:6px;font-size:12.5px}
    #__card tr.r{will-change:transform,opacity}
    #__card .foot{margin-top:14px;color:#6b7385;font-size:12.5px;display:flex;gap:16px}
    #__card .foot b{color:#9aa3b5;font-weight:600}
    #__cur{position:fixed;left:0;top:0;z-index:99999;width:22px;height:22px;pointer-events:none;will-change:transform;filter:drop-shadow(0 2px 3px rgba(0,0,0,.45))}
  `});
  await p.evaluate(() => {
    const ov = document.createElement("div"); ov.id = "__ov";
    ov.innerHTML = `<div id="__card">
      <div class="eyebrow"><i></i>viz · what → why → how<span>Munzner's analysis, written before any chart</span></div>
      <h2>Decide what to draw. <em>Then draw it.</em></h2>
      <p class="sub">One row per view of <code>ventas.csv</code> — the data, the task, the idiom that fits.</p>
      <table>
        <thead><tr><th class="c1">View</th><th class="k c2">What · data</th><th class="k c3">Why · task</th><th class="k">How · idiom</th></tr></thead>
        <tbody>
          <tr class="r"><td class="n">Ingresos por mes</td><td>1 ordinal key (month) × 1 quantity (COP)</td><td>Compare months, read the trend</td><td class="h"><b>column chart</b>one hue, max labeled</td></tr>
          <tr class="r"><td class="n">Ingresos por región</td><td>1 categorical key (region) × 1 quantity</td><td>Rank regions</td><td class="h"><b>horizontal bars</b>sorted</td></tr>
          <tr class="r"><td class="n">Unidades por producto</td><td>1 categorical key (product) × quantity + unit price</td><td>Rank products, volume vs price</td><td class="h"><b>horizontal bars</b>sorted, price</td></tr>
        </tbody>
      </table>
      <div class="foot"><span><b>Bars, not a pie</b> — position beats angle</span><span><b>Tooltips</b> on every mark</span><span><b>Sources</b> cited under the charts</span></div>
    </div>`;
    document.body.appendChild(ov);
    const cur = document.createElement("div"); cur.id = "__cur";
    cur.innerHTML = `<svg viewBox="0 0 24 24" width="22" height="22"><path d="M5 3l14 9.2-6.3.9 3.6 6.6-2.6 1.4-3.6-6.7L5 19.6z" fill="#fff" stroke="#0b0d12" stroke-width="1.6" stroke-linejoin="round"/></svg>`;
    document.body.appendChild(cur);
    window.__tick = ({ scrollY, ovO, cardP, rows, cur: c }) => {
      window.scrollTo(0, scrollY);
      const ov = document.getElementById("__ov"); ov.style.opacity = ovO; ov.style.display = ovO <= 0 ? "none" : "grid";
      const card = document.getElementById("__card"); card.style.transform = `translateY(${(1 - cardP) * 18}px) scale(${.97 + .03 * cardP})`;
      document.querySelectorAll("#__card tr.r").forEach((tr, i) => { const q = rows[i]; tr.style.opacity = q; tr.style.transform = `translateY(${(1 - q) * 8}px)`; });
      const cu = document.getElementById("__cur"); cu.style.opacity = c.o; cu.style.transform = `translate(${c.x - 5}px, ${c.y - 3}px)`;
    };
  });
  await p.evaluate(() => document.fonts.ready);
  // measure: scroll target (KPI row top at 20px) and the two bars to hover, in viewport coords at that scroll
  const m = await p.evaluate(() => {
    const kpi = document.querySelector(".tile.hero").getBoundingClientRect();
    const target = Math.round(kpi.top + window.scrollY - 20);
    window.scrollTo(0, target);
    const r1 = document.querySelectorAll("#c-month .bar .mark")[1].getBoundingClientRect();   // "ago", the max
    const r2 = document.querySelectorAll("#c-region .bar .mark")[0].getBoundingClientRect();  // "Sur", the top row
    window.scrollTo(0, 0);
    return { target, b1: { x: r1.left + r1.width / 2, y: r1.top + r1.height * 0.35 }, b2: { x: r2.left + r2.width * 0.6, y: r2.top + r2.height / 2 } };
  });
  console.log(JSON.stringify(m));
  const start = { x: m.b1.x + 220, y: m.b1.y + 160 };
  await p.mouse.move(VW - 40, VH - 40);
  const out = `${process.env.OUT_DIR || "frames"}/dashboard`; fs.rmSync(out, { recursive: true, force: true }); fs.mkdirSync(out, { recursive: true });
  const times = STILLS || Array.from({ length: FRAMES }, (_, i) => i / FPS);
  for (let i = 0; i < times.length; i++) {
    const t = times[i];
    const ovIn = easeOut(clamp01((t - 0.05) / 0.4)), ovOut = clamp01((t - 2.45) / 0.45);
    const ovO = ovIn * (1 - ovOut);
    const cardP = ovIn * (1 - ovOut * 0.6);
    const rows = [0, 1, 2].map((k) => easeOut(clamp01((t - 0.55 - k * 0.22) / 0.35)));
    const scrollY = m.target * easeInOut(clamp01((t - 2.9) / 1.3));
    let pos, curO;
    if (t < 4.3) { pos = start; curO = clamp01((t - 4.1) / 0.2); }
    else if (t < 5.7) { pos = lerp(start, m.b1, easeOut(clamp01((t - 4.3) / 0.8))); curO = 1; }
    else { pos = lerp(m.b1, m.b2, easeInOut(clamp01((t - 5.7) / 0.8))); curO = 1; }
    await p.evaluate((a) => window.__tick(a), { scrollY, ovO, cardP, rows, cur: { o: curO, x: pos.x, y: pos.y } });
    if (t >= 4.1) await p.mouse.move(pos.x, pos.y);
    await p.screenshot({ path: `${out}/f${String(i).padStart(4, "0")}.png` });
  }
  await b.close();
  console.log("dashboard", times.length, "frames");
})();
