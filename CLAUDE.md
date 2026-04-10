# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based digital collection site built on **CollectionBuilder-CSV**, a template framework designed for librarians and digital humanities practitioners. The site, titled "Sedimentation: An Archive of Glen Canyon," explores Glen Canyon's entangled human and natural histories through a sedimentary archive.

## Development Commands

### Build and Serve
```bash
# Serve the site locally with live reload
bundle exec jekyll serve

# Build for production
rake deploy
# or
JEKYLL_ENV=production bundle exec jekyll build
```

### Asset Management
```bash
# Generate thumbnail and small images from objects/ directory
rake generate_derivatives

# Download objects from URLs in CSV and rename
rake download_by_csv[csv_file,download_link,download_rename,output_dir]

# Rename objects using CSV mapping
rake rename_by_csv[csv_file,filename_current,filename_new,input_dir,output_dir]

# Resize images
rake resize_images[new_size,new_format,input_dir,output_dir]
```

### Dependencies
```bash
# Install Ruby gems
bundle install
```

## Architecture

### Data-Driven Design
The site is **metadata-driven**: content is generated from CSV files in [_data/](_data/), not manually created pages. The primary metadata file is [_data/sedi.csv](_data/sedi.csv), which defines ~400 collection items.

### Jekyll Plugins (/_plugins/)
Custom generators create site functionality:

- **cb_page_gen.rb**: Generates individual item pages from metadata rows. Reads `_data/sedi.csv` and creates an HTML page for each row (filtered by `objectid` field and absence of `parentid`). Uses `display_template` metadata column to determine layout.
- **cb_helpers.rb**: Processes theme configuration from [_data/theme.yml](_data/theme.yml), setting defaults and calculating values to avoid slow Liquid operations.
- **tributary_bibliography.rb**: Extracts footnote citations from tributary collection files and generates [complete_bibliography](pages/resources.md) page.
- **complete_bibliography.rb**: Companion to tributary_bibliography for full bibliography generation.
- **array_count_uniq.rb** & **sort_numeric.rb**: Utility filters for Liquid templates.

### Custom Collections
- **Tributaries** ([_tributaries/](_tributaries/)): Special narrative pages (atmosphere.md, biota.md, humans.md, land.md, water.md) with custom layouts and scrollytelling features. Configured in `_config.yml` with `output: true` and permalink structure.

### Configuration Files
- **_config.yml**: Site settings including `metadata: sedi` (which CSV to use), `baseurl: /sedimentation`, collections configuration, and URL variables.
- **_data/theme.yml**: Visual and feature configuration (map center, timeline settings, featured image, navbar colors, etc.).
- **_data/config-*.csv**: Feature-specific configurations (browse, map, metadata display, navigation, search, table).

### Data Generation
When Jekyll builds:
1. Plugins process metadata CSV and generate JSON files in [assets/data/](assets/data/) (metadata.json, subjects.json, locations.json, timelinejs.json, geodata.json, etc.)
2. These JSONs power interactive features: browse page, map, timeline, search

### Object Files
- **objects/**: Original images and media files
- Rake tasks generate derivatives (small, thumb) which are stored in `objects/small/` and `objects/thumbs/`
- Metadata CSV references these with `object_location`, `image_small`, `image_thumb` columns

### Layouts & Includes
- **_layouts/**: Page templates (default, item, tributary, etc.)
- **_includes/**: Reusable components (feature snippets, nav, footer, etc.)
- **_sass/**: Custom SCSS/CSS

## Coding Conventions (from CONTRIBUTING.md)

- **Comments**: Include extensive inline comments for educational purposes
- **Code simplicity**: Keep structure comprehensible for digital librarians, not necessarily fully optimized
- **Liquid spacing**: Include spaces for readability, e.g., `{% if site.example %}{{ site.example }}{% endif %}`
- **Indentation**: Use 4 spaces for HTML/JS/CSS, 2 spaces for YAML
- **Multi-valued fields**: Use `;` separator in metadata
- **Backwards compatibility**: New features should maintain compatibility with existing data setups using sane defaults

## Project Context

- Built by Center for Digital Inquiry and Learning (CDIL)
- CollectionBuilder prioritizes pragmatic, sustainable approaches accessible to librarians (not full-time developers)
- Main metadata has fields: objectid, title, tributary, description, creator, date, subject, damspace (Above/Below dam), damtime (Pre/Post-dam), location, lat/long, format, etc.
- Site includes custom features like "river poem" visualization and tributary narrative structure
