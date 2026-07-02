# GateMatch — Session Handoff

_Last updated: 2026-06-30. Read this first, then open `index.html`._

This documents the **current, live state only**. Approaches that were tried and abandoned are deliberately omitted, except where a past failure is now an active constraint (those are flagged **CONSTRAINT** so they aren't re-attempted).

---

## 1. What this is

GateMatch is a startup landing page. Positioning (per `~/Downloads/GateMatch Revised.docx`):

- **Category:** event-driven travel connections — NOT "conference networking software."
- **Tagline:** **"Meet before you arrive."**
- **Idea:** you're going to an event; relevant people are going too; GateMatch connects you before you arrive (at the gate, layover, after landing, hotel check-in, before the first session).
- **Voice:** short, lowkey, premium, travel/gate energy. Avoid LinkedIn / generic-SaaS / privacy-dashboard / dating-app feel. Don't overdo privacy/legal copy.

It is a **marketing site only** (not the attendee app or admin dashboard).

---

## 2. Files

```
/Users/zphil0/GateMatch/
├── index.html              # the whole site (inline CSS/JS)
├── serve.sh                # local server (chmod +x already done)
├── HANDOFF.md              # this file
└── assets/
    ├── gate.jpg            # hero background photo (1448×1086, 454 KB)
    ├── landing-opt.glb     # 3D airplane model, 1.7 MB (compressed)
    └── model-viewer.min.js # self-hosted <model-viewer> (935 KB)
```
Ship the **entire `assets/` folder** with `index.html`.

---

## 3. How to run  ← important

```bash
cd /Users/zphil0/GateMatch
./serve.sh            # serves http://localhost:5173 and opens the browser
# optional: ./serve.sh 8080
```

**CONSTRAINT — must be served over http(s).** `<model-viewer>` loads as an ES module and *fetches* the GLB; opening `index.html` directly as a `file://` page makes Chrome block both, so the **3D silently fails** (everything else still renders). The recurring "3D isn't loading" report was almost certainly file:// viewing. Always test via `serve.sh` or a deploy (Vercel/Netlify/etc.).

---

## 4. Design system (current)

- **Theme:** dark and cohesive throughout (hero photo → dark content with no white seams).
- **Palette** (steel/cyan neutrals + deep-blue accent):
  - bg `#10171A`, bg-2 `#161F23`, panels `rgba(157,180,192,.055)`, lines `rgba(194,223,227,.10)`
  - text `#ECF7F7`, secondary/steel `#9DB4C0`, muted `#6F838C`
  - **accent (deep navy blue) `--accent:#001e6c`** for fills/buttons (white text), CTA, hero "GateMatch" word stays lighter (`#5B7CF4`) for legibility on the dark photo
  - **`--accent-2:#7E9BF7`** for small text / icons / kickers (legible on dark)
  - **CONSTRAINT:** the user explicitly rejected the light/powder blue — keep the accent a **deep blue**, not pale cyan.
- **Fonts:** **Manrope** (display / big text) + **Roboto Slab** (body / small text).
- **No top navigation** — the user removed the navbar and Join button. The page has no header; CTAs live in the body + footer only. Don't re-add a top nav without asking.

---

## 5. Page structure (top → bottom)

1. **Preloader** (`#preloader`) — solid-color screen; an **airplane orbits a circle clockwise** drawing a glowing arc (orbit is **ease-in**: slow at the start, accelerating back toward the origin), with "GateMatch" wordmark. Holds until `window load` + `document.fonts.ready` (no model wait anymore; **6 s hard fallback, 400 ms min**). Finishes on the rotor's `animationiteration` so the plane lands back at the origin, then fades and sets `body.loaded`.
2. **Hero** (`#hero`, sticky) — full-bleed `assets/gate.jpg`; **"Welcome to GateMatch"** letter-cascade ("Welcome to" white, "GateMatch" deep blue, **no glow**), "Meet before you arrive." + scroll cue. Ken Burns on `.scene-zoom`, scroll-dissolve on `.scene`, mouse parallax on the `<img>` (each owns a **separate** transform — don't merge them). Cascade is gated by `body.loaded` (un-pauses after preloader).
3. **Value** (`#join`) — copy left + floating **match-card mockup** right (Matt Chen · 94% · "Why this match" · Gate/Layover/Check-in chips · Request intro · "Arrives Mon 2:40 PM" chip · peeking 2nd card).
4. **Spatial moment** (`#spatial`) — a **custom CSS globe** (deep-navy sphere, scrolling meridians, specular highlight, terminator shading) with a plane orbiting it, plus the dashed orbit ring + floating chips. **The 3D `<model-viewer>` was removed** (see §6) — this is now pure CSS, no GLB, no external script.
5. **Connection moments** (`#moments`) — horizontal **journey timeline**, dashed route line, 5 moments each with a one-liner (gate → layover → after landing → hotel check-in → first session).
6. **Who's on their way** (`#who`) — 4 **persona cards** (Maya/Devin/Sana/Marcus: role + "looking to meet" + destination chip).
7. **Product flow** (`#flow`) — "From join to handshake," 5 connected steps.
8. **Trust** — 3 short cards: Rough windows first · Flight details optional · Mutual interest before sharing.
9. **CTA** — deep-blue gradient card, animated dashed **route line**, floating mini attendee cards.
10. **Footer** — "GateMatch" wordmark + tagline + links.

All animations are `prefers-reduced-motion` aware.

---

## 6. The 3D model — REMOVED, replaced by a CSS globe

The 3D `<model-viewer>` was repeatedly reported as "not loading" (almost always the file:// fetch-blocking issue), so per the user's standing instruction it was **removed and replaced with a custom CSS globe** in `#spatial`. There is now **no GLB, no `model-viewer.min.js` script tag, and no model wait in the preloader** — the section can never be blank, and the page loads faster.

- The globe is `.globe` (radial-gradient sphere + box-shadow rim + `::after` specular highlight) containing an inline **`.globe-svg`** (viewBox 0 0 400 400, sphere r=180 clipped by `#sphereClip`):
  - **Continents**: hand-built SVG `<path>` silhouettes (N/S America, Greenland, Africa, Europe, Asia, Australia, Madagascar, Japan, Indonesia, New Guinea, British Isles) on an equirectangular tile **720 units wide**. Rendered **twice** (`translate(0,20)` + `translate(720,20)`) and scrolled west→east by a SMIL `<animateTransform translate 0→-720, dur 60s>` for a seamless rotating loop. Fill = `url(#landFill)` gradient.
  - **Curved graticule** (`.grid`): meridians are concentric **ellipses** (rx 60/120/165, ry 180) + a central vertical line; parallels are shallow **quadratic arcs** — deliberately curved so the sphere reads as 3D (the user explicitly rejected a flat straight-line grid).
  - **Shading**: `#globeShade` radial gradient circle on top = highlight (top-left) → transparent → dark terminator at the limb.
  - A `.globe-orbit` wrapper rotates a small plane icon around it (CSS).
  - Reduced-motion: CSS disables `.globe-orbit`; the SMIL scroll is paused in JS via `globe-svg.pauseAnimations()`.
- `assets/landing-opt.glb` and `assets/model-viewer.min.js` are now **unused** by the page (still on disk; safe to delete from `assets/` if slimming the bundle). The compression recipe that produced the GLB is preserved in git history if the 3D is ever revived.
- If reviving the 3D: it **must be served over http(s)** (file:// silently blocks the ES-module + GLB fetch — that was the recurring "3D isn't loading" report), self-host the script (no `unpkg` CDN), and compress with `--compress quantize` not `--compress meshopt` (3.5 throws `setMeshoptDecoder must be called`).

---

## 7. OPEN / PENDING

1. **3D fallback — RESOLVED by removal.** The 3D was replaced with the CSS globe (§6), which renders everywhere (even file://) with no external assets, so there is nothing left to make robust here.
2. **Mobile polish — explicitly deferred.** The user said "we won't move on to mobile yet." Desktop/laptop is the priority. Layouts have responsive breakpoints but mobile hasn't been reviewed/tuned.
3. **Placeholders to replace before launch:** contact CTA → `mailto:hello@gatematch.com`; persona/match names and the "94%", dashboard-style numbers are illustrative sample data; "Founder Summit NYC" is a sample event.

---

## 8. Gotchas for the next session

- **Preview screenshot tool:** the Claude_Preview screenshot returns blank/desynced frames whenever the page is scrolled via JS (even fixed elements vanish — it's a capture artifact, not a bug). Reliable patterns: capture at scroll-top, or temporarily `display:none` the sections above the one you want and force `[data-reveal].in`, then screenshot. Verify lower sections via DOM/computed-style audits.
- The hero is `position:sticky`; content slides over it. Don't "fix" the apparent overlap — it's intentional (background dissolves into the page).
- Keep each hero transform on its own element (scene = scroll dissolve, scene-zoom = Ken Burns, img = parallax). Combining them re-introduces edge-exposure / animation clobbering bugs.

---

## 9. Superseded — do NOT rebuild

These earlier directions were fully replaced; ignore them (listed only so they aren't re-created):
- A light "Trust & Authority / Calendly" version (Fraunces, white background).
- A dark-cinematic **floating-crystal** hero with a vertical one-word side-nav and a sound toggle.
- An **SVG-drawn** boarding-gate scene (replaced by the real `gate.jpg` photo).
- Light/powder-blue accent and a light/white content theme.
- "Conference networking" positioning (now event-driven travel connections).
