---
layout: print-hub
title: Print & PDF
permalink: /print/
sitemap: false
search_exclude: true
---

<div class="print-hub">

  <div class="print-hub-header">
    <h1>Print &amp; PDF</h1>
    <p>Print individual tributary essays, save your Eddies journey, or build a custom book from the archive.</p>
  </div>

  <!-- Format selector -->
  <div class="print-hub-section">
    <h2>Page Format</h2>
    <div class="format-selector" role="group" aria-label="Page format">
      <span class="format-label">Size:</span>
      <button class="format-btn" data-format="letter">Letter</button>
      <button class="format-btn" data-format="a4">A4</button>
      <button class="format-btn" data-format="69">6×9″</button>
    </div>
  </div>

  <!-- Tributary essays -->
  <div class="print-hub-section">
    <h2>Tributary Essays</h2>
    <div class="tributary-cards">
      {% assign sorted_tribs = site.tributaries | sort: "order" %}
      {% for trib in sorted_tribs %}
      <div class="tributary-card">
        <p class="card-title">{{ trib.title }}</p>
        <a class="card-link" href="{{ '/print/' | append: trib.slug | append: '/' | relative_url }}" data-tributary="{{ trib.slug }}" target="_blank">
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16">
            <path d="M2.5 8a.5.5 0 1 0 0-1 .5.5 0 0 0 0 1z"/>
            <path d="M5 1a2 2 0 0 0-2 2v2H2a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h1v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h1a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-1V3a2 2 0 0 0-2-2H5zM4 3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2H4V3zm1 5a2 2 0 0 0-2 2v1H2a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v-1a2 2 0 0 0-2-2H5zm7 2v3a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1z"/>
          </svg>
          Print Essay
        </a>
      </div>
      {% endfor %}
    </div>
  </div>

  <!-- Eddies -->
  <div class="print-hub-section">
    <h2>Your Eddies Journey</h2>
    <div class="eddies-card">
      <div class="eddies-card-content">
        <p class="card-title">Eddies</p>
        <p class="eddies-status" id="eddies-session-status">Checking for active session…</p>
      </div>
      <a class="card-link" id="eddies-print-link" href="{{ '/print/eddies/' | relative_url }}" target="_blank">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16">
          <path d="M2.5 8a.5.5 0 1 0 0-1 .5.5 0 0 0 0 1z"/>
          <path d="M5 1a2 2 0 0 0-2 2v2H2a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h1v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h1a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-1V3a2 2 0 0 0-2-2H5zM4 3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2H4V3zm1 5a2 2 0 0 0-2 2v1H2a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v-1a2 2 0 0 0-2-2H5zm7 2v3a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1z"/>
        </svg>
        Print Journey
      </a>
    </div>
  </div>

  <!-- Book builder -->
  <div class="print-hub-section">
    <h2>Build the Book</h2>
    <div class="book-builder">
      <ul class="book-checklist" id="book-checklist">
        {% for trib in sorted_tribs %}
        <li>
          <input type="checkbox" id="book-{{ trib.slug }}" value="{{ trib.slug }}" checked>
          <label for="book-{{ trib.slug }}">{{ trib.title }}</label>
        </li>
        {% endfor %}
      </ul>
      <button class="book-generate-btn" id="book-generate-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16" style="margin-right:0.4rem;">
          <path d="M2.5 8a.5.5 0 1 0 0-1 .5.5 0 0 0 0 1z"/>
          <path d="M5 1a2 2 0 0 0-2 2v2H2a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h1v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h1a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-1V3a2 2 0 0 0-2-2H5zM4 3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2H4V3zm1 5a2 2 0 0 0-2 2v1H2a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v-1a2 2 0 0 0-2-2H5zm7 2v3a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1z"/>
        </svg>
        Generate Book PDF
      </button>
    </div>
  </div>

</div>

<script>
(function() {
  // ——— Format selector ———
  var storedFormat = localStorage.getItem('print-format') || 'letter';

  document.querySelectorAll('.format-btn').forEach(function(btn) {
    if (btn.dataset.format === storedFormat) btn.classList.add('active');
    btn.addEventListener('click', function() {
      var fmt = this.dataset.format;
      localStorage.setItem('print-format', fmt);
      document.querySelectorAll('.format-btn').forEach(function(b) {
        b.classList.toggle('active', b.dataset.format === fmt);
      });
      storedFormat = fmt;
      // Update all tributary card links
      updateTribLinks(fmt);
    });
  });

  function updateTribLinks(fmt) {
    document.querySelectorAll('.card-link[data-tributary]').forEach(function(link) {
      var slug = link.dataset.tributary;
      var base = link.href.split('?')[0];
      link.href = base + '?format=' + fmt;
    });
    var eddiesLink = document.getElementById('eddies-print-link');
    if (eddiesLink) {
      var base = eddiesLink.href.split('?')[0];
      eddiesLink.href = base + '?format=' + fmt;
    }
  }

  // Set initial format on links
  updateTribLinks(storedFormat);

  // ——— Eddies session status ———
  var statusEl = document.getElementById('eddies-session-status');
  var eddiesLink = document.getElementById('eddies-print-link');
  var rawSession = localStorage.getItem('eddies-print-session');

  if (rawSession) {
    try {
      var session = JSON.parse(rawSession);
      var count = session.sections ? session.sections.length : 0;
      if (count > 0) {
        var date = session.generatedAt
          ? new Date(session.generatedAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
          : '';
        statusEl.textContent = count + ' section' + (count !== 1 ? 's' : '') +
          (date ? ' · saved ' + date : '');
      } else {
        statusEl.textContent = 'No sections recorded';
        eddiesLink.classList.add('disabled');
      }
    } catch(e) {
      statusEl.textContent = 'No active session';
      eddiesLink.classList.add('disabled');
    }
  } else {
    statusEl.textContent = 'No active session — visit Eddies to begin';
    eddiesLink.classList.add('disabled');
  }

  // ——— Book builder ———
  document.getElementById('book-generate-btn').addEventListener('click', function() {
    var checked = Array.from(
      document.querySelectorAll('#book-checklist input[type="checkbox"]:checked')
    ).map(function(cb) { return cb.value; });

    if (checked.length === 0) {
      alert('Select at least one essay to include.');
      return;
    }

    var fmt = localStorage.getItem('print-format') || 'letter';
    var baseUrl = '{{ "/print/book/" | relative_url }}';
    window.open(baseUrl + '?essays=' + checked.join(',') + '&format=' + fmt, '_blank');
  });

})();
</script>
