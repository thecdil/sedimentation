# Sedimentation — Technical Feature Guide

A reference for understanding how the major custom visualizations and interactive systems work technically. Start here when returning to the codebase after time away.

---

## Table of Contents

1. [Splash Page — Particle River Animation](#1-splash-page--particle-river-animation)
2. [Main Page — Scroll River Visualization](#2-main-page--scroll-river-visualization)
3. [Navigation Overlay — Visual River Nav](#3-navigation-overlay--visual-river-nav)
4. [Tributary Essays — Scrollytelling Layout](#4-tributary-essays--scrollytelling-layout)
5. [Eddies — Choose Your Own Adventure](#5-eddies--choose-your-own-adventure)
6. [Header System](#6-header-system)
7. [Foot & Conditional Script Loading](#7-foot--conditional-script-loading)

---

## 1. Splash Page — Particle River Animation

**File:** `index.html` (803 lines, standalone — does NOT use the Jekyll default layout)

### What It Does

A full-screen animated canvas where the title "SEDIMENTATION" and credits decompose into sediment particles that flow down invisible river paths and settle in the bottom-left corner (the "dam"). After 7 seconds the "Breach" button appears; clicking it navigates to `main.html`.

### Canvas Setup

The canvas fills the full viewport. `resizeCanvas()` fires on load and on `window.resize`. Font sizes are calculated from `canvas.width` using the Liquid frontmatter variable `{{ page.font-size-calc }}` (value: `"7, 140"`), which evaluates to `Math.min(canvas.width / 7, 140)` — so the title scales with the viewport up to a max of 140px.

### River Network

`riverNetwork` is an array of path objects. Each path has:
- `points[]` — control points expressed as `canvas.width * 0.X` / `canvas.height * 0.Y` fractions
- `width` — the river's attraction radius in pixels
- `isMainRiver` — flag for the primary Colorado River path

The first entry (index 0) is the main river running top-right → bottom-left. Remaining entries are smaller tributaries. **These paths are never drawn** — they're invisible attractor lanes only.

### Distance Math (Parametric Projection)

`getDistanceToRiver(x, y, river)` finds the shortest distance from a point to any segment in a path using the standard parametric projection formula:

```
dot = A·C + B·D  (project vector onto segment direction)
param = dot / lenSq  (clamped to [0,1])
closest = p1 + param * (p2 - p1)
distance = euclidean(point, closest)
```

Used in two ways:
- `isInRiver()` — checks if a particle is within `river.width/2` of any path
- Attraction force — pulls stray particles back toward the nearest river segment

### Text Particle Extraction

`createTextParticles()` renders the title and subtitles invisibly to the canvas using the loaded Inconsolata font, then reads `getImageData()`. Every pixel with alpha > 128 becomes a particle at that pixel position. After extraction the canvas is cleared — letters are never shown directly. Each particle stores `originalX/Y` for click-to-restart resets.

### Continuous Flow Particles

`addContinuousParticles()` fires every 100ms (starting at 2 seconds). It spawns:
- **155 particles** biased toward the top 40% of the main river
- **50 more** clustered right at the source point (top-right corner)

Disabled if `prefers-reduced-motion` is set.

### Settling Grid

`sedimentGrid` is a sparse object (`{gridKey: true}`) tracking occupied 1×1px cells. When a particle enters the dam zone (x < 10%, y > 5%), `findSettlingPosition()` scans downward to find the lowest open cell with support below it, or the canvas bottom edge. This creates a natural sediment pile. Particles that can't find a slot slow down and keep flowing.

### Animation Loop

`animate()` runs forever via `requestAnimationFrame` (both branches of the stop condition re-call it). Each frame:
1. Clears canvas, redraws faint text stroke outlines
2. Injects continuous particles
3. Updates each particle: river flow or attraction force → 0.95 drag → position update → settle check
4. Draws all particles
5. Triggers typewriter subtitle (after 1s) and Breach button (after 7s)

---

## 2. Main Page — Scroll River Visualization

**File:** `main.html` (~680 lines after cleanup, uses `layout: default`)

### What It Does

A 12,000px tall scrollable page with a particle river drawn on a canvas beneath the intro content box and river poem. The river "reveals" as you scroll or as time passes, with sediment particles depositing along its path.

### River Path (SVG → Canvas)

The river path is stored in the page frontmatter as an SVG path string (`river_path`). It uses `M` (moveto), `Q` (quadratic bezier), and `T` (smooth curve through reflected control point) commands in a coordinate space of roughly x: 0–200, y: -10–900.

`parsePathToPoints()` converts this to pixel coordinates:
- **x mapping** — `mapRiverX()` scales x linearly from 0–200 to 0–`canvas.width`, then applies a smooth cubic ease (smoothstep) in the bottom 18% of the path that arcs the river off-screen to the right (the "exit arc past the dam")
- **y mapping** — linear scale from SVG y-range to `canvas.height` (fixed at 7300px)
- **Curve subdivision** — Q curves subdivided into 25 steps, T curves into 15 steps, producing a dense point array for smooth particle attraction

`parsePathToPoints()` is called on load and again on every `window.resize`.

### Dual Particle System

**riverBedParticles** (static layer):
- Created once by `createRiverBed()`, 400 particles per path point scattered within ±4.8%/2.4% of canvas dimensions
- `settled = true`, never decay, apply a gentle sine-wave sway each frame for a living-water feel
- Revealed progressively as `revealProgress` increases (index 0 → N over time)

**flowing particles** (dynamic layer):
- Spawned at newly revealed path points and occasionally along already-drawn sections
- Drift with slight random velocity, get attracted toward the nearest river point if within 7% distance
- Settle permanently when within 3.6% of the river
- Decay (and are removed) if they wander too far

### Coordinate Space

All positions stored as fractions of `canvas.width` / `canvas.height`. Velocities are correspondingly tiny (e.g., `vy ≈ 0.0005–0.0013` per frame). The `draw()` method converts back to pixels. This keeps positions valid after resize.

### Scroll-to-Reveal Mechanic

`revealProgress = Math.max(scrollProgress, timeProgress)`

- `scrollProgress` = `window.pageYOffset / (documentHeight - windowHeight)`
- `timeProgress` = `elapsed / 25000` (25-second auto-advance)

Taking the max means the river keeps revealing even if the user doesn't scroll, but scrolling can get ahead of the timer.

### Page Layout

`.river-container` is 12,000px tall with a 4-stop desert gradient (wheat → dark chocolate). The canvas is `position: absolute` over the full container. The intro content box is `position: absolute; top: 140px; right: 6.5%` with a 92% opacity white background. On mobile (≤768px) it becomes `position: relative` and takes full width.

---

## 3. Navigation Overlay — Visual River Nav

**File:** `_includes/side-nav-banner.html` (~850 lines)

### What It Does

A folding-map toggle button that opens a full-page overlay with two panels: textual navigation links on the left and five SVG river columns on the right, each representing a tributary essay subdivided into clickable section segments.

### Overlay Open/Close

- `openFullPageNav()` — adds `.active` to `#fullPageNav`, locks `body.overflow`
- `closeFullPageNav()` — removes `.active`, restores scroll
- Escape key also closes

The toggle button gets class `sticky-nav-button` on tributary pages (fixed positioning) and a plain wrapper on other pages.

### Visual River Columns

Five `.river-column` divs (Land, Water, Biota, Atmosphere, Humans). Each contains:
- `<h3 class="river-title">` — the tributary name (hover/click target)
- `<svg class="vertical-river" viewBox="0 0 80 700">` — the column visualization
  - `<g class="river-segments">` — container for section rects

**Hardcoded fallback** segments are in the HTML. On load, `renderNavigation()` replaces them with dynamically generated segments from `tributaries.json`:
- viewBox height = 700; `segmentHeight = floor((700 - 10) / sectionCount) - 5`
- Each segment = two overlapping `<rect>` elements: one with the coarse `#landParticles` SVG pattern and one with the fine `#landParticlesSmall` pattern (layered particle texture)

### Hover Label System

`mouseenter` on any `.river-segment` creates a temporary `<text class="segment-label">` element centered on the segment's bounding rect and appended to the SVG. `mouseleave` removes it. Labels are suppressed if the column is in `.locked` state.

### Lock / Mute State Machine

Clicking a `.river-title` toggles `.locked` on its column:
- **Locked**: `showAllLabels()` renders persistent text labels for every segment
- **Other columns**: gain `.muted` on hover of the locked title (visual dimming)
- Only one column locked at a time; click again to unlock

Hovering a title (without clicking) temporarily shows all labels for that column.

### Data Loading & Caching

`loadTributariesData()` fetches `/assets/data/tributaries.json` (generated at Jekyll build time by the `cb_page_gen.rb` plugin). Result is stored in `sessionStorage` under `sediment_tributaries_data` for 1 hour. On cache hit the nav renders immediately with no network request.

### Dropdown Behavior

- **Collection dropdown**: desktop = normal link to `/browse.html`; mobile (≤768px) = click toggles `.expanded` submenu
- **Tributary dropdown**: Shift+click expands/collapses the section list. Normal click navigates. The current tributary's sections auto-expand. Section links on the current page close the nav and smooth-scroll to the anchor.

### Active State

Text link `.active` classes are injected at Jekyll build time via Liquid (`{% if page.url == ... %}`). The JS additionally adds `.current-tributary` to the matching `.river-column` by comparing `window.location.pathname` to `trib.slug` at runtime.

---

## 4. Tributary Essays — Scrollytelling Layout

**Files:** `_layouts/tributary.html`, `_tributaries/*.md`, `_includes/js/essay-scroll-js.html`, `_sass/_essay.scss`

### What It Does

Long-form narrative essays with scroll-driven section transitions, floating image galleries, scholarly footnotes, and cross-tributary navigation buttons.

### Layout Structure (`_layouts/tributary.html`)

```
body
  └── default layout
        ├── side-nav-banner.html (nav overlay)
        ├── tributary-river.html (SVG river background, positioned left or right based on page.tributary-side)
        └── .tributary-container
              ├── .tributary-title-image-container (sedimentation-title.png)
              ├── #scrolly
              │     └── article
              │           └── .step (each section is a .step div)
              └── .more-tributaries (grid of other tributary cards)
```

The `page.side` frontmatter (`left`/`right`) controls which side the river SVG appears on.

### Scrollama Integration (`essay-scroll-js.html`)

Scrollama watches `.step` elements. On `onStepEnter`, each step can define a `data-bg-color` and `data-text-color` attribute (set from the tributary markdown's section frontmatter). These transition the background and text colors of the page as the user reads.

### Section Navigation (`assets/js/section-nav.js`)

Auto-generates a sticky mini-nav from all `h2` elements in the essay. Uses `IntersectionObserver` to highlight the current section heading in the nav as the user scrolls.

### Image Gallery (Spotlight)

Pages with `gallery: true` in frontmatter load `spotlight.bundle.js` (loaded via `foot.html`). Images wrapped in `<a class="spotlight">` anchors open in Spotlight's lightbox viewer.

`spotlight-media-handler.html` wraps Spotlight to add:
- Video (YouTube/Vimeo/MP4) support
- Audio playback
- PDF embed
- Link to the item's collection page
- Metadata caching for item details

### Trib-Button Navigation (`assets/js/tributary-buttons.js`)

`.trib-button-link` elements (rendered by `_includes/feature/trib-button.html`) trigger the image disintegration animation when clicked. The `.trib-button-image` pixel data is extracted and decomposed into particles. See [Feature 6 — Tributary Buttons](#) for physics details.

### "More Tributaries" Footer

`_layouts/tributary.html` loops over `site.tributaries`, excludes the current page by `page.slug`, and renders a grid of trib-button cards linking to the other essays.

---

## 5. Eddies — Choose Your Own Adventure

**Files:** `eddies/index.html`, `_includes/js/eddies-cyoa-js.html`

### What It Does

An interactive page that presents sections from the tributary essays one at a time in a randomized or curated sequence. Each section is revealed with a sediment particle coalesce animation.

### Data Source

`/assets/data/tributaries.json` (generated at Jekyll build) contains all tributary sections with their rendered HTML content. `init()` fetches this and flattens it into `allSections[]`, filtering out Works Cited and very short sections.

### Session Persistence

| Store | Key | What's Saved |
|---|---|---|
| `localStorage` | `eddies-viewed-sections` | Set of `tributary:sectionId` strings, persists across browser sessions, resets when all sections seen |
| `sessionStorage` | `eddies-loaded-sections` | Ordered array of sections loaded in the current tab session |
| `sessionStorage` | `eddies-session-active` | Flag enabling session restore on page refresh |

On page reload, `restoreSession()` re-renders all previously loaded sections without animation.

### Navigation Choices

Each displayed section has two buttons at the bottom:

1. **Randomize** — calls `getRandomSection()`, which picks a random section not in `viewedSections[]`
2. **Curated** — `extractTribButtonTarget()` parses the original trib-button link from the section's HTML. If a specific `anchorId` is found, `loadSpecificSection()` loads that exact section. If only a tributary is found (no anchor), loads a random section from that tributary. If nothing found, opens a section-picker modal.

### Content Processing

Before display, `processContentForCYOA()`:
- Strips `.trib-choice-container` and `.new-section` navigation elements (CYOA supplies its own)
- Wraps all `<img>` elements in `<a class="spotlight gallery-img">` anchors for Spotlight gallery compatibility

### Particle Coalesce Animation

200 `SedimentParticle` instances start at random viewport positions and fly toward the bounding box of the newly appended section element over 1200ms. A fixed full-viewport canvas (`#cyoa-particle-canvas`) is created for the animation and removed when complete. The section content fades in starting at 40% animation progress.

Disabled entirely when `prefers-reduced-motion` is set.

### Controls

After the first section loads, `createControlButtons()` appends a sticky control bar:
- **Clear & Reset** — clears sessionStorage, removes sections, shows intro again
- **Save/Print** — calls `window.print()`

Controls collapse after the user scrolls past 1000px (expand when scrolling back up).

---

## 6. Header System

Three distinct header variants, chosen based on which page is being rendered:

### Variant A: Splash Page (`index.html`)

`index.html` is fully standalone — it does NOT use `layout: default` and does not include any header files. The entire page is a hand-authored HTML document with its own `<head>` and `<body>`. The canvas IS the page.

### Variant B: Main Page (`main.html`)

Uses `layout: default`. The `default.html` layout conditionally includes `static-sediment-header.html` **unless** `page.river_path` is set (which is true on `main.html`). So `main.html` gets NO static header — instead `side-nav-banner.html` is included directly inside the page's HTML, positioned as a fixed nav in the top-left corner.

### Variant C: All Other Pages

Use `layout: default` → includes `static-sediment-header.html`. This include renders:
- The `sedimentation-title.png` logo (links to `/main.html`)
- The `side-nav-banner.html` nav toggle

**Detection logic in `_layouts/default.html`:**
```liquid
{% unless page.url == "/" or page.layout == "tributary" or page.river_path %}
  {% include static-sediment-header.html %}
{% endunless %}
```

### Tributary Pages

Tributary pages also use `layout: default` but the `unless` condition excludes them from the static header. The `tributary.html` layout includes `side-nav-banner.html` directly with the `sticky-nav-button` wrapper class, which positions the toggle button as a fixed button in the corner of the page.

---

## 7. Foot & Conditional Script Loading

**File:** `_includes/foot.html`

This include fires at the end of every `<body>` and conditionally loads scripts based on page metadata:

| Condition | Script Loaded |
|---|---|
| Always | Bootstrap bundle, Lazysizes, `tributary-buttons.js` |
| `layout.gallery == true` OR `page.gallery == true` | Spotlight.bundle.js |
| `page.scrollama == true` | `essay-scroll-js.html` (Scrollama integration) |
| `page.sticky-nav == true` | `scroll-nav-btn.html` (floating nav FAB) |
| `page.custom-foot` or `layout.custom-foot` set | The listed include files (semicolon-separated) |

### Custom Foot Pattern

Layouts can set `custom_foot` in their frontmatter to load page-specific scripts. Examples:
- `browse.html` layout → `js/browse-js.html`
- `map.html` layout → `js/map-js.html`
- `eddies/index.html` page → `js/eddies-cyoa-js.html` and `js/spotlight-media-handler.html`

Scripts in `_includes/js/` that contain Liquid template variables (e.g., `browse-js.html`, `map-js.html`) must stay as includes rather than plain `.js` files because Jekyll processes them for variable substitution at build time.

---

## Data Files

| File | Generator | Used By |
|---|---|---|
| `assets/data/tributaries.json` | `_plugins/cb_page_gen.rb` | Eddies CYOA, Side Nav dropdown |
| `assets/data/metadata.json` | `_plugins/cb_page_gen.rb` | Spotlight media handler, navigation-cards.html |
| `assets/data/subjects.json` | `_plugins/cb_page_gen.rb` | Browse facets |
| `assets/data/geodata.json` | `_plugins/cb_page_gen.rb` | Leaflet map |
| `assets/js/lunr-store.js` | Jekyll template (Liquid) | Lunr full-text search |

The `tributaries.json` structure mirrors the `_tributaries/` collection: each tributary has a `sections[]` array where each section has `id`, `heading`, and `html_content` (the rendered HTML of that section extracted by the plugin).
