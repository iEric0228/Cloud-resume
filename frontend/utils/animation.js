/**
 * animation.js
 * Progressive enhancements. Motion effects are gated on prefers-reduced-motion;
 * the sticky-nav state and footer year are not motion, so they always run.
 *   1. Sticky-nav background/blur once the page scrolls
 *   2. Footer year injection
 *   3. Scroll-triggered staggered fade-in for sections, projects, stats (motion)
 *   4. Scroll progress indicator bar (motion)
 *   5. Count-up for the stats strip (motion)
 *   6. Pointer-tracking spotlight on project cards, fine pointers only (motion)
 */
(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ── 1. Sticky-nav state (not motion) ──────────────────────────────────────
  const initNavState = () => {
    const nav = document.querySelector('.nav');
    if (!nav) return;
    let ticking = false;
    const update = () => {
      nav.classList.toggle('is-scrolled', window.scrollY > 8);
      ticking = false;
    };
    window.addEventListener('scroll', () => {
      if (!ticking) {
        window.requestAnimationFrame(update);
        ticking = true;
      }
    }, { passive: true });
    update();
  };

  // ── 2. Footer year (not motion) ───────────────────────────────────────────
  const initYear = () => {
    const el = document.getElementById('year');
    if (el) el.textContent = String(new Date().getFullYear());
  };

  // ── 3. Scroll reveal ──────────────────────────────────────────────────────
  const initScrollReveal = () => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.06, rootMargin: '0px 0px -40px 0px' }
    );

    const stagger = (elements, baseDelay) => {
      elements.forEach((el, i) => {
        el.classList.add('fade-in-up');
        el.style.transitionDelay = `${baseDelay + i * 70}ms`;
        observer.observe(el);
      });
    };

    document.querySelectorAll('.section').forEach((el) => {
      el.classList.add('fade-in-up');
      observer.observe(el);
    });
    stagger(document.querySelectorAll('.project'), 0);
    stagger(document.querySelectorAll('.stat'), 0);
  };

  // ── 4. Scroll progress bar ────────────────────────────────────────────────
  const initScrollProgress = () => {
    const bar = document.createElement('div');
    bar.className = 'scroll-progress';
    bar.setAttribute('aria-hidden', 'true');
    document.body.appendChild(bar);

    let ticking = false;
    const update = () => {
      const doc = document.documentElement;
      const max = doc.scrollHeight - doc.clientHeight;
      const ratio = max > 0 ? doc.scrollTop / max : 0;
      bar.style.transform = `scaleX(${ratio})`;
      ticking = false;
    };

    window.addEventListener('scroll', () => {
      if (!ticking) {
        window.requestAnimationFrame(update);
        ticking = true;
      }
    }, { passive: true });
    update();
  };

  // ── 5. Stats count-up ─────────────────────────────────────────────────────
  const initCountUp = () => {
    const els = document.querySelectorAll('[data-count]');
    if (!els.length) return;

    const DURATION = 1200;
    const easeOut = (t) => 1 - Math.pow(1 - t, 3);

    const run = (el) => {
      const target = Number(el.dataset.count);
      if (!Number.isFinite(target)) return;
      const start = performance.now();
      const tick = (now) => {
        const progress = Math.min((now - start) / DURATION, 1);
        el.textContent = String(Math.round(target * easeOut(progress)));
        if (progress < 1) requestAnimationFrame(tick);
        else el.textContent = String(target);
      };
      requestAnimationFrame(tick);
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          run(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.5 });

    els.forEach((el) => observer.observe(el));
  };

  // ── 6. Pointer spotlight on project cards ─────────────────────────────────
  const initSpotlight = () => {
    if (!window.matchMedia('(hover: hover) and (pointer: fine)').matches) return;

    document.querySelectorAll('.project').forEach((card) => {
      let raf = null;
      let lastX = 0;
      let lastY = 0;

      card.addEventListener('mousemove', (e) => {
        lastX = e.clientX;
        lastY = e.clientY;
        if (raf) return;
        raf = window.requestAnimationFrame(() => {
          const rect = card.getBoundingClientRect();
          card.style.setProperty('--mx', `${lastX - rect.left}px`);
          card.style.setProperty('--my', `${lastY - rect.top}px`);
          raf = null;
        });
      });
    });
  };

  const init = () => {
    // Always run — these are not motion effects.
    initNavState();
    initYear();
    if (reduceMotion) return;
    // Motion-only enhancements below.
    initScrollReveal();
    initScrollProgress();
    initCountUp();
    initSpotlight();
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
})();
