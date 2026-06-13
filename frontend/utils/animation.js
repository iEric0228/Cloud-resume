/**
 * animation.js
 * Progressive enhancements (all gated on prefers-reduced-motion):
 *   1. Scroll-triggered staggered fade-in for sections, projects, skills
 *   2. Scroll progress indicator bar
 *   3. Pointer-tracking spotlight on project cards (fine pointers only)
 */
(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ── 1. Scroll reveal ──────────────────────────────────────────────────────
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
        el.style.transitionDelay = `${baseDelay + i * 80}ms`;
        observer.observe(el);
      });
    };

    document.querySelectorAll('.section').forEach((el) => {
      el.classList.add('fade-in-up');
      observer.observe(el);
    });
    stagger(document.querySelectorAll('.project'), 0);
    stagger(document.querySelectorAll('.skills__group'), 0);
  };

  // ── 2. Scroll progress bar ────────────────────────────────────────────────
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

    window.addEventListener(
      'scroll',
      () => {
        if (!ticking) {
          window.requestAnimationFrame(update);
          ticking = true;
        }
      },
      { passive: true }
    );
    update();
  };

  // ── 3. Pointer spotlight on project cards ─────────────────────────────────
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
    if (reduceMotion) return;
    initScrollReveal();
    initScrollProgress();
    initSpotlight();
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
})();
