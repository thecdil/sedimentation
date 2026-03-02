---
title: Panorama Feature Test
layout: page
permalink: /panorama-test.html
---

## Multiple Panorama Viewers Test Page

This page demonstrates the panorama feature include with multiple instances and different options.

### Example 1: Auto-load (default)

This panorama loads immediately when the page loads:

{% include feature/panorama.html objectid="sediment278" caption="Sheep petroglyphs at Petroglyph Beach" %}

---

### Example 2: Manual load with different ratio

This panorama requires clicking the load button (autoload=false) and uses 16x9 aspect ratio:

{% include feature/panorama.html objectid="sediment279" autoload=false ratio="16x9" %}

---

### Example 3: Manual load with custom width

This panorama is 75% width and uses manual loading:

{% include feature/panorama.html objectid="sediment280" autoload=false width="75" caption="Kayaking - Click to load" %}

---

### Example 4: Multiple side-by-side (50% width each)

<div class="row">
<div class="col-md-6">
{% include feature/panorama.html objectid="sediment281" width="100" caption="Location 1" ratio="1x1" %}
</div>
<div class="col-md-6">
{% include feature/panorama.html objectid="sediment282" width="100" caption="Location 2" ratio="1x1" %}
</div>
</div>

---

### Example 5: With custom Pannellum parameters

This panorama sets initial viewing angle with heading and pitch:

{% include feature/panorama.html objectid="sediment286" heading="90" pitch="10" hfov="120" %}

---

### Example 6: No caption

{% include feature/panorama.html objectid="sediment287" caption=false %}

---

## Verification Checklist

Open browser DevTools to verify:
- Each panorama has a unique ID (panorama-sediment278, panorama-sediment279, etc.)
- Pannellum CSS/JS loads only once (check Network tab)
- Auto-load panoramas initialize immediately
- Manual-load panoramas show Pannellum's load button overlay
- All panoramas are interactive and functional
- No JavaScript console errors
