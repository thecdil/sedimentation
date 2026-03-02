/**
 * Tributary Button Particle Animation System
 * Handles particle disintegration effect and seamless page transitions
 */

(function() {
  'use strict';

  const colors = {
    particles: ['#CD853F', '#D2691E', '#F4A460', '#DEB887', '#BC8F8F', '#A0522D'],
    overlayBg: 'rgba(248, 245, 240, 0.95)'
  };

  // Configuration presets
  const PRESETS = {
    fast: {
      duration: 700,
      particleDensity: 3.5,
      particleSpeed: 1.3,
      fadeSpeed: 0.12,
      bodyFade: 0.6
    },
    normal: {
      duration: 1400,
      particleDensity: 2.5,
      particleSpeed: 1.0,
      fadeSpeed: 0.08,
      bodyFade: 0.7
    }
  };

  /**
   * Particle class for sediment animation
   */
  class TribParticle {
    constructor(x, y, targetSide, color, size, config) {
      this.x = x;
      this.y = y;
      this.targetSide = targetSide;
      this.color = color;
      this.size = size;
      this.opacity = 1;
      this.life = 1;
      this.config = config;

      // River flow with variance
      const speedMultiplier = config.particleSpeed;
      this.vx = (targetSide === 'right' ? 1 : -1) * (Math.random() * 4 + 6) * speedMultiplier;
      this.vy = (Math.random() * 4 - 1.5) * speedMultiplier;

      // Turbulence for water effect
      this.turbulence = Math.random() * 0.5;
    }

    update() {
      // Gradual slowdown
      this.vx *= 0.97;
      this.vy *= 0.97;

      // Gravity and turbulence
      this.vy += 0.15;
      this.vx += Math.sin(this.y * 0.02) * this.turbulence;

      this.x += this.vx;
      this.y += this.vy;

      // Fade particles as they exit viewport
      const margin = 100;
      if (this.x < -margin || this.x > window.innerWidth + margin ||
          this.y > window.innerHeight + margin) {
        this.life -= this.config.fadeSpeed;
        this.opacity = Math.max(0, this.life);
      }
    }

    draw(ctx) {
      if (this.opacity <= 0) return;

      ctx.globalAlpha = this.opacity;
      ctx.fillStyle = this.color;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalAlpha = 1;
    }

    isDead() {
      return this.opacity <= 0;
    }
  }

  /**
   * Create or get the global transition overlay
   */
  function getOrCreateOverlay() {
    let overlay = document.getElementById('trib-transition-overlay');

    if (!overlay) {
      overlay = document.createElement('div');
      overlay.id = 'trib-transition-overlay';
      overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        z-index: 10000;
        display: none;
        opacity: 0;
        transition: opacity 0.3s ease;
      `;
      document.body.appendChild(overlay);
    }

    return overlay;
  }

  /**
   * Create or get the particle canvas within overlay
   */
  function getOrCreateCanvas(overlay) {
    let canvas = overlay.querySelector('canvas');

    if (!canvas) {
      canvas = document.createElement('canvas');
      canvas.style.cssText = `
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
      `;
      overlay.appendChild(canvas);
    }

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    return canvas;
  }

  /**
   * Main disintegration effect with overlay transition
   */
  function disintegrateImage(imgElement, targetLink, flowSide, speed = 'normal') {
    const config = PRESETS[speed] || PRESETS.normal;
    const overlay = getOrCreateOverlay();
    const canvas = getOrCreateCanvas(overlay);
    const ctx = canvas.getContext('2d');

    // Show overlay
    overlay.style.display = 'block';

    const rect = imgElement.getBoundingClientRect();
    const img = new Image();

    // Only set crossOrigin if image is from different domain
    const imgUrl = new URL(imgElement.src, window.location.href);
    if (imgUrl.origin !== window.location.origin) {
      img.crossOrigin = "anonymous";
    }

    function createParticles() {
      const tempCanvas = document.createElement('canvas');
      const tempCtx = tempCanvas.getContext('2d');
      tempCanvas.width = rect.width;
      tempCanvas.height = rect.height;
      tempCtx.drawImage(img, 0, 0, rect.width, rect.height);

      const particles = [];
      const sampleRate = config.particleDensity;
      let useFallback = false;

      try {
        const imageData = tempCtx.getImageData(0, 0, rect.width, rect.height);

        for (let y = 0; y < rect.height; y += sampleRate) {
          for (let x = 0; x < rect.width; x += sampleRate) {
            const index = (y * rect.width + x) * 4;
            const alpha = imageData.data[index + 3];

            if (alpha > 20) {
              const r = imageData.data[index];
              const g = imageData.data[index + 1];
              const b = imageData.data[index + 2];
              const color = `rgba(${r},${g},${b},${alpha/255})`;

              const particleX = rect.left + x;
              const particleY = rect.top + y;
              const size = Math.random() * 2.5 + 1.5;

              particles.push(new TribParticle(particleX, particleY, flowSide, color, size, config));
            }
          }
        }

        if (particles.length < 50) {
          useFallback = true;
        }
      } catch(e) {
        console.warn('Image processing failed, using fallback particles');
        useFallback = true;
      }

      // Enhanced fallback for CORS issues or small images
      if (useFallback) {
        particles.length = 0;
        const particleCount = Math.max(120, (rect.width * rect.height) / 25);

        for (let i = 0; i < particleCount; i++) {
          const particleX = rect.left + Math.random() * rect.width;
          const particleY = rect.top + Math.random() * rect.height;
          const color = colors.particles[Math.floor(Math.random() * colors.particles.length)];
          const size = Math.random() * 2.5 + 1.5;

          particles.push(new TribParticle(particleX, particleY, flowSide, color, size, config));
        }
      }

      // Hide image smoothly
      imgElement.style.opacity = '0';

      let startTime = Date.now();
      const totalDuration = config.duration;

      function animate() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / totalDuration, 1);

        // Clear canvas with slight trail
        ctx.fillStyle = 'rgba(248, 245, 240, 0.2)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Fade overlay background (creates seamless transition)
        overlay.style.backgroundColor = colors.overlayBg;
        overlay.style.opacity = Math.min(progress * 1.5, 1).toString();

        // Update and draw particles
        for (let i = particles.length - 1; i >= 0; i--) {
          particles[i].update();
          particles[i].draw(ctx);

          if (particles[i].isDead()) {
            particles.splice(i, 1);
          }
        }

        if (elapsed >= totalDuration || particles.length === 0) {
          // Ensure overlay is fully opaque before navigation
          overlay.style.opacity = '1';

          // Brief delay to ensure visual stability
          setTimeout(function() {
            window.location.href = targetLink;
          }, 50);
        } else {
          requestAnimationFrame(animate);
        }
      }

      animate();
    }

    // Handle both cached and uncached images
    if (img.complete || imgElement.complete) {
      img.src = imgElement.src;
      setTimeout(createParticles, 0);
    } else {
      img.onload = createParticles;
      img.onerror = function() {
        console.warn('Image load error, still showing effect');
        createParticles();
      };
      img.src = imgElement.src;
    }
  }

  /**
   * Initialize on page load - clean up any leftover overlays
   */
  function initCleanup() {
    const overlay = document.getElementById('trib-transition-overlay');
    if (overlay) {
      overlay.style.display = 'none';
      overlay.style.opacity = '0';
      overlay.style.backgroundColor = 'transparent';

      // Clear any canvas
      const canvas = overlay.querySelector('canvas');
      if (canvas) {
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
      }
    }

    // Ensure body opacity is always reset
    document.body.style.opacity = '1';

    // Reset all button images to visible (in case they were hidden during transition)
    const buttonImages = document.querySelectorAll('.trib-button-image');
    buttonImages.forEach(img => {
      img.style.opacity = '1';
    });
  }

  /**
   * Initialize button event listeners
   */
  function initButtons() {
    const tribButtons = document.querySelectorAll('.trib-button-link');

    tribButtons.forEach(button => {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        const imgElement = this.querySelector('.trib-button-image');
        const targetLink = this.getAttribute('href');
        const flowSide = this.getAttribute('data-flow-side');
        const speed = this.getAttribute('data-speed') || 'normal';

        disintegrateImage(imgElement, targetLink, flowSide, speed);
      });
    });
  }

  /**
   * Initialize continue button scroll functionality
   */
  function initContinueButtons() {
    const continueButtons = document.querySelectorAll('.continue-choice .choice-inner');

    continueButtons.forEach(button => {
      button.addEventListener('click', function(e) {
        e.preventDefault();

        const buttonRow = this.closest('.trib-choice-container');
        if (!buttonRow) return;

        // Look for next meaningful content section
        let targetElement = buttonRow.nextElementSibling;

        // Skip whitespace and empty text nodes
        while (targetElement && (targetElement.nodeType !== 1 || !targetElement.offsetHeight)) {
          targetElement = targetElement.nextElementSibling;
        }

        // If no direct sibling, search within parent container
        if (!targetElement) {
          const parent = buttonRow.parentElement;
          if (parent) {
            const allSections = parent.querySelectorAll('section, .row, .container, div[id], div[class*="content"]');
            const currentIndex = Array.from(parent.children).indexOf(buttonRow);

            for (let section of allSections) {
              const sectionIndex = Array.from(parent.children).indexOf(section);
              if (sectionIndex > currentIndex && section.offsetHeight > 0) {
                targetElement = section;
                break;
              }
            }
          }
        }

        // Fallback: scroll down by viewport height
        if (!targetElement) {
          window.scrollBy({
            top: window.innerHeight * 0.8,
            behavior: 'smooth'
          });
        } else {
          const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - 20;
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
        }
      });
    });
  }

  // Initialize everything when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      initCleanup();
      initButtons();
      initContinueButtons();
    });
  } else {
    initCleanup();
    initButtons();
    initContinueButtons();
  }

  // Handle page show (fires on back button navigation from bfcache)
  window.addEventListener('pageshow', function(event) {
    if (event.persisted) {
      // Page was loaded from bfcache (back/forward button)
      // Clean up any leftover transition overlays
      initCleanup();
    }
  });

  // Export for potential external use
  window.TributaryButtons = {
    disintegrateImage: disintegrateImage,
    reinitialize: function() {
      initButtons();
      initContinueButtons();
    }
  };

})();
