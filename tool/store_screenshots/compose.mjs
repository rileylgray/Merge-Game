// Builds the App Store and Play Store listing images from the raw screen
// captures in build/store_raw/ (made by test/store_screenshot_capture.dart).
//
// Each slide is laid out as an HTML page — headline, sub-line and the capture
// inside a device frame — and rendered to PNG at the exact size each store
// asks for:
//
//   store_screenshots/app_store/       1290 x 2796  (iPhone 6.9"/6.7" display)
//   store_screenshots/app_store_ipad/  2064 x 2752  (iPad 13" display)
//   store_screenshots/play_store/      1080 x 1920  (phone, 9:16)
//
// Run from the repo root, after the capture test:
//
//   flutter test test/store_screenshot_capture.dart
//   NODE_PATH=$(npm root -g) node tool/store_screenshots/compose.mjs [store dir...]
//
// Needs Playwright with a Chromium it can find.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';

// Loaded through require so a global install found via NODE_PATH works too;
// ES module imports ignore NODE_PATH.
const { chromium } = createRequire(import.meta.url)('playwright');

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const rawDir = path.join(root, 'build/store_raw');
const outRoot = path.join(root, 'store_screenshots');

// Each slide's backdrop is a soft wash in its meadow's colours (`bg`, top to
// bottom), with two glows (`glow`) that also tint the headline and the pill.
// A slide may add `features: [[icon, text], ...]`, a row of pills along the
// bottom — kept off the board slides, where it would cover the app's own hint.
// `skip: [device, ...]` leaves a slide out of the stores showing those devices
// ('ios', 'ipad', 'android'), and `<device>: {...}` overrides fields for one.
const slides = [
  {
    id: '01_merge',
    shots: ['meadow_day'],
    eyebrow: 'Merge & collect',
    title: 'Merge <em>adorable</em><br>friends',
    sub: 'Drag two matching friends together and watch them grow.',
    bg: ['#d6efff', '#e8f8d8'],
    glow: ['#43a853', '#ff9f2e'],
  },
  {
    id: '02_discover',
    shots: ['discovery'],
    eyebrow: '150 friends to find',
    title: 'Discover<br><em>new friends</em>',
    sub: 'Every merge could reveal someone you have never met.',
    bg: ['#fff1d8', '#ffe2ec'],
    glow: ['#f28a1e', '#e8506e'],
  },
  {
    // Two meadows side by side, so the set shows how different they look.
    id: '03_meadows',
    shots: ['meadow_night', 'meadow_water'],
    eyebrow: 'Five meadows',
    title: 'Explore <em>magical</em><br>meadows',
    sub: 'From moonlit hedgerows to the deep blue sea.',
    bg: ['#e6e1ff', '#d6efff'],
    glow: ['#6c5ce0', '#1497c2'],
  },
  {
    id: '04_collection',
    shots: ['collection'],
    eyebrow: 'Collection',
    title: 'Fill your<br><em>collection</em>',
    sub: 'Track down every friend in all five meadows.',
    bg: ['#fdf6ea', '#e3f5d6'],
    glow: ['#43a853', '#3d8fe0'],
    // A whole meadow fits in four rows on a 13" iPad, leaving half the screen
    // bare; the wardrobe slide shows the same grid behind its sheet instead.
    skip: ['ipad'],
  },
  {
    id: '05_dress_up',
    shots: ['dress_up'],
    eyebrow: 'Wardrobe',
    title: 'Dress them <em>up</em>',
    sub: 'Crowns, top hats, capes and more for your favourite friends.',
    bg: ['#ffe7f1', '#ece2ff'],
    glow: ['#e0476a', '#9149d0'],
  },
  {
    id: '06_legends',
    shots: ['meadow_mythical', 'meadow_prehistoric'],
    eyebrow: 'Legends',
    title: 'Dragons, <em>dinos</em><br>&amp; more',
    sub: 'Merge your way up to unicorns, phoenixes and a mighty titanosaur.',
    bg: ['#f3e2ff', '#ffe4cc'],
    glow: ['#9149d0', '#e0702a'],
  },
];

// The phone captures are an iPhone-shaped window: 393 x 852 points at 3x, with
// the status bar's 59 points left for the frame to draw into. The iPad ones,
// in build/store_raw/ipad/, are a 13" iPad Pro: 1032 x 1376 at 2x.
const PHONE_PT = { w: 393, h: 852, statusBar: 59, raw: rawDir };
const IPAD_PT = { w: 1032, h: 1376, statusBar: 24, raw: path.join(rawDir, 'ipad') };

// Sizes as fractions of the canvas width (text, devices) or height (tops,
// glow centres), per store, since each store's canvas has its own shape.
const tallPhone = {
  screen: PHONE_PT,
  title: 0.102, eyebrow: 0.03, sub: 0.04, textTop: 0.062,
  deviceW: 0.8, duoW: 0.49, bezel: 0.032, radius: 0.145,
  gap: 0.032, minTop: 0.32, duoDrop: 0.075,
  spread: 0.225, tilt: 4,
  feature: 0.03, featuresBottom: 0.05, glowY: [62, 78],
};
const widePhone = {
  screen: PHONE_PT,
  title: 0.088, eyebrow: 0.028, sub: 0.036, textTop: 0.05,
  deviceW: 0.62, duoW: 0.45, bezel: 0.032, radius: 0.1,
  gap: 0.03, minTop: 0.313,
  spread: 0.22, tilt: 5,
  feature: 0.027, featuresBottom: 0.04, glowY: [70, 86],
};
const ipad = {
  screen: IPAD_PT,
  title: 0.068, eyebrow: 0.02, sub: 0.027, textTop: 0.05,
  deviceW: 0.78, duoW: 0.45, bezel: 0.026, radius: 0.058,
  gap: 0.03, minTop: 0.27, duoDrop: 0.07,
  spread: 0.235, tilt: 3,
  feature: 0.02, featuresBottom: 0.04, glowY: [66, 82],
};

const stores = [
  { dir: 'app_store', width: 1290, height: 2796, device: 'ios', layout: tallPhone },
  { dir: 'app_store_ipad', width: 2064, height: 2752, device: 'ipad', layout: ipad },
  { dir: 'play_store', width: 1080, height: 1920, device: 'android', layout: widePhone },
];

// The app asks for dark status bar icons everywhere (lib/main.dart), so the
// frame draws them dark over every screen.
const STATUS_INK = '#1c1a24';
// The headline and copy colour on the pale backdrops.
const INK = '#3b3547';

const fontUrl = (f) => pathToFileURL(path.join(here, 'fonts', f)).href;
const dataUrl = (file) =>
  `data:image/png;base64,${fs.readFileSync(file).toString('base64')}`;

const icons = {
  signal: `<svg viewBox="0 0 18 12"><rect x="0" y="8" width="3" height="4" rx="1"/><rect x="5" y="5.5" width="3" height="6.5" rx="1"/><rect x="10" y="3" width="3" height="9" rx="1"/><rect x="15" y="0" width="3" height="12" rx="1"/></svg>`,
  wifi: `<svg viewBox="0 0 16 12"><path d="M8 11.5 5.6 9a3.4 3.4 0 0 1 4.8 0z"/><path d="M3.4 6.8a6.5 6.5 0 0 1 9.2 0l-1.4 1.4a4.5 4.5 0 0 0-6.4 0z"/><path d="M1.2 4.6a9.6 9.6 0 0 1 13.6 0l-1.4 1.4a7.6 7.6 0 0 0-10.8 0z"/></svg>`,
  battery: `<svg viewBox="0 0 27 13"><rect x="0.5" y="0.5" width="23" height="12" rx="3.5" fill="none" stroke="currentColor" stroke-opacity=".4"/><rect x="2" y="2" width="20" height="9" rx="2"/><path d="M25 4.5v4a2 2 0 0 0 0-4z" fill-opacity=".4"/></svg>`,
  droidWifi: `<svg viewBox="0 0 16 13"><path d="M8 12.5 0 3.3a12.2 12.2 0 0 1 16 0z"/></svg>`,
  droidSignal: `<svg viewBox="0 0 13 13"><path d="M13 0v13H0z"/></svg>`,
  droidBattery: `<svg viewBox="0 0 8 14"><rect x="2.5" y="0" width="3" height="1.5" rx=".5"/><rect x="0" y="1.2" width="8" height="12.8" rx="1.5"/></svg>`,
  sparkle: `<svg viewBox="0 0 24 24"><path d="M12 1.5c.5 4.9 2.6 7.9 9 10.5-6.4 2.6-8.5 5.6-9 10.5-.5-4.9-2.6-7.9-9-10.5 6.4-2.6 8.5-5.6 9-10.5z"/></svg>`,
};

function statusBar(device) {
  if (device === 'ipad') {
    return `
      <div class="sb ipad">
        <span class="time">9:41<span class="date">Mon Jun 9</span></span>
        <span class="sb-icons">${icons.wifi}${icons.battery}</span>
      </div>`;
  }
  if (device === 'ios') {
    return `
      <div class="sb ios">
        <span class="time">9:41</span>
        <span class="island"></span>
        <span class="sb-icons">${icons.signal}${icons.wifi}${icons.battery}</span>
      </div>`;
  }
  return `
    <div class="sb droid">
      <span class="time">9:41</span>
      <span class="punch"></span>
      <span class="sb-icons">${icons.droidWifi}${icons.droidSignal}${icons.droidBattery}</span>
    </div>`;
}

/// A scattering of soft sparkles across the backdrop, placed the same way
/// every run so a regenerated set doesn't churn.
function sparkles(W, H, [g1, g2]) {
  const spots = [
    [0.08, 0.06, 0.05, g1], [0.9, 0.09, 0.035, g2], [0.06, 0.3, 0.03, g2],
    [0.93, 0.28, 0.045, g1], [0.16, 0.18, 0.022, g2], [0.84, 0.19, 0.025, g1],
  ];
  return spots
    .map(([x, y, s, c]) => {
      const size = Math.round(W * s);
      return `<span class="spark" style="left:${Math.round(W * x - size / 2)}px; top:${Math.round(H * y)}px; width:${size}px; height:${size}px; fill:${c}">${icons.sparkle}</span>`;
    })
    .join('');
}

function page(slide, store) {
  const { width: W, height: H, device, layout: L } = store;
  const SCREEN_PT = L.screen;

  // Headline block and phone are sized off the canvas, so the same slide
  // reads the same on every store's aspect ratio.
  const pad = Math.round(W * 0.075);
  const titleSize = Math.round(W * L.title);
  const eyebrowSize = Math.round(W * L.eyebrow);
  const subSize = Math.round(W * L.sub);
  const textTop = Math.round(H * L.textTop);

  // The phone hangs just below the copy and runs off the bottom of the canvas,
  // which keeps the screen large without crowding the headline. Its final top
  // is set in the page once the copy's real height is known.
  const duo = slide.shots.length === 2;
  const phoneW = Math.round(W * (duo ? L.duoW : L.deviceW));
  const bezel = Math.round(phoneW * L.bezel);
  const screenW = phoneW - bezel * 2;
  const screenH = Math.round(screenW * (SCREEN_PT.h / SCREEN_PT.w));
  const phoneH = screenH + bezel * 2;
  const gap = Math.round(H * L.gap);
  // Never higher than this, so a slide with a one-line sub-line keeps its
  // phone level with the rest of the set.
  const minTop = Math.round(H * L.minTop);
  // A duo is shorter than the canvas, so it can sit a little lower.
  const drop = duo ? Math.round(H * (L.duoDrop ?? 0)) : 0;
  const pt = screenW / SCREEN_PT.w; // one screen point, in canvas pixels
  const radius = Math.round(phoneW * L.radius);

  const [g1, g2] = slide.glow;
  const [b1, b2] = slide.bg;

  const phone = (shot, style) => `
    <div class="phone" style="${style}">
      ${device === 'ipad' ? '<span class="camera"></span>' : ''}
      <div class="screen">
        <img src="${dataUrl(path.join(SCREEN_PT.raw, `${shot}.png`))}">
        ${statusBar(device)}
        ${device === 'android' ? '' : '<div class="home-bar"></div>'}
      </div>
    </div>`;

  // A duo tilts the two phones toward each other, the second a step lower and
  // in front.
  const stagger = Math.round(phoneH * 0.07);
  const spread = W * L.spread;
  const tilt = L.tilt;
  const phones = duo
    ? phone(slide.shots[0],
        `left:${W / 2 - spread - phoneW / 2}px; transform: rotate(-${tilt}deg); z-index: 1;`) +
      phone(slide.shots[1],
        `left:${W / 2 + spread - phoneW / 2}px; top:${stagger}px; transform: rotate(${tilt}deg); z-index: 2;`)
    : phone(slide.shots[0], `left:${(W - phoneW) / 2}px;`);
  const features = slide.features
    ? `<div class="features">${slide.features
        .map(([icon, text]) => `<span class="feature">${icons[icon]}${text}</span>`)
        .join('')}</div>`
    : '';
  const featureSize = Math.round(W * L.feature);

  return `<!doctype html>
<html><head><meta charset="utf-8">
<style>
  @font-face { font-family: Poppins; font-weight: 600; src: url(${fontUrl('Poppins-600.woff2')}); }
  @font-face { font-family: Poppins; font-weight: 800; src: url(${fontUrl('Poppins-800.woff2')}); }
  @font-face { font-family: Inter; font-weight: 100 900; src: url(${fontUrl('Inter.woff2')}); }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: ${W}px; height: ${H}px; overflow: hidden; }
  body {
    position: relative;
    background:
      radial-gradient(ellipse ${W * 0.9}px ${H * 0.42}px at 10% ${L.glowY[0]}%, ${g1}40, transparent 70%),
      radial-gradient(ellipse ${W * 0.8}px ${H * 0.38}px at 92% ${L.glowY[1]}%, ${g2}38, transparent 70%),
      radial-gradient(ellipse ${W}px ${H * 0.3}px at 50% 0%, #ffffffcc, transparent 75%),
      linear-gradient(180deg, ${b1} 0%, ${b2} 100%);
    font-family: Inter, sans-serif;
    color: ${INK};
    -webkit-font-smoothing: antialiased;
  }
  /* A faint dot grid for texture. */
  body::before {
    content: ''; position: absolute; inset: 0;
    background-image: radial-gradient(rgba(59,53,71,.08) ${Math.max(1, W / 540)}px, transparent 0);
    background-size: ${Math.round(W / 18)}px ${Math.round(W / 18)}px;
    mask-image: linear-gradient(180deg, #000 0%, transparent 55%);
  }
  .spark { position: absolute; opacity: .5; }
  .spark svg { width: 100%; height: 100%; }
  .copy {
    position: absolute; left: ${pad}px; right: ${pad}px; top: ${textTop}px;
    text-align: center;
  }
  .eyebrow {
    display: inline-block;
    font-family: Poppins; font-weight: 600;
    font-size: ${eyebrowSize}px; letter-spacing: .14em; text-transform: uppercase;
    padding: ${eyebrowSize * 0.45}px ${eyebrowSize * 1.1}px;
    border-radius: 999px;
    color: #fff;
    background: linear-gradient(90deg, ${g1}, ${g2});
    box-shadow: 0 ${eyebrowSize * 0.3}px ${eyebrowSize * 1.2}px ${g1}55;
  }
  h1 {
    margin-top: ${Math.round(titleSize * 0.32)}px;
    font-family: Poppins; font-weight: 800;
    font-size: ${titleSize}px; line-height: 1.08; letter-spacing: -0.02em;
    text-wrap: balance;
  }
  h1 em {
    font-style: normal;
    background: linear-gradient(90deg, ${g1}, ${g2});
    -webkit-background-clip: text; background-clip: text; color: transparent;
  }
  p.sub {
    margin: ${Math.round(subSize * 0.7)}px auto 0; max-width: ${Math.round(W * 0.78)}px;
    font-size: ${subSize}px; line-height: 1.4; font-weight: 500;
    color: rgba(59, 53, 71, .74);
    text-wrap: balance;
  }
  .stage { position: absolute; left: 0; right: 0; top: 0; height: ${H}px; }
  .phone {
    position: absolute; top: 0;
    width: ${phoneW}px; height: ${phoneH}px;
    padding: ${bezel}px;
    border-radius: ${radius}px;
    background: linear-gradient(145deg, #3a3a48, #101016 40%, #2a2a36);
    box-shadow:
      0 0 0 ${Math.max(2, bezel * 0.12)}px #54546a inset,
      0 ${W * 0.035}px ${W * 0.09}px rgba(40, 30, 60, .32),
      0 0 ${W * 0.12}px ${g1}30;
  }
  .phone .camera {
    position: absolute; right: ${bezel / 2}px; top: 50%;
    width: ${bezel * 0.32}px; height: ${bezel * 0.32}px; margin: ${-bezel * 0.16}px ${-bezel * 0.16}px 0 0;
    border-radius: 50%; background: #05050a; box-shadow: 0 0 0 ${bezel * 0.06}px #22222e;
  }
  .screen {
    position: relative; width: ${screenW}px; height: ${screenH}px;
    border-radius: ${radius - bezel}px; overflow: hidden; background: #000;
  }
  .screen img { display: block; width: 100%; height: 100%; }
  .sb {
    position: absolute; left: 0; right: 0; top: 0; height: ${SCREEN_PT.statusBar * pt}px;
    display: flex; align-items: center; justify-content: space-between;
    color: ${STATUS_INK}; font-family: Inter; font-weight: 600;
  }
  .sb svg { fill: ${STATUS_INK}; }
  .sb.ios { padding: 0 ${30 * pt}px 0 ${44 * pt}px; font-size: ${17 * pt}px; padding-top: ${4 * pt}px; }
  .sb.ios .island {
    position: absolute; left: 50%; top: ${11 * pt}px; transform: translateX(-50%);
    width: ${125 * pt}px; height: ${37 * pt}px; border-radius: ${19 * pt}px; background: #000;
  }
  .sb.ios .sb-icons { display: flex; gap: ${6 * pt}px; align-items: center; }
  .sb.ios .sb-icons svg { height: ${12 * pt}px; width: auto; }
  .sb.ios .sb-icons svg:last-child { height: ${13 * pt}px; }
  .sb.ipad { padding: 0 ${20 * pt}px 0 ${24 * pt}px; font-size: ${13 * pt}px; }
  .sb.ipad .date { margin-left: ${7 * pt}px; }
  .sb.ipad .sb-icons { display: flex; gap: ${6 * pt}px; align-items: center; }
  .sb.ipad .sb-icons svg { height: ${10 * pt}px; width: auto; }
  .sb.ipad .sb-icons svg:last-child { height: ${11.5 * pt}px; }
  .sb.droid { padding: 0 ${26 * pt}px; font-size: ${15 * pt}px; font-weight: 500; }
  .sb.droid .punch {
    position: absolute; left: 50%; top: ${20 * pt}px; transform: translateX(-50%);
    width: ${22 * pt}px; height: ${22 * pt}px; border-radius: 50%; background: #000;
    box-shadow: 0 0 0 ${2 * pt}px #1a1a22;
  }
  .sb.droid .sb-icons { display: flex; gap: ${6 * pt}px; align-items: center; }
  .sb.droid .sb-icons svg { height: ${13 * pt}px; width: auto; }
  .features {
    position: absolute; left: ${pad * 0.5}px; right: ${pad * 0.5}px; bottom: ${Math.round(H * L.featuresBottom)}px;
    display: flex; justify-content: center; flex-wrap: wrap; gap: ${featureSize * 0.6}px;
    z-index: 4;
  }
  .feature {
    display: inline-flex; align-items: center; gap: ${featureSize * 0.45}px;
    font-family: Inter; font-weight: 700; font-size: ${featureSize}px; color: ${INK};
    padding: ${featureSize * 0.55}px ${featureSize * 0.9}px;
    border-radius: 999px;
    background: rgba(255, 255, 255, .94);
    box-shadow: 0 0 0 ${Math.max(1.5, featureSize * 0.06)}px ${g1}33 inset,
      0 ${featureSize * 0.3}px ${featureSize}px rgba(40, 30, 60, .18);
  }
  .feature svg { width: ${featureSize * 1.15}px; height: ${featureSize * 1.15}px; fill: ${g2}; }
  .home-bar {
    position: absolute; left: 50%; bottom: ${8 * pt}px; transform: translateX(-50%);
    width: ${(device === 'ipad' ? 300 : 134) * pt}px; height: ${5 * pt}px; border-radius: ${3 * pt}px; background: rgba(28, 26, 36, .55);
  }
</style></head>
<body>
  ${sparkles(W, H, slide.glow)}
  <div class="copy">
    <div class="eyebrow">${slide.eyebrow}</div>
    <h1>${slide.title}</h1>
    <p class="sub">${slide.sub}</p>
  </div>
  <div class="stage">${phones}</div>
  ${features}
  <script>
    document.fonts.ready.then(() => {
      const copy = document.querySelector('.copy');
      document.querySelector('.stage').style.top =
        Math.max(${minTop}, copy.offsetTop + copy.offsetHeight + ${gap}) + ${drop} + 'px';
      document.body.dataset.ready = '1';
    });
  </script>
</body></html>`;
}

// The slides a store shows: all of them, less any that skip its device.
const slidesFor = (store) => slides.filter((s) => !s.skip?.includes(store.device));

const missing = [...new Set(stores.flatMap((store) =>
  slidesFor(store).flatMap((s) => s.shots).map((shot) => path.join(store.layout.screen.raw, `${shot}.png`))))]
  .filter((file) => !fs.existsSync(file))
  .map((file) => path.relative(rawDir, file));
if (missing.length) {
  console.error(`Missing captures in ${rawDir}: ${missing.join(', ')}`);
  console.error('Run: flutter test test/store_screenshot_capture.dart');
  process.exit(1);
}

// Optional store folders to build, e.g. `compose.mjs app_store_ipad`; all by
// default.
const only = process.argv.slice(2);
const browser = await chromium.launch();
try {
  for (const store of stores.filter((s) => !only.length || only.includes(s.dir))) {
    const outDir = path.join(outRoot, store.dir);
    fs.mkdirSync(outDir, { recursive: true });
    const pg = await browser.newPage({
      viewport: { width: store.width, height: store.height },
      deviceScaleFactor: 1,
    });
    for (const slide of slides.filter((s) => !slidesFor(store).includes(s))) {
      fs.rmSync(path.join(outDir, `${slide.id}.png`), { force: true });
    }
    for (const slide of slidesFor(store)) {
      const html = path.join(rawDir, `_${store.dir}_${slide.id}.html`);
      fs.writeFileSync(html, page({ ...slide, ...slide[store.device] }, store));
      await pg.goto(pathToFileURL(html).href);
      await pg.waitForSelector('body[data-ready="1"]');
      const out = path.join(outDir, `${slide.id}.png`);
      await pg.screenshot({ path: out, omitBackground: false });
      console.log(`  ${path.relative(root, out)}`);
    }
    await pg.close();
  }
} finally {
  await browser.close();
}
