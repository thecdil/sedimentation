---
layout: page
title: Home
permalink: /old.html
---

<div class="cover-links">
      {% assign cover_pages = site.html_pages | where_exp: "page", "page.url contains 'cover'" %}
      {% if cover_pages.size > 0 %}
        {% for cover_page in cover_pages %}
          <a href="{{ cover_page.url | relative_url }}" class="btn btn-outline-primary m-1">
            {{ cover_page.title | default: cover_page.url }}
          </a>
        {% endfor %}
      {% else %}
        <p class="text-muted">No coverage pages found.</p>
      {% endif %}
    </div>