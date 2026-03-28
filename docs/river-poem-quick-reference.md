# River Poem Reference

## Quick Start

**Edit this file:** `_data/river-poem.yml`

**Minimum required properties:**
```yaml
sections:
  - id: "unique-name"
    scroll_position: 500
    side: "left"
    content: "Your poem text here"
```

**Multi-line text:** Use `|` after `content:`
```yaml
content: |
  First line of poem
  Second line continues
```

---

## Complete Property Reference

```yaml
- id: "section-name"           # Required: unique identifier
  scroll_position: 500          # Required: vertical position in pixels
  side: "left"                  # Required: "left" or "right"
  content: "Text"               # Required: your poem text
  
  # Spacing (all optional, in pixels)
  padding_top: 20               # Default: 20
  padding_bottom: 20            # Default: 20
  padding_left: 20              # Default: 20
  padding_right: 20             # Default: 20
  
  # Styling (all optional)
  max_width: 400                # Default: 400 (pixels)
  font_size: 18                 # Default: 18 (pixels)
  text_align: "left"            # Default: "left" | Options: left, right, center
  
  # Icon & Link to Tributary (all optional)
  icon: "water"                 # Icon filename without .png (must be in /objects/)
  trib: "water"                 # Tributary name (REQUIRED if using icon)
  anchor: "seeps"               # Optional: section ID on tributary page (e.g., #seeps)
```

**Important:** If you use `icon`, you **must** also include `trib`. The `anchor` is optional and creates a link to a specific section on the tributary page.

---

## Available Tributary Icons

Place icons in `/objects/` as PNG files:
- `water` → `/tributaries/water/`
- `land` → `/tributaries/land/`
- `atmosphere` → `/tributaries/atmosphere/`
- `animal` → `/tributaries/animal/`
- `humans` → `/tributaries/humans/`
- `infrastructure` → `/tributaries/infrastructure/`
- `colonization` → `/tributaries/colonization/`

**With anchor example:** Links to `/tributaries/water/#seeps`
```yaml
icon: "water"
trib: "water"
anchor: "seeps"
```

---

## Examples

### 1. Simple text
```yaml
- id: "line1"
  scroll_position: 300
  side: "left"
  content: "you are silt"
```

### 2. Multi-line with custom spacing
```yaml
- id: "line2"
  scroll_position: 700
  side: "right"
  content: |
    you may be embedded in the strata
    or clinging to the outer dermis
    of a canyon wall
  padding_right: 85
  max_width: 420
```

### 3. With icon and tributary link
```yaml
- id: "line3"
  scroll_position: 1000
  side: "left"
  content: "you flew in on wind gusts from quartz and iron dunes"
  padding_left: 100
  icon: "atmosphere"
  trib: "atmosphere"
```

### 4. With icon, link, and anchor to specific section
```yaml
- id: "line4"
  scroll_position: 1300
  side: "right"
  content: "or the river might cut you from your bed"
  icon: "water"
  trib: "water"
  anchor: "seeps"
```

### 5. Larger emphasis text
```yaml
- id: "line5"
  scroll_position: 1600
  side: "left"
  content: "you are radioactive"
  font_size: 22
  text_align: "center"
  max_width: 300
```

---

## Tips

- **Spacing:** Space sections 200-600px apart for good rhythm
- **Balance:** Alternate left/right sides for visual interest
- **Testing:** Save `river-poem.yml` and refresh browser to see changes
- **Positioning:** Adjust `scroll_position` to align with river curves
- **Icons:** Add icons near related content to guide readers to tributaries
