/* Acme Notes — hyperui motion demo.
 *
 * One deterministic, time-driven timeline (0–9 s) renders the whole choreography from a
 * single number `t`, so a recorder can call window.__seek(t) and get the exact same frame
 * every run. On load the page plays that timeline once (unless `?record` is in the URL),
 * then switches to live mode: real wheel scrolling with parallax, a 3D tilt that follows the
 * pointer, hover/tap springs and clickable tabs. `prefers-reduced-motion` jumps straight to
 * the resting state and disables the tilt.
 *
 * Everything animated here is transform / opacity / filter only.
 */
(() => {
  'use strict';

  const DURATION = 9;
  const $ = (s) => document.querySelector(s);
  const $$ = (s) => Array.from(document.querySelectorAll(s));

  const stage = $('#stage');
  const world = $('#world');
  const nav = $('.nav');
  const words = $$('.headline .word');
  const staggers = $$('.stagger');
  const card = $('#product-card');
  const scene = $('.card-scene');
  const glow = $('#glow');
  const sheen = $('#sheen');
  const pointer = $('#pointer');
  const ring = $('.pointer-ring');
  const blobs = $$('.blob');
  const reveals = $$('.reveal');
  const tabs = $$('.tab');
  const indicator = $('#tab-indicator');
  const ctaBtn = $('#cta-btn');
  const wordmark = $('#wordmark');

  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const recordMode = /[?&]record\b/.test(location.search);

  // ---------- easing ----------
  const clamp01 = (x) => (x < 0 ? 0 : x > 1 ? 1 : x);
  const lerp = (a, b, p) => a + (b - a) * p;
  const seg = (t, t0, t1) => clamp01((t - t0) / (t1 - t0));
  const outExpo = (p) => (p >= 1 ? 1 : 1 - Math.pow(2, -10 * p));
  const outCubic = (p) => 1 - Math.pow(1 - p, 3);
  const inOutCubic = (p) => (p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2);
  // Analytic under-damped spring step response, normalised to [0,1] over p ∈ [0,1].
  const spring = (k, w) => (p) => {
    if (p <= 0) return 0;
    if (p >= 1) return 1;
    return 1 - Math.exp(-k * p) * (Math.cos(w * p) + (k / w) * Math.sin(w * p));
  };
  const springSoft = spring(8, 9); // ~6 % overshoot — shared-layout indicator
  const springBouncy = spring(6, 12); // ~15 % overshoot — hover / tap feedback

  // ---------- layout (measured once, world at rest) ----------
  const L = {};
  function layout() {
    world.style.transform = 'none';
    L.vw = stage.clientWidth;
    L.vh = stage.clientHeight;
    const r = (el) => el.getBoundingClientRect();
    L.scene = r(scene);
    L.card = r(card);
    L.reveals = reveals.map((el) => r(el).top);
    // final scroll: the hero (card + floating chip) fully out, the features block centred below
    const heroBottom = Math.max(r($('.hero-copy')).bottom, r($('.pc-float')).bottom);
    const block = r($('.features'));
    const blockH = r($('.platforms')).bottom - r($('.features-head')).top;
    const centred = r($('.features-head')).top - (L.vh - blockH) / 2;
    L.maxS = Math.max(0, Math.round(Math.max(heroBottom + 28, centred)));
    L.travel = L.reveals.map((top) => Math.max(80, Math.min(220, L.vh - (top - L.maxS) - 20)));
    const b = r(ctaBtn);
    L.btn = { x: b.left + b.width * 0.5, y: b.top + b.height * 0.5 };
    L.tabs = tabs.map((el) => r(el));
    const tabsBox = r($('#tabs'));
    L.tabOffsets = L.tabs.map((tr) => ({ x: tr.left - tabsBox.left - 4, w: tr.width }));
    indicator.style.width = L.tabOffsets[0].w + 'px';
  }

  // ---------- the timeline ----------
  // Simulated pointer path in viewport coords. Targets inside the scrolled section are
  // expressed in world coords minus the final scroll offset.
  function pointerKeys() {
    const S = L.maxS;
    const c = L.card;
    return [
      { t: 1.45, x: c.left + 40, y: c.bottom + 50 },
      { t: 2.2, x: c.left + c.width * 0.35, y: c.top + c.height * 0.3 },
      { t: 2.9, x: c.left + c.width * 0.8, y: c.top + c.height * 0.62 },
      { t: 3.4, x: c.right + 30, y: c.top + c.height * 0.9 },
      { t: 5.6, x: c.right - 40, y: L.vh * 0.78 },
      { t: 6.0, x: c.right - 40, y: L.vh * 0.78 },
      { t: 6.4, x: L.btn.x, y: L.btn.y - S },
      { t: 7.0, x: L.btn.x, y: L.btn.y - S },
      { t: 7.4, x: L.tabs[1].left + L.tabs[1].width * 0.5, y: L.tabs[1].top + L.tabs[1].height * 0.5 - S },
      { t: 7.8, x: L.tabs[1].left + L.tabs[1].width * 0.5, y: L.tabs[1].top + L.tabs[1].height * 0.5 - S },
      { t: 8.5, x: L.tabs[1].left + L.tabs[1].width * 0.5 + 36, y: L.tabs[1].top + L.tabs[1].height * 0.5 - S + 44 },
    ];
  }
  function pointerAt(t, keys) {
    if (t <= keys[0].t) return keys[0];
    for (let i = 1; i < keys.length; i++) {
      if (t <= keys[i].t) {
        const a = keys[i - 1], b = keys[i];
        const p = inOutCubic(seg(t, a.t, b.t));
        return { x: lerp(a.x, b.x, p), y: lerp(a.y, b.y, p) };
      }
    }
    return keys[keys.length - 1];
  }

  const T = {
    scrollStart: 3.0, scrollEnd: 5.6,
    cardIn: 1.4, cardSettled: 2.5,
    hoverIn: 6.35, press: 6.72, release: 6.84, hoverOut: 7.0,
    tabClick: 7.4,
    wordmark: 8.0,
  };

  // Derived state from time. Also reused by live mode (with S / pointer coming from input).
  function stateAt(t) {
    const S = L.maxS * inOutCubic(seg(t, T.scrollStart, T.scrollEnd));
    const keys = pointerAt.keys || (pointerAt.keys = pointerKeys());
    const pt = pointerAt(t, keys);
    const overCard = t >= 1.55 && t <= 3.3;
    const entrance = outExpo(seg(t, T.cardIn, T.cardSettled));
    // hover / tap
    let btnScale = 1 + 0.05 * springBouncy(seg(t, T.hoverIn, T.hoverIn + 0.5));
    if (t >= T.hoverOut) btnScale = 1.05 - 0.05 * springSoft(seg(t, T.hoverOut, T.hoverOut + 0.5));
    const tap = -0.09 * outCubic(seg(t, T.press, T.release)) + 0.09 * springBouncy(seg(t, T.release, T.release + 0.55));
    btnScale += tap;
    const clicks = [T.release, T.tabClick];
    let ringP = 0;
    for (const c of clicks) if (t >= c && t < c + 0.45) ringP = seg(t, c, c + 0.45);
    return {
      t, S, pt,
      pointerOpacity: seg(t, 1.45, 1.75),
      ringP,
      glow: overCard ? seg(t, 1.55, 1.9) * (1 - seg(t, 3.0, 3.3)) : 0,
      entrance,
      tilt: tiltFor(pt, S, entrance),
      btnScale,
      tabP: springSoft(seg(t, T.tabClick, T.tabClick + 0.7)),
      tabFade: outCubic(seg(t, T.tabClick, T.tabClick + 0.3)),
      wordmarkP: outExpo(seg(t, T.wordmark, T.wordmark + 0.6)),
    };
  }

  // Tilt from where the pointer is relative to the card centre (card moves with the scroll).
  function tiltFor(pt, S, entrance) {
    const c = L.card;
    const cx = c.left + c.width / 2, cy = c.top + c.height / 2 - S;
    const dx = Math.max(-1, Math.min(1, (pt.x - cx) / (c.width * 0.6)));
    const dy = Math.max(-1, Math.min(1, (pt.y - cy) / (c.height * 0.6)));
    const inside = Math.abs(pt.x - cx) < c.width * 0.75 && Math.abs(pt.y - cy) < c.height * 0.75;
    const k = inside ? 1 : 0;
    // entrance pose → pointer pose
    return {
      rx: lerp(18, -dy * 10 * k, entrance),
      ry: lerp(-24, dx * 13 * k, entrance),
    };
  }

  // ---------- render ----------
  function render(s) {
    const { t } = s;
    // nav
    { const p = outExpo(seg(t, 0.0, 0.7)); nav.style.opacity = p; nav.style.transform = `translateY(${lerp(-12, 0, p)}px)`; }
    // headline words: y + blur → clear
    words.forEach((w, i) => {
      const p = outExpo(seg(t, 0.08 + i * 0.09, 0.08 + i * 0.09 + 0.75));
      w.style.opacity = p;
      w.style.transform = `translateY(${lerp(34, 0, p)}px)`;
      w.style.filter = `blur(${lerp(14, 0, p).toFixed(2)}px)`;
    });
    // eyebrow / sub / actions / proof
    const sTimes = [0.0, 0.8, 0.95, 1.1];
    staggers.forEach((el) => {
      const i = +el.dataset.i;
      const p = outExpo(seg(t, sTimes[i], sTimes[i] + 0.7));
      el.style.opacity = p;
      el.style.transform = `translateY(${lerp(18, 0, p)}px)`;
      el.style.filter = `blur(${lerp(8, 0, p).toFixed(2)}px)`;
    });
    // 3D card
    {
      const e = s.entrance;
      card.style.opacity = e;
      card.style.filter = `blur(${lerp(10, 0, e).toFixed(2)}px)`;
      card.style.transform = `perspective(1200px) translateY(${lerp(70, 0, e)}px) scale(${lerp(0.9, 1, e).toFixed(4)}) rotateX(${s.tilt.rx.toFixed(3)}deg) rotateY(${s.tilt.ry.toFixed(3)}deg)`;
      const gx = s.pt.x - L.scene.left, gy = s.pt.y - (L.scene.top - s.S);
      glow.style.transform = `translate(${gx.toFixed(1)}px, ${gy.toFixed(1)}px)`;
      glow.style.opacity = s.glow;
      const sx = s.pt.x - L.card.left, sy = s.pt.y - (L.card.top - s.S);
      sheen.style.transform = `translate(${sx.toFixed(1)}px, ${sy.toFixed(1)}px)`;
      sheen.style.opacity = s.glow;
    }
    // scroll + parallax depth layers
    world.style.transform = `translateY(${(-s.S).toFixed(2)}px)`;
    blobs.forEach((b, i) => {
      const d = +b.dataset.depth;
      const drift = Math.sin(t * 0.6 + i * 2.1) * 10;
      b.style.transform = `translate(${(drift * 0.6).toFixed(2)}px, ${(-s.S * d + drift).toFixed(2)}px)`;
    });
    // scroll-linked reveals: each element fades in as its top crosses 90 % of the viewport
    reveals.forEach((el, i) => {
      const r = +el.dataset.r;
      const top = L.reveals[i] - s.S;
      const p = outExpo(clamp01((L.vh + 10 - top - r * 26) / L.travel[i]));
      el.style.opacity = p;
      el.style.transform = `translateY(${lerp(44, 0, p)}px)`;
      el.style.filter = `blur(${lerp(10, 0, p).toFixed(2)}px)`;
    });
    // button spring
    ctaBtn.style.transform = `scale(${s.btnScale.toFixed(4)})`;
    // tabs: indicator slides + resizes with a soft spring (shared-layout feel)
    {
      const a = L.tabOffsets[0], b = L.tabOffsets[1];
      const x = lerp(a.x, b.x, s.tabP);
      const w = lerp(a.w, b.w, s.tabP) / a.w;
      indicator.style.transform = `translateX(${x.toFixed(2)}px) scaleX(${w.toFixed(4)})`;
      tabs[0].style.opacity = lerp(1, 0.55, s.tabFade);
      tabs[1].style.opacity = lerp(0.55, 1, s.tabFade);
      tabs[0].setAttribute('aria-selected', s.tabFade < 0.5);
      tabs[1].setAttribute('aria-selected', s.tabFade >= 0.5);
    }
    // pointer + click ring
    pointer.style.opacity = s.pointerOpacity;
    pointer.style.transform = `translate(${s.pt.x.toFixed(1)}px, ${s.pt.y.toFixed(1)}px)`;
    const pressed = t >= T.press && t < T.release;
    pointer.firstElementChild.style.transform = `scale(${pressed ? 0.86 : 1})`;
    ring.style.opacity = s.ringP ? (1 - s.ringP) * 0.9 : 0;
    ring.style.transform = `scale(${lerp(0.3, 1.8, outCubic(s.ringP)).toFixed(3)})`;
    // wordmark
    wordmark.style.opacity = s.wordmarkP;
    wordmark.style.transform = `translateY(${lerp(10, 0, s.wordmarkP)}px)`;
  }

  // ---------- seek API (used by the recorder) ----------
  function seek(t) {
    t = Math.max(0, Math.min(DURATION, t));
    render(stateAt(t));
    return t;
  }
  window.__seek = seek;
  window.__duration = DURATION;

  // ---------- live mode ----------
  const live = { S: 0, targetS: 0, pt: { x: -9999, y: -9999 }, tilt: { rx: 0, ry: 0 }, tab: 1, tabFrom: 1, tabT0: -1, raf: 0 };
  function startLive(endState) {
    stage.classList.remove('is-recording');
    stage.classList.add('is-live');
    live.S = live.targetS = endState.S;
    const base = stateAt(DURATION);
    let last = performance.now();
    const frame = (now) => {
      const dt = Math.min(0.05, (now - last) / 1000); last = now;
      live.S = reduced ? live.targetS : lerp(live.S, live.targetS, 1 - Math.pow(0.001, dt));
      const target = tiltFor(live.pt, live.S, 1);
      const k = reduced ? 0 : 1 - Math.pow(0.002, dt);
      live.tilt.rx = reduced ? 0 : lerp(live.tilt.rx, target.rx, k);
      live.tilt.ry = reduced ? 0 : lerp(live.tilt.ry, target.ry, k);
      const c = L.card, cx = c.left + c.width / 2, cy = c.top + c.height / 2 - live.S;
      const over = Math.abs(live.pt.x - cx) < c.width * 0.75 && Math.abs(live.pt.y - cy) < c.height * 0.75;
      // tab indicator spring
      let tabP = 1;
      if (live.tabT0 >= 0) tabP = springSoft(clamp01((now - live.tabT0) / 700));
      const a = L.tabOffsets[live.tabFrom], b = L.tabOffsets[live.tab];
      const s = {
        ...base,
        t: DURATION, S: live.S, pt: live.pt, tilt: live.tilt,
        glow: over ? 1 : 0, pointerOpacity: 0, ringP: 0, btnScale: 1, tabP: 0, tabFade: 1,
      };
      render(s);
      indicator.style.transform = `translateX(${lerp(a.x, b.x, tabP).toFixed(2)}px) scaleX(${(lerp(a.w, b.w, tabP) / L.tabOffsets[0].w).toFixed(4)})`;
      tabs.forEach((el, i) => { el.style.opacity = ''; el.classList.toggle('is-active', i === live.tab); el.setAttribute('aria-selected', i === live.tab); });
      ctaBtn.style.transform = '';
      live.raf = requestAnimationFrame(frame);
    };
    live.raf = requestAnimationFrame(frame);
  }
  stage.addEventListener('wheel', (e) => {
    if (!stage.classList.contains('is-live')) return;
    e.preventDefault();
    live.targetS = Math.max(0, Math.min(L.maxS, live.targetS + e.deltaY));
  }, { passive: false });
  window.addEventListener('keydown', (e) => {
    if (!stage.classList.contains('is-live')) return;
    if (e.key === 'ArrowDown' || e.key === 'PageDown' || e.key === ' ') live.targetS = L.maxS;
    if (e.key === 'ArrowUp' || e.key === 'PageUp' || e.key === 'Home') live.targetS = 0;
  });
  stage.addEventListener('pointermove', (e) => { live.pt = { x: e.clientX, y: e.clientY }; });
  stage.addEventListener('pointerleave', () => { live.pt = { x: -9999, y: -9999 }; });
  tabs.forEach((el, i) => el.addEventListener('click', () => {
    if (i === live.tab) return;
    live.tabFrom = live.tab; live.tab = i; live.tabT0 = performance.now();
  }));
  $$('a[href="#"]').forEach((a) => a.addEventListener('click', (e) => e.preventDefault()));
  wordmark.addEventListener('click', (e) => { e.preventDefault(); play(); });

  // ---------- autoplay ----------
  function play() {
    cancelAnimationFrame(live.raf);
    stage.classList.remove('is-live');
    stage.classList.add('is-recording');
    live.tab = 1; live.tabFrom = 1; live.tabT0 = -1;
    if (reduced) { seek(DURATION); startLive(stateAt(DURATION)); return; }
    const t0 = performance.now();
    const tick = (now) => {
      const t = (now - t0) / 1000;
      if (t >= DURATION) { seek(DURATION); startLive(stateAt(DURATION)); return; }
      seek(t);
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  window.__ready = (document.fonts ? document.fonts.ready : Promise.resolve()).then(() => {
    layout();
    stage.classList.add('is-recording');
    seek(0);
    if (!recordMode) play();
    return true;
  });
})();
