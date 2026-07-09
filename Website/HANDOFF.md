# GateMatch — Session Handoff

_Last updated: 2026-07-07. Read this first, then open `index.html`, `css/main.css`, `js/main.js`._

This documents the **current, live state only**. Abandoned approaches are omitted except where a past failure is now an active constraint (flagged **CONSTRAINT**).

---

## 1. What this is

GateMatch is a startup landing page. Positioning (per `~/Downloads/GateMatch Revised.docx`):

- **Category:** event-driven travel connections — NOT "conference networking software."
- **Tagline:** **"Meet before you arrive."**
- **Idea:** you're going to an event; relevant people are going too; GateMatch connects you before you arrive (gate, layover, after landing, hotel check-in, before the first session).
- **Voice:** short, lowkey, premium, travel/gate energy. Avoid LinkedIn / generic-SaaS / privacy-dashboard / dating-app feel. Don't overdo privacy/legal copy.

It is a **marketing site only** (not the attendee app or admin dashboard).

---

## 2. The big idea of the current design — "The Journey"

The page is a **single scroll-driven cinematic**: one continuous Three.js world that the camera flies through as you scroll, narrating GateMatch's story in four beats:

**Home → Gate → Sky (airplane seat) → Event (landing).**

- A **sticky WebGL stage** (`#story` is 780vh tall; `#stage` is `position:sticky`) holds a full-screen `<canvas>`. GSAP **ScrollTrigger** (`scrub`) drives a master timeline; the timeline animates a plain `proxy` object, and a `gsap.ticker` render loop reads the proxy each frame and renders the Three.js scene. Nothing is drawn to the DOM for the 3D — it's all one WebGL scene.
- The **camera** rides two CatmullRom curves (`camPath` for position, `tgtPath` for lookAt), scrubbed by scroll. Mouse adds subtle parallax + bank.
- A single **blue "route" tube** (the brand-blue thread) draws itself progressively from your front door all the way to the venue as you scroll — it's the visual spine of the whole story.
- **Chapter overlays** (`.ch` DOM elements) fade/rise in over the canvas with masked word reveals, one per beat.
- **The page is journey-only.** It ends on the Event finale ("Land connected.") which carries the single "Join a GateMatch event" CTA — there is nothing after the story (`document.scrollHeight === #story height`). The earlier static content sections that used to scroll over after the journey (value + match card, moments timeline, the "manifest", product flow, trust, final CTA, footer) were **removed per the user's request** on 2026-07-07. Their CSS (in `main.css`) and the IntersectionObserver reveal system + `[data-reveal]`/`reveal-ready` (in `main.js`) are now **dormant but left in place** — re-add `<main class="content">…</main>` before the scripts to bring them back, or strip the dead CSS/JS to slim things.

The four world sets, built once in `initJourney()`:
1. **Home** — a sleeping neighbourhood (instanced dark houses + warm window lights + a porch glow + street lights leading out).
2. **Gate** — a glowing terminal glass wall + mullions + a **canvas-texture "GATE B22 →" sign** (redrawn once fonts load) + instanced waiting travellers + **match arcs** (blue bezier lines that draw between pairs as `proxy.gateMatch` advances) + a **boarding door** set into the glass (frame posts/lintel + two sliding panels + a light-spill glow) so the route enters through an *opening*, not through solid glass. The doors slide apart via `proxy.door` (open ~timeline 31→38 as the route ball reaches the gate, close ~49→54 behind you).
3. **Sky** — drifting cloud sprites + a moon. **The plane wing was removed** (it obstructed the view) — the window now shows a clear view. The **airplane window** itself is a CSS element (`#cabin`, an ellipse mask with a huge box-shadow vignette) that scales up to frame the view, then you push through it.
4. **Event** — a night city (instanced blocks + window-light points), the **venue** (landmark + additive light beam + glow) and an **attendee constellation** (nodes + edges) that assembles above it as `proxy.eventNet` advances. Labelled obscurely ("The Foundry") on purpose — see §7.

---

## 3. Files

```
Website/
├── index.html              # markup only (no inline CSS/JS anymore)
├── css/main.css            # all styles
├── js/main.js              # ES module: preloader, Three.js journey, GSAP direction, reveals
├── serve.sh                # local server (chmod +x already done)
├── HANDOFF.md              # this file
└── assets/
    ├── gate.jpg            # now UNUSED by the live page (was the final CTA background; only the dormant .cta CSS still references it)
    ├── vendor/
    │   ├── gsap.min.js            # GSAP 3.12.5 (self-hosted)
    │   ├── ScrollTrigger.min.js   # GSAP ScrollTrigger 3.12.5
    │   └── three.module.min.js    # Three.js r160 (ES module, loaded via importmap)
    ├── landing-opt.glb     # UNUSED by the current page (legacy; safe to delete to slim bundle)
    └── model-viewer.min.js # UNUSED by the current page (legacy; safe to delete)
```
Ship `index.html` + `css/` + `js/` + `assets/vendor/`. `gate.jpg` and the two legacy files are no longer loaded (see the reveal note in §2) and can be dropped — restore `gate.jpg` if the content sections / final CTA are re-added.

**Cache-busting:** `main.css` and `main.js` are referenced with `?v=N`. **Bump `N` in `index.html` whenever you edit those files** or a browser (and the Claude_Preview tab) will serve a stale cached copy — this bit me during the build.

**Loading performance (CONSTRAINT — don't undo):** the Google Fonts CSS is loaded **non-render-blocking** (`<link rel="preload" as="style" onload="this.rel='stylesheet'">` + `<noscript>` fallback), and `three.module.min.js` has a `<link rel="modulepreload">` (with `preload as="script"` for gsap/ScrollTrigger). **Why:** the fonts stylesheet was a render-blocking request that measured ~740 ms and, because it blocks module execution, delayed the 655 KB three.js download from starting until ~790 ms → ~1 s blank load. With these two changes three.js starts downloading at ~40 ms in parallel and nothing waits on the fonts. Do NOT switch the font `<link>` back to a plain `rel="stylesheet"` in the head. The preloader also caps its font wait (1 s) so slow fonts can't stall the lap. Note: three.js is 655 KB **uncompressed** — fine on localhost (14 ms) and on any host that gzip/brotli-compresses static assets (→ ~170 KB); the bundled python `serve.sh` does NOT compress, so a slow *deployed* load usually means the host isn't compressing.

---

## 4. How to run  ← important

```bash
cd Website
./serve.sh            # serves http://localhost:5173 and opens the browser
# optional: ./serve.sh 8080
```

**CONSTRAINT — must be served over http(s).** `js/main.js` is an ES module and loads Three.js via an **import map**; `file://` blocks ES-module fetches, so the whole journey silently falls back to the static page. Always test via `serve.sh` or a deploy. (There's also a `.claude/launch.json` `gatematch` config on port 4173 used by the preview tooling.)

---

## 5. Design system (unchanged intent, darker world)

- **Theme:** night navy-black throughout, cinematic. `--bg:#070c13`.
- **Accent (deep blue):** `--accent:#001e6c` for fills/buttons (white text). `--accent-2:#7E9BF7` for small text/icons on dark. `--brand-blue:#5B7CF4` for the wordmark. `--route:#2E55E0` for the route line.
  - **CONSTRAINT:** the brand blue must stay **strong/direct deep blue** — never neon, never pale/powder cyan, never washed out by glows. The user explicitly rejected pale blue.
- **Fonts:** **Manrope** (display) + **Roboto Slab** (body/small).
- **No top navigation.** No header/navbar. CTAs live in the body + footer + the final CTA. Don't re-add a top nav without asking.

---

## 6. Key mechanics & where to touch them (`js/main.js`)

- **`RM` flag** = reduced-motion OR no-WebGL OR no-GSAP. When true, `html.rm` is set and the journey never initialises — the page renders as a **static stacked fallback** (chapters become normal sections, canvas/rail/grain hidden). Verified working.
- **Preloader** (`#preloader`) — the plane flies **exactly one lap**, and the lap is **driven by real load progress** (JS, not a CSS loop). `cur` (0→1) chases a `target` that rises with load milestones (`readyState` interactive→0.35, `load`→0.9) plus a gentle trickle, then snaps to 1 once load+fonts are done and `MIN_MS` (700 ms) has passed; `rotor` rotates `cur*360°` and the arc draws `cur`, so the plane's speed maps directly to how fast the page loads and it lands home after one turn. 6 s hard failsafe. **CONSTRAINT/why:** the old version used a CSS `infinite` spin that finished on an `animationiteration` boundary → it visibly looped *multiple* times while waiting; don't reintroduce a looping CSS animation here.
- **HUD** — a fixed **journey rail** (`#rail`, left: Home/Gate/Sky/Event progress with a plane that rides the fill; stops are clickable → smooth-scroll to that beat), hidden < 900px, fades out (`onLeave`) past the story and back (`onEnterBack`). The **boarding-pass widget was removed** per the user (was `#pass`, top-right); its `.pass` CSS is now dormant/unused.
- **Timeline authoring** — `direct(proxy)` builds the master ScrollTrigger timeline on a 0–100 "duration" scale. Chapters use the `chapter(id, tIn, tOut)` helper (masked-word rise + kicker/paragraph fade). To retime a beat, edit the numbers there. `splitWords()` wraps display lines in `.wm/.wd` mask spans.
- **Reveals** — content sections use `[data-reveal]` + **IntersectionObserver** (`initReveals`), NOT ScrollTrigger. **CONSTRAINT/why:** `gsap.from`+ScrollTrigger reveals failed to fire on instant anchor jumps (footer/nav `#…` links), leaving sections stuck invisible. IO fires on any scroll. Also, the hidden state is gated behind `html.reveal-ready` (added by JS) so a script/observer failure can never leave the page blank — content is visible by default.
- **Debug hooks** (harmless, left in for the next session): `window.__seek(0..1)` jumps the story by scroll; `window.__st/__tl/__intro` are the ScrollTrigger/timeline/intro; `window.__frame()` renders one frame on demand (needed to verify in a backgrounded tab — see §8).

---

## 7. OPEN / PENDING

1. **Mobile — functional, not polished.** No horizontal overflow; rail/pass/gate-card hide < 900px; the WebGL journey + chapter text work on mobile (verified at 375px). But it hasn't been *designed* for mobile — type scale and beat pacing could be tuned. Desktop is the priority.
2. **Placeholders to replace before launch:** contact CTA → `mailto:hello@gatematch.com`; the match name "Matt Chen"/"94%" is sample data. The venue is deliberately **obscure** ("The Foundry" / "the same event") — the user did not want a specific named conference. **PENDING:** the user asked to generate an obscure venue image via Higgsfield to represent the venue in the scene, but the Higgsfield account is on the **free plan with 0 credits**, so image generation is blocked — needs a top-up / free trial before that can be done, then texture it onto the venue in `eventSet()`.
3. **Legacy assets** `landing-opt.glb` + `model-viewer.min.js` + `gate.jpg` are unused — delete them if slimming the deploy.

---

## 8. Gotchas for the next session

- **Bump the `?v=` query on `main.css`/`main.js` after editing** or you'll debug a stale cached file (see §3).
- **Claude_Preview runs the tab _hidden_** (`document.visibilityState === 'hidden'`), which throttles `requestAnimationFrame` **and** `IntersectionObserver` — so the GSAP ticker and the reveals appear "frozen" in automated checks even though they're fine in a real browser. To verify the 3D deterministically: set `window.__intro.progress(1)`, `window.__st.disable(false)`, stay at `scrollY 0`, drive `window.__tl.progress(p)` and call `window.__frame()` twice, then screenshot. Screenshots also desync/blank whenever the page is scrolled via JS — capture at scroll-top, or hide `#stage` + the fixed HUD and pull content sections to the top.
- **Keep the route line the brand deep-blue** and strong — it's the spine of the story.
- The hero/chapters sit on `position:sticky` `#stage`; content scrolls over it. That overlap is intentional.

---

## 9. Superseded — do NOT rebuild

Earlier directions, fully replaced (listed only so they aren't re-created):
- The previous **static multi-section page** with a `gate.jpg` photo hero, a **CSS globe** in a "spatial" section, and inline CSS/JS in one `index.html`. (The globe, the sticky-photo hero, and the persona-card grid are all gone — the personas became the airline-manifest list; the photo is now only the final CTA background.)
- The 3D `<model-viewer>` GLB approach (file:// fetch issues); a light "Trust & Authority / Calendly" version; a floating-crystal hero; an SVG boarding-gate scene; pale/powder-blue accent; "conference networking" positioning.
