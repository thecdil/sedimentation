---
title: Eddies
layout: page
permalink: /eddies/
gallery: true
custom-foot: js/eddies-cyoa-js.html;js/spotlight-media-handler.html
---

# Eddies

<div class="eddies-container">
  <!-- Initial intro screen -->
  <div id="eddies-intro" class="eddies-intro">
    <p class="eddies-description">Dive into the sedimentary layers of Glen Canyon. Each click unearths a new story, randomly drawn from the tributaries of water, land, atmosphere, biota, and humans.</p>
    <button id="begin-journey-btn" class="begin-journey-btn">
      <span class="btn-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
          <path fill-rule="evenodd" d="M8 1a.5.5 0 0 1 .5.5v11.793l3.146-3.147a.5.5 0 0 1 .708.708l-4 4a.5.5 0 0 1-.708 0l-4-4a.5.5 0 0 1 .708-.708L7.5 13.293V1.5A.5.5 0 0 1 8 1z"/>
        </svg>
      </span>
      Begin Journey
    </button>
  </div>

  <!-- Sections load here dynamically -->
  <div id="eddies-sections" class="eddies-sections"></div>
</div>
