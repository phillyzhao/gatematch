/* ============================================================
   GateMatch — "The Journey"
   One continuous Three.js world (home → gate → sky → event),
   camera scrubbed by GSAP ScrollTrigger. DOM overlays narrate.
   ============================================================ */
import * as THREE from 'three';

const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const $ = (s) => document.querySelector(s);
const clamp01 = (v) => Math.min(1, Math.max(0, v));

function webglOK() {
  try {
    const c = document.createElement('canvas');
    return !!(window.WebGLRenderingContext && (c.getContext('webgl2') || c.getContext('webgl')));
  } catch (e) { return false; }
}

const RM = reduce || !webglOK() || !window.gsap;
if (RM) document.documentElement.classList.add('rm');
if (window.gsap && window.ScrollTrigger) gsap.registerPlugin(ScrollTrigger);

/* ============================================================
   Preloader — the plane flies EXACTLY ONE lap, and that lap is
   driven by real load progress: it advances as resources arrive
   (trickles while waiting, snaps to 100% on load+fonts), so the
   plane's speed maps directly to how fast the page is loading.
   The site reveals the instant the plane completes its one lap.
   ============================================================ */
const introTl = (!RM && window.gsap) ? gsap.timeline({ paused: true }) : null;
window.__intro = introTl;

(function preloader() {
  const pre = $('#preloader');
  if (!pre) { document.body.classList.add('loaded'); return; }
  const rotor = $('#plRotor');
  const arc = pre.querySelector('.pl-arc');
  const ARC_LEN = 326.7;                 // circumference of the r=52 ring
  let finished = false;
  document.body.style.overflow = 'hidden';

  // progress model: `target` is where loading actually is, `cur` chases it
  let cur = 0, target = 0.08, loaded = false, fontsDone = false;
  const start = performance.now();
  const MIN_MS = 700;                    // never let the lap feel like a flash

  function done() { return loaded && fontsDone; }
  function bumpTargets() {
    if (document.readyState === 'interactive') target = Math.max(target, 0.35);
    if (document.readyState === 'complete') { loaded = true; target = Math.max(target, 0.9); }
  }
  bumpTargets();
  document.addEventListener('readystatechange', bumpTargets);
  window.addEventListener('load', () => { loaded = true; target = Math.max(target, 0.9); }, { once: true });
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(() => { fontsDone = true; }).catch(() => { fontsDone = true; });
  else fontsDone = true;
  setTimeout(() => { fontsDone = true; }, 1000);   // fonts are non-blocking — never let them stall the lap

  function finish() {
    if (finished) return; finished = true;
    if (rotor) rotor.style.transform = 'rotate(360deg)';   // land exactly at the origin
    if (arc) arc.style.strokeDashoffset = 0;
    pre.classList.add('done');
    document.body.classList.add('loaded');
    document.body.style.overflow = '';
    setTimeout(() => pre.remove(), 700);
    if (introTl) {
      introTl.play();
      gsap.to('#rail', { autoAlpha: 1, duration: .8, delay: .6 });
    }
  }

  function tick(now) {
    const elapsed = now - start;
    // trickle forward while we wait so the plane never stalls, but cap below 90%
    if (!done()) target = Math.min(0.9, target + 0.0016);
    // once truly loaded (and past the minimum), aim for a full lap
    if (done() && elapsed >= MIN_MS) target = 1;
    cur += (target - cur) * 0.08;
    if (target >= 1 && cur > 0.995) cur = 1;
    if (rotor) rotor.style.transform = 'rotate(' + (cur * 360).toFixed(2) + 'deg)';
    if (arc) arc.style.strokeDashoffset = (ARC_LEN * (1 - cur)).toFixed(1);
    if (cur >= 1) return finish();
    requestAnimationFrame(tick);
  }
  if (reduce) { finish(); return; }                          // no spin for reduced-motion
  requestAnimationFrame(tick);
  setTimeout(finish, 6000);                                  // hard safety net
})();

/* ============================================================
   Word-mask splitting for the big display lines
   ============================================================ */
function splitWords(el) {
  const words = el.textContent.trim().split(/\s+/);
  el.setAttribute('aria-label', el.textContent.trim());
  el.innerHTML = words.map(w => `<span class="wm" aria-hidden="true"><span class="wd">${w}</span></span>`).join(' ');
  return [...el.querySelectorAll('.wd')];
}

/* ============================================================
   THE WORLD
   ============================================================ */
function initJourney() {
  const canvas = $('#gl');
  const stage = $('#stage');

  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.75));
  renderer.setSize(stage.clientWidth, stage.clientHeight);
  renderer.setClearColor(0x05070d);

  const scene = new THREE.Scene();
  scene.fog = new THREE.FogExp2(0x0a1220, 0.0145);

  const camera = new THREE.PerspectiveCamera(55, stage.clientWidth / stage.clientHeight, 0.1, 1600);
  scene.add(camera);

  /* ---------- shared textures ---------- */
  function glowTexture(inner, outer) {
    const c = document.createElement('canvas'); c.width = c.height = 128;
    const x = c.getContext('2d');
    const g = x.createRadialGradient(64, 64, 2, 64, 64, 64);
    g.addColorStop(0, inner); g.addColorStop(.35, outer); g.addColorStop(1, 'rgba(0,0,0,0)');
    x.fillStyle = g; x.fillRect(0, 0, 128, 128);
    const t = new THREE.CanvasTexture(c); t.colorSpace = THREE.SRGBColorSpace; return t;
  }
  const glowWarm = glowTexture('rgba(255,196,130,.95)', 'rgba(255,150,70,.28)');
  const glowBlue = glowTexture('rgba(190,208,255,.95)', 'rgba(80,110,230,.30)');
  const glowSoft = glowTexture('rgba(205,220,250,.55)', 'rgba(120,140,200,.16)');

  /* ---------- sky dome (night → dawn hint at horizon) ---------- */
  (function skyDome() {
    const c = document.createElement('canvas'); c.width = 2; c.height = 1024;
    const x = c.getContext('2d');
    const g = x.createLinearGradient(0, 0, 0, 1024);
    g.addColorStop(0.00, '#02040a');
    g.addColorStop(0.38, '#060d1a');
    g.addColorStop(0.52, '#0a1424');
    g.addColorStop(0.60, '#142347');
    g.addColorStop(0.645, '#1d2c55');
    g.addColorStop(0.68, '#0a1120');
    g.addColorStop(1.00, '#04070d');
    x.fillStyle = g; x.fillRect(0, 0, 2, 1024);
    const tex = new THREE.CanvasTexture(c); tex.colorSpace = THREE.SRGBColorSpace;
    const dome = new THREE.Mesh(
      new THREE.SphereGeometry(760, 28, 20),
      new THREE.MeshBasicMaterial({ map: tex, side: THREE.BackSide, fog: false, depthWrite: false })
    );
    dome.position.z = -160; dome.renderOrder = -10;
    scene.add(dome);
  })();

  /* ---------- stars ---------- */
  const stars = (function stars() {
    const n = 900, pos = new Float32Array(n * 3);
    for (let i = 0; i < n; i++) {
      const r = 520 + Math.random() * 180;
      const th = Math.random() * Math.PI * 2;
      const ph = Math.acos(1 - Math.random() * 0.92);       // bias to upper dome
      pos[i * 3] = r * Math.sin(ph) * Math.cos(th);
      pos[i * 3 + 1] = Math.abs(r * Math.cos(ph)) - 30;
      pos[i * 3 + 2] = -160 + r * Math.sin(ph) * Math.sin(th);
    }
    const g = new THREE.BufferGeometry();
    g.setAttribute('position', new THREE.BufferAttribute(pos, 3));
    const m = new THREE.PointsMaterial({ color: 0xbfd0e8, size: 1.5, sizeAttenuation: false, transparent: true, opacity: .8, fog: false, depthWrite: false });
    const p = new THREE.Points(g, m);
    scene.add(p); return p;
  })();

  /* ---------- ground ---------- */
  const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(1000, 900),
    new THREE.MeshBasicMaterial({ color: 0x05080e })
  );
  ground.rotation.x = -Math.PI / 2;
  ground.position.set(0, 0, -160);
  scene.add(ground);

  /* ---------- chapter 1 · HOME (sleeping neighborhood) ---------- */
  (function home() {
    const nHouse = 64;
    const geo = new THREE.BoxGeometry(1, 1, 1); geo.translate(0, .5, 0);
    const inst = new THREE.InstancedMesh(geo, new THREE.MeshBasicMaterial({ color: 0x0c131d }), nHouse);
    const dummy = new THREE.Object3D();
    const lightPos = [];
    for (let i = 0; i < nHouse; i++) {
      const side = Math.random() < .5 ? -1 : 1;
      const x = side * (5 + Math.random() * 26);
      const z = 12 - Math.random() * 84;
      const sx = 2.2 + Math.random() * 3, sy = 1.6 + Math.random() * 2.6, sz = 2.2 + Math.random() * 3;
      dummy.position.set(x, 0, z);
      dummy.scale.set(sx, sy, sz);
      dummy.rotation.y = (Math.random() - .5) * .3;
      dummy.updateMatrix();
      inst.setMatrixAt(i, dummy.matrix);
      const nl = 1 + Math.floor(Math.random() * 3);        // lit windows
      for (let k = 0; k < nl; k++) {
        lightPos.push(x + (Math.random() - .5) * sx * .7, .6 + Math.random() * (sy * .8), z + (Math.random() - .5) * sz * .7 + (x > 0 ? -sz / 2 : sz / 2));
      }
    }
    scene.add(inst);
    const lg = new THREE.BufferGeometry();
    lg.setAttribute('position', new THREE.BufferAttribute(new Float32Array(lightPos), 3));
    scene.add(new THREE.Points(lg, new THREE.PointsMaterial({ color: 0xffb36b, size: 3, sizeAttenuation: false, transparent: true, opacity: .9, depthWrite: false })));
    // your house — a warm porch light by the door
    const porch = new THREE.Sprite(new THREE.SpriteMaterial({ map: glowWarm, transparent: true, opacity: .7, depthWrite: false }));
    porch.position.set(3.4, .9, 5); porch.scale.set(2.2, 2.2, 1);
    scene.add(porch);
    // street lights tracing the road out of the neighborhood
    const sp = [];
    for (let i = 0; i < 26; i++) {
      const z = 8 - i * 3.6;
      sp.push((i % 2 ? 1.9 : -1.9) + (Math.random() - .5) * .4, .18, z);
    }
    const sg = new THREE.BufferGeometry();
    sg.setAttribute('position', new THREE.BufferAttribute(new Float32Array(sp), 3));
    scene.add(new THREE.Points(sg, new THREE.PointsMaterial({ color: 0x5f7fc4, size: 2.4, sizeAttenuation: false, transparent: true, opacity: .8, depthWrite: false })));
  })();

  /* ---------- chapter 2 · GATE (terminal wall + travelers + matches) ---------- */
  const gate = (function gateSet() {
    const grp = new THREE.Group(); scene.add(grp);
    // glowing glass wall
    const glass = new THREE.Mesh(new THREE.PlaneGeometry(130, 13), new THREE.MeshBasicMaterial({ color: 0x0e1728 }));
    glass.position.set(0, 6.5, -119.6); grp.add(glass);
    const roof = new THREE.Mesh(new THREE.BoxGeometry(134, .7, 1.4), new THREE.MeshBasicMaterial({ color: 0x080d16 }));
    roof.position.set(0, 13.3, -119.3); grp.add(roof);
    // mullions
    const nM = 58;
    const mull = new THREE.InstancedMesh(new THREE.BoxGeometry(.28, 13, .28), new THREE.MeshBasicMaterial({ color: 0x04080f }), nM);
    const d = new THREE.Object3D();
    for (let i = 0; i < nM; i++) { d.position.set(-63 + i * 2.2, 6.5, -119.2); d.updateMatrix(); mull.setMatrixAt(i, d.matrix); }
    grp.add(mull);
    // gate sign (canvas texture, drawn once fonts are ready)
    const signC = document.createElement('canvas'); signC.width = 640; signC.height = 168;
    const signTex = new THREE.CanvasTexture(signC); signTex.colorSpace = THREE.SRGBColorSpace;
    function drawSign() {
      const x = signC.getContext('2d');
      x.fillStyle = '#001e6c'; x.fillRect(0, 0, 640, 168);
      x.strokeStyle = 'rgba(126,155,247,.5)'; x.lineWidth = 4; x.strokeRect(6, 6, 628, 156);
      x.fillStyle = '#fff'; x.textAlign = 'center'; x.textBaseline = 'middle';
      x.font = '800 84px Manrope, sans-serif';
      x.fillText('GATE B22 →', 320, 90);
      signTex.needsUpdate = true;
    }
    drawSign();
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(drawSign).catch(() => {});
    const signMat = new THREE.MeshBasicMaterial({ map: signTex, transparent: true, opacity: .06 });
    const sign = new THREE.Mesh(new THREE.PlaneGeometry(7.4, 1.94), signMat);
    sign.position.set(0, 8.7, -117.4); grp.add(sign);
    // travelers waiting
    const nT = 46, tPos = [];
    const trav = new THREE.InstancedMesh(new THREE.CapsuleGeometry(.22, .95, 2, 8), new THREE.MeshBasicMaterial({ color: 0x0a1119 }), nT);
    for (let i = 0; i < nT; i++) {
      const x = -30 + Math.random() * 60, z = -100 - Math.random() * 15;
      tPos.push(new THREE.Vector3(x, .9, z));
      d.position.set(x, .9, z); d.rotation.y = Math.random() * Math.PI; d.updateMatrix();
      trav.setMatrixAt(i, d.matrix);
    }
    grp.add(trav);
    // match arcs — pairs of travelers light up and connect
    const pairs = [];
    const used = new Set();
    for (let i = 0; i < 6; i++) {
      let a, b;
      do { a = Math.floor(Math.random() * nT); } while (used.has(a)); used.add(a);
      do { b = Math.floor(Math.random() * nT); } while (used.has(b) || tPos[a].distanceTo(tPos[b]) < 6); used.add(b);
      const pa = tPos[a].clone().setY(1.9), pb = tPos[b].clone().setY(1.9);
      const mid = pa.clone().add(pb).multiplyScalar(.5); mid.y += 2.6 + Math.random() * 1.6;
      const curve = new THREE.QuadraticBezierCurve3(pa, mid, pb);
      const pts = curve.getPoints(48);
      const lineGeo = new THREE.BufferGeometry().setFromPoints(pts);
      const line = new THREE.Line(lineGeo, new THREE.LineBasicMaterial({ color: 0x5b7cf4, transparent: true, opacity: .95 }));
      line.geometry.setDrawRange(0, 0);
      const dotM = () => new THREE.Sprite(new THREE.SpriteMaterial({ map: glowBlue, transparent: true, opacity: 0, depthWrite: false }));
      const dotA = dotM(), dotB = dotM();
      dotA.position.copy(pa); dotB.position.copy(pb);
      dotA.scale.set(1.2, 1.2, 1); dotB.scale.set(1.2, 1.2, 1);
      grp.add(line, dotA, dotB);
      pairs.push({ line, dotA, dotB, n: pts.length });
    }

    // boarding door — set into the glass wall where the route passes through,
    // so the journey enters through an opening (not magically through glass)
    const DW = 6, DH = 7, DZ = -119.0;
    const doorGlow = new THREE.Mesh(
      new THREE.PlaneGeometry(DW * 1.08, DH * 1.02),
      new THREE.MeshBasicMaterial({ color: 0xaec4ff, transparent: true, opacity: 0, blending: THREE.AdditiveBlending, depthWrite: false })
    );
    doorGlow.position.set(0, DH / 2, DZ - .35); grp.add(doorGlow);
    const frameMat = new THREE.MeshBasicMaterial({ color: 0x8aa2ff, transparent: true, opacity: 1 });
    const post = new THREE.BoxGeometry(.24, DH + .35, .24);
    const postL = new THREE.Mesh(post, frameMat); postL.position.set(-DW / 2 - .12, DH / 2, DZ);
    const postR = new THREE.Mesh(post, frameMat); postR.position.set(DW / 2 + .12, DH / 2, DZ);
    const lintel = new THREE.Mesh(new THREE.BoxGeometry(DW + .6, .24, .24), frameMat); lintel.position.set(0, DH + .12, DZ);
    grp.add(postL, postR, lintel);
    const panelMat = new THREE.MeshBasicMaterial({ color: 0x0c1522 });
    const panelGeo = new THREE.BoxGeometry(DW / 2, DH, .16);
    const panelL = new THREE.Mesh(panelGeo, panelMat); panelL.position.set(-DW / 4, DH / 2, DZ);
    const panelR = new THREE.Mesh(panelGeo, panelMat); panelR.position.set(DW / 4, DH / 2, DZ);
    grp.add(panelL, panelR);

    return { pairs, signMat, door: { panelL, panelR, glow: doorGlow, quarterW: DW / 4, travel: DW / 2 + .3 } };
  })();

  /* ---------- chapter 3 · SKY (clouds, moon — view kept clear, no wing) ---------- */
  const sky = (function skySet() {
    const cloudMat = new THREE.SpriteMaterial({ map: glowSoft, transparent: true, opacity: .34, depthWrite: false });
    const clouds = [];
    for (let i = 0; i < 130; i++) {
      const s = new THREE.Sprite(cloudMat);
      const sc = 9 + Math.random() * 18;
      s.scale.set(sc * (1.5 + Math.random()), sc, 1);
      s.position.set(-75 + Math.random() * 150, 15 + Math.random() * 30, -128 - Math.random() * 168);
      s.userData.v = .18 + Math.random() * .5;
      scene.add(s); clouds.push(s);
    }
    const moon = new THREE.Sprite(new THREE.SpriteMaterial({ map: glowBlue, transparent: true, opacity: .5, fog: false, depthWrite: false }));
    moon.position.set(150, 210, -560); moon.scale.set(70, 70, 1);
    scene.add(moon);
    return { clouds };
  })();

  /* ---------- chapter 4 · EVENT (city, venue beacon, network) ---------- */
  const eventSet = (function eventSet() {
    const grp = new THREE.Group(); scene.add(grp);
    const VENUE = new THREE.Vector3(0, 0, -318);
    // city blocks
    const nB = 380;
    const bGeo = new THREE.BoxGeometry(1, 1, 1); bGeo.translate(0, .5, 0);
    const city = new THREE.InstancedMesh(bGeo, new THREE.MeshBasicMaterial({ color: 0x0a1119 }), nB);
    const d = new THREE.Object3D();
    let placed = 0, guard = 0;
    while (placed < nB && guard++ < 4000) {
      const x = -88 + Math.random() * 176, z = -270 - Math.random() * 84;
      if (Math.hypot(x - VENUE.x, z - VENUE.z) < 9) continue;
      const central = 1 - Math.min(1, Math.abs(x) / 88);
      d.position.set(x, 0, z);
      d.scale.set(2.4 + Math.random() * 2.4, 1.6 + Math.random() * (4 + central * 11), 2.4 + Math.random() * 2.4);
      d.updateMatrix(); city.setMatrixAt(placed++, d.matrix);
    }
    grp.add(city);
    // city window lights
    const nL = 720, lp = new Float32Array(nL * 3);
    for (let i = 0; i < nL; i++) {
      lp[i * 3] = -88 + Math.random() * 176;
      lp[i * 3 + 1] = .5 + Math.random() * 12;
      lp[i * 3 + 2] = -270 - Math.random() * 84;
    }
    const lg = new THREE.BufferGeometry(); lg.setAttribute('position', new THREE.BufferAttribute(lp, 3));
    grp.add(new THREE.Points(lg, new THREE.PointsMaterial({ color: 0x9fb8ff, size: 1.9, sizeAttenuation: false, transparent: true, opacity: .7, depthWrite: false })));
    // the venue — landmark + light beam + glow
    const venue = new THREE.Mesh(new THREE.BoxGeometry(4.6, 9, 4.6), new THREE.MeshBasicMaterial({ color: 0x0e1830 }));
    venue.position.set(VENUE.x, 4.5, VENUE.z); grp.add(venue);
    const beam = new THREE.Mesh(
      new THREE.CylinderGeometry(.4, 1.1, 30, 12, 1, true),
      new THREE.MeshBasicMaterial({ color: 0x2e55e0, transparent: true, opacity: .16, side: THREE.DoubleSide, depthWrite: false, blending: THREE.AdditiveBlending })
    );
    beam.position.set(VENUE.x, 15, VENUE.z); grp.add(beam);
    const vglow = new THREE.Sprite(new THREE.SpriteMaterial({ map: glowBlue, transparent: true, opacity: .55, depthWrite: false }));
    vglow.position.set(VENUE.x, 9.5, VENUE.z); vglow.scale.set(16, 16, 1); grp.add(vglow);
    // attendee constellation above the venue
    const nodes = [], nN = 16;
    const nodeGeo = new THREE.SphereGeometry(.28, 10, 10);
    const edgePts = [];
    const nodePos = [];
    for (let i = 0; i < nN; i++) {
      const a = (i / nN) * Math.PI * 2 + Math.random() * .3;
      const r = 7 + Math.random() * 5;
      const p = new THREE.Vector3(VENUE.x + Math.cos(a) * r, 10 + Math.random() * 8, VENUE.z + Math.sin(a) * r * .8);
      nodePos.push(p);
      const n = new THREE.Mesh(nodeGeo, new THREE.MeshBasicMaterial({ color: 0x7e9bf7 }));
      n.position.copy(p); n.scale.setScalar(0.0001);
      grp.add(n); nodes.push(n);
    }
    for (let i = 0; i < nN; i++) {
      edgePts.push(nodePos[i], nodePos[(i + 3) % nN]);
      if (i % 2 === 0) edgePts.push(nodePos[i], new THREE.Vector3(VENUE.x, 9.4, VENUE.z));
    }
    const eg = new THREE.BufferGeometry().setFromPoints(edgePts);
    const edgeMat = new THREE.LineBasicMaterial({ color: 0x2e55e0, transparent: true, opacity: 0 });
    grp.add(new THREE.LineSegments(eg, edgeMat));
    return { nodes, edgeMat };
  })();

  /* ---------- the route — one blue thread through the whole story ---------- */
  const route = (function routeLine() {
    const curve = new THREE.CatmullRomCurve3([
      new THREE.Vector3(3.6, .8, 6.2),      // your front door
      new THREE.Vector3(1.4, .8, -8),
      new THREE.Vector3(0, .9, -34),
      new THREE.Vector3(0, 1.0, -72),
      new THREE.Vector3(0, 1.3, -102),
      new THREE.Vector3(0, 1.6, -115),      // the gate
      new THREE.Vector3(0, 7, -128),        // takeoff
      new THREE.Vector3(0, 19, -148),
      new THREE.Vector3(0, 31, -178),
      new THREE.Vector3(0, 37, -212),       // cruise
      new THREE.Vector3(0, 33, -252),
      new THREE.Vector3(0, 21, -282),
      new THREE.Vector3(0, 9, -304),
      new THREE.Vector3(0, 2.4, -316.5),    // the venue
    ]);
    const SEG = 700;
    const tube = new THREE.Mesh(
      new THREE.TubeGeometry(curve, SEG, .07, 6),
      new THREE.MeshBasicMaterial({ color: 0x2e55e0, transparent: true, opacity: .9 })
    );
    tube.geometry.setDrawRange(0, 0);
    scene.add(tube);
    const spark = new THREE.Sprite(new THREE.SpriteMaterial({ map: glowBlue, transparent: true, opacity: .95, depthWrite: false }));
    spark.scale.set(2, 2, 1);
    scene.add(spark);
    const IDX_PER_SEG = 6 * 6;
    return {
      set(p) {
        tube.geometry.setDrawRange(0, Math.floor(p * SEG) * IDX_PER_SEG);
        spark.position.copy(curve.getPointAt(clamp01(p)));
        spark.material.opacity = p <= 0 ? 0 : .95;
      }
    };
  })();

  /* ---------- camera rails ---------- */
  const camPath = new THREE.CatmullRomCurve3([
    new THREE.Vector3(0, 2.6, 15),
    new THREE.Vector3(0, 3.0, -4),
    new THREE.Vector3(1.6, 3.4, -24),
    new THREE.Vector3(-1.2, 4.2, -48),
    new THREE.Vector3(0, 3.6, -76),
    new THREE.Vector3(0, 3.4, -98),
    new THREE.Vector3(0, 4.4, -112),
    new THREE.Vector3(0, 12, -138),
    new THREE.Vector3(0, 26, -168),
    new THREE.Vector3(0, 34, -205),
    new THREE.Vector3(0, 33, -238),
    new THREE.Vector3(0, 24, -266),
    new THREE.Vector3(0, 13, -290),
    new THREE.Vector3(0, 8.8, -303),
  ]);
  const tgtPath = new THREE.CatmullRomCurve3([
    new THREE.Vector3(0, 2.4, -10),
    new THREE.Vector3(0, 2.5, -30),
    new THREE.Vector3(0, 2.9, -52),
    new THREE.Vector3(0, 4.0, -80),
    new THREE.Vector3(0, 5.6, -106),
    new THREE.Vector3(0, 6.6, -118),
    new THREE.Vector3(0, 8.2, -124),
    new THREE.Vector3(0, 18, -155),
    new THREE.Vector3(0, 30, -195),
    new THREE.Vector3(0, 35, -235),
    new THREE.Vector3(0, 28, -268),
    new THREE.Vector3(0, 16, -296),
    new THREE.Vector3(0, 8, -314),
    new THREE.Vector3(0, 6, -318),
  ]);

  /* ---------- scroll-driven state ---------- */
  const proxy = { cam: 0, route: 0, gateMatch: 0, eventNet: 0, fog: 0.012, door: 0 };
  const pointer = { x: 0, y: 0, tx: 0, ty: 0 };
  if (window.matchMedia('(pointer:fine)').matches) {
    window.addEventListener('mousemove', (e) => {
      pointer.tx = (e.clientX / window.innerWidth - .5) * 2;
      pointer.ty = (e.clientY / window.innerHeight - .5) * 2;
    }, { passive: true });
  }

  /* ---------- render loop ---------- */
  const camPos = new THREE.Vector3(), camTgt = new THREE.Vector3();
  let elapsed = 0;
  function frame(time, dtMs) {
    const dt = Math.min(dtMs / 1000, .05);
    elapsed += dt;
    pointer.x += (pointer.tx - pointer.x) * .05;
    pointer.y += (pointer.ty - pointer.y) * .05;

    const p = clamp01(proxy.cam);
    camPath.getPointAt(p, camPos);
    tgtPath.getPointAt(p, camTgt);
    camPos.x += pointer.x * .8;
    camPos.y += pointer.y * -.5 + Math.sin(elapsed * .8) * .05;
    camera.position.copy(camPos);
    camera.lookAt(camTgt);
    // gentle bank while cruising
    const bank = Math.sin(Math.PI * clamp01((p - .58) / .2)) * -.05 + pointer.x * -.02;
    camera.rotateZ(bank);

    scene.fog.density = proxy.fog;
    stars.rotation.y += dt * .004;
    gate.signMat.opacity = .06 + .94 * clamp01((p - .26) / .1);   // the gate reveals itself on approach

    // boarding doors slide apart, light spills from the opening
    const dOpen = clamp01(proxy.door);
    gate.door.panelL.position.x = -gate.door.quarterW - dOpen * gate.door.travel;
    gate.door.panelR.position.x = gate.door.quarterW + dOpen * gate.door.travel;
    gate.door.glow.material.opacity = dOpen * .6;

    route.set(proxy.route);

    gate.pairs.forEach((pr, i) => {
      const pi = clamp01(proxy.gateMatch * 1.5 - i * .1);
      pr.line.geometry.setDrawRange(0, Math.floor(pr.n * pi));
      pr.dotA.material.opacity = Math.min(1, pi * 3) * .95;
      pr.dotB.material.opacity = clamp01((pi - .85) * 6) * .95;
    });

    sky.clouds.forEach(s => {
      s.position.x += s.userData.v * dt;
      if (s.position.x > 85) s.position.x = -85;
    });

    eventSet.nodes.forEach((n, i) => {
      n.scale.setScalar(Math.max(.0001, clamp01(proxy.eventNet * 1.6 - i * .05)));
    });
    eventSet.edgeMat.opacity = proxy.eventNet * .55;

    renderer.render(scene, camera);
  }
  gsap.ticker.add(frame);
  window.__frame = (dt = 1 / 60) => frame(elapsed + dt, dt * 1000);   // headless-verification hook

  window.addEventListener('resize', () => {
    camera.aspect = stage.clientWidth / stage.clientHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(stage.clientWidth, stage.clientHeight);
  });

  return { proxy };
}

/* ============================================================
   DIRECTION — the master scroll timeline
   ============================================================ */
function direct(proxy) {
  // split display lines
  const heroWords = splitWords($('.hero-title'));
  const words = {};
  ['chHome', 'chGate', 'chSky', 'chEvent'].forEach(id => {
    words[id] = splitWords(document.querySelector(`#${id} .ch-h`));
  });

  // hero intro (plays once, after preloader)
  gsap.set(heroWords, { yPercent: 120 });
  gsap.set(['.hero-mark', '#heroSub', '#heroCue'], { autoAlpha: 0, y: 24 });
  introTl
    .to('.hero-mark', { autoAlpha: 1, y: 0, duration: .9, ease: 'power3.out' }, .1)
    .to(heroWords, { yPercent: 0, duration: 1.4, stagger: .09, ease: 'power4.out' }, .25)
    .to('#heroSub', { autoAlpha: 1, y: 0, duration: 1, ease: 'power3.out' }, .9)
    .to('#heroCue', { autoAlpha: 1, y: 0, duration: 1, ease: 'power3.out' }, 1.2);

  const chEvent = $('#chEvent');
  const railFill = $('#railFill'), railPlane = $('#railPlane');
  const stops = [...document.querySelectorAll('#railStops li')];

  function hud(p) {
    railFill.style.height = (p * 100) + '%';
    railPlane.style.top = (p * 100) + '%';
    stops.forEach(li => li.classList.toggle('on', p >= (+li.dataset.p - .05)));
    chEvent.style.pointerEvents = p > .86 ? 'auto' : 'none';
  }

  const tl = gsap.timeline({
    defaults: { ease: 'none' },
    scrollTrigger: {
      trigger: '#story', start: 'top top', end: 'bottom bottom', scrub: 1,
      onUpdate(self) { hud(self.progress); },
      onLeave() { gsap.to('#rail', { autoAlpha: 0, duration: .5 }); },
      onEnterBack() { gsap.to('#rail', { autoAlpha: 1, duration: .5 }); },
    }
  });

  // world state across the whole journey (100 units)
  tl.to(proxy, { cam: 1, duration: 100 }, 0);
  tl.to(proxy, { route: 1, duration: 88 }, 2);
  tl.to(proxy, { fog: .010, duration: 8 }, 28);
  tl.to(proxy, { fog: .0045, duration: 8 }, 56);
  tl.to(proxy, { fog: .0085, duration: 8 }, 78);
  tl.to(proxy, { gateMatch: 1, duration: 12, ease: 'power1.inOut' }, 38);
  tl.to(proxy, { eventNet: 1, duration: 12, ease: 'power1.inOut' }, 86);
  // the boarding doors slide open as the route reaches the gate (so it passes
  // THROUGH the opening, not through the glass), then close behind us
  tl.to(proxy, { door: 1, duration: 7, ease: 'power2.out' }, 31);
  tl.to(proxy, { door: 0, duration: 5, ease: 'power2.in' }, 49);

  // hero exit
  tl.fromTo('#chHero', { autoAlpha: 1, y: 0 }, { autoAlpha: 0, y: -80, duration: 6, ease: 'power1.in' }, 2);

  // chapter helper — masked words ride in with the scrub
  function chapter(id, tIn, tOut) {
    const el = document.getElementById(id);
    const k = el.querySelector('.ch-k'), pp = el.querySelector('.ch-p');
    tl.fromTo(el, { autoAlpha: 0 }, { autoAlpha: 1, duration: 3 }, tIn);
    tl.fromTo(words[id], { yPercent: 118 }, { yPercent: 0, duration: 3.4, stagger: .3, ease: 'power2.out' }, tIn);
    tl.fromTo([k, pp], { autoAlpha: 0, y: 26 }, { autoAlpha: 1, y: 0, duration: 2.6, stagger: .5 }, tIn + .8);
    if (tOut != null) tl.to(el, { autoAlpha: 0, y: -50, duration: 3, ease: 'power1.in' }, tOut);
  }

  chapter('chHome', 10, 26);
  chapter('chGate', 35, 51);
  tl.fromTo('#gateCard', { autoAlpha: 0, y: 44, rotate: 2.5 }, { autoAlpha: 1, y: 0, rotate: 0, duration: 3, ease: 'power2.out' }, 41);

  // boarding: fade to black, settle into the window seat
  tl.fromTo('#veil', { autoAlpha: 0 }, { autoAlpha: 1, duration: 3, ease: 'power1.in' }, 53);
  tl.set('#cabin', { autoAlpha: 1 }, 56);
  tl.fromTo('#cabin', { scale: .52 }, { scale: 1.06, duration: 16, ease: 'power1.out' }, 56);
  tl.to('#veil', { autoAlpha: 0, duration: 2.5 }, 57.5);

  chapter('chSky', 61, 73);

  // push through the window into the open sky, then descend
  tl.to('#cabin', { scale: 3.4, autoAlpha: 0, duration: 5, ease: 'power2.in' }, 74);

  chapter('chEvent', 84, null);
  tl.fromTo('#chEvent .cta-row', { autoAlpha: 0, y: 30 }, { autoAlpha: 1, y: 0, duration: 3 }, 88);

  // journey rail — click a stop to fly there
  const st = tl.scrollTrigger;
  stops.forEach(li => li.addEventListener('click', () => {
    window.scrollTo({ top: st.start + (st.end - st.start) * (+li.dataset.p), behavior: 'smooth' });
  }));

  // debug hooks: window.__seek(0..1) jumps the story
  window.__seek = (p) => window.scrollTo(0, st.start + (st.end - st.start) * p);
  window.__st = st; window.__tl = tl;

  hud(0);
}

/* ============================================================
   Content reveals — IntersectionObserver so they fire on ANY
   scroll (wheel, instant anchor jumps, restored positions).
   No GSAP dependency, works in the reduced-motion fallback too.
   ============================================================ */
function initReveals() {
  const els = [...document.querySelectorAll('[data-reveal]')];
  if (reduce || !('IntersectionObserver' in window)) return;   // leave content visible
  document.documentElement.classList.add('reveal-ready');       // now safe to hide-then-reveal
  const io = new IntersectionObserver((ents) => {
    ents.forEach(x => { if (x.isIntersecting) { x.target.classList.add('in'); io.unobserve(x.target); } });
  }, { threshold: .12, rootMargin: '0px 0px -8% 0px' });
  els.forEach(e => { e.style.transitionDelay = ((+e.dataset.d || 0) * 1000) + 'ms'; io.observe(e); });
}

/* ============================================================
   Boot
   ============================================================ */
if (!RM) {
  const world = initJourney();
  direct(world.proxy);
}
initReveals();
