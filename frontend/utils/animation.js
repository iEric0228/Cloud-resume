/**
 * animation.js
 * Scroll-triggered fade-ins, loading screen, typing effect, and cursor particles.
 * Motion is suppressed when the user prefers reduced motion.
 */

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// ── Loading Screen ────────────────────────────────────────────────────────────
function initLoadingScreen() {
  const screen = document.querySelector('.loading-screen');
  if (!screen) return;

  const hide = () => {
    screen.classList.add('is-hidden');
    screen.addEventListener('transitionend', () => screen.remove(), { once: true });
  };

  if (document.readyState === 'complete') {
    setTimeout(hide, 300);
  } else {
    window.addEventListener('load', () => setTimeout(hide, 400), { once: true });
  }
}

// ── Scroll Animations ─────────────────────────────────────────────────────────
function initScrollAnimations() {
  if (prefersReducedMotion) return;

  const sections = document.querySelectorAll('.section');
  if (!sections.length) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target); // fire once
        }
      });
    },
    { threshold: 0.08 }
  );

  sections.forEach((section, i) => {
    section.classList.add('fade-in-up');
    section.style.transitionDelay = `${i * 60}ms`;
    observer.observe(section);
  });
}

// ── Typing Effect ─────────────────────────────────────────────────────────────
function initTypingEffect() {
  if (prefersReducedMotion) return;

  const tagline = document.querySelector('.header__tagline');
  if (!tagline) return;

  const fullText = tagline.textContent.trim();
  tagline.textContent = '';
  tagline.setAttribute('aria-label', fullText);

  let index = 0;
  const cursor = document.createElement('span');
  cursor.className = 'typing-cursor';
  cursor.setAttribute('aria-hidden', 'true');
  tagline.appendChild(cursor);

  const type = () => {
    if (index < fullText.length) {
      tagline.insertBefore(document.createTextNode(fullText.charAt(index)), cursor);
      index++;
      setTimeout(type, 38);
    } else {
      setTimeout(() => cursor.remove(), 1200);
    }
  };

  setTimeout(type, 900);
}

// ── Cursor Particles ──────────────────────────────────────────────────────────
function initParticleEffect() {
  if (prefersReducedMotion) return;

  const COLORS = ['#667eea', '#764ba2', '#f093fb', '#f5576c', '#00f2fe'];
  const SPAWN_CHANCE = 0.12;

  // Inject keyframe once only
  if (!document.getElementById('particle-keyframe')) {
    const style = document.createElement('style');
    style.id = 'particle-keyframe';
    style.textContent = `
      @keyframes particle-rise {
        0%   { transform: translateY(0)   scale(1);   opacity: 0.9; }
        100% { transform: translateY(-28px) scale(0); opacity: 0; }
      }
      .cursor-particle {
        position: fixed;
        width: 5px;
        height: 5px;
        border-radius: 50%;
        pointer-events: none;
        z-index: 9000;
        animation: particle-rise 0.9s ease-out forwards;
      }
    `;
    document.head.appendChild(style);
  }

  document.addEventListener('mousemove', (e) => {
    if (Math.random() > SPAWN_CHANCE) return;
    const p = document.createElement('div');
    p.className = 'cursor-particle';
    p.style.background = COLORS[Math.floor(Math.random() * COLORS.length)];
    p.style.left = `${e.clientX}px`;
    p.style.top = `${e.clientY}px`;
    document.body.appendChild(p);
    p.addEventListener('animationend', () => p.remove(), { once: true });
  });
}

// ── Bootstrap ─────────────────────────────────────────────────────────────────
function init() {
  initLoadingScreen();
  initScrollAnimations();
  initTypingEffect();
  initParticleEffect();
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init, { once: true });
} else {
  init();
}
