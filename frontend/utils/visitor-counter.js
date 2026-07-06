/**
 * visitor-counter.js
 * Fetches and animates the visitor count from AWS API Gateway → Lambda → DynamoDB.
 * The CI/CD pipeline replaces REPLACE_WITH_API_URL at deploy time.
 */

const VISITOR_API_URL = 'REPLACE_WITH_API_URL';

// Public API Gateway endpoint (already exposed in the deployed bundle — not a secret).
// Resilient fallback so the count still renders when the CI placeholder is not injected
// (e.g. local preview, or a deploy where injection was skipped).
const FALLBACK_API_URL = 'https://nm17e5j01b.execute-api.us-east-1.amazonaws.com/prod/count';

const MAX_RETRIES   = 3;
const BASE_DELAY_MS = 1000;
const ANIM_DURATION = 2000;

// Prefer the CI-injected URL; fall back to the known public endpoint.
function resolveApiUrl() {
  return VISITOR_API_URL && !VISITOR_API_URL.includes('REPLACE_WITH')
    ? VISITOR_API_URL
    : FALLBACK_API_URL;
}

// ── DOM helpers ───────────────────────────────────────────────────────────────
function getCountEl() {
  return document.getElementById('visitor-count');
}

function showError() {
  const el = getCountEl();
  if (!el) return;
  el.textContent = '\u2014';
}

// ── Counter animation ─────────────────────────────────────────────────────────
function setFinal(el, target) {
  el.textContent = target.toLocaleString();
  el.classList.add('counter-display__number--final');
}

function animateCount(el, target) {
  // Show the number immediately when animation can't/shouldn't run:
  //  - reduced-motion users (a count-up is motion)
  //  - a hidden/backgrounded tab, where requestAnimationFrame is throttled and
  //    would otherwise leave the value stuck on the placeholder.
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReduced || document.hidden) {
    setFinal(el, target);
    return;
  }

  const start     = Date.now();
  const easeOut   = (t) => 1 - Math.pow(1 - t, 3);

  const tick = () => {
    const progress = Math.min((Date.now() - start) / ANIM_DURATION, 1);
    el.textContent = Math.floor(target * easeOut(progress)).toLocaleString();

    if (progress < 1) {
      requestAnimationFrame(tick);
    } else {
      setFinal(el, target);
    }
  };

  requestAnimationFrame(tick);
}

// ── Response parsing ──────────────────────────────────────────────────────────
function extractCount(data) {
  if (typeof data !== 'object' || data === null) return null;
  const val = data.visitor_count ?? data.count ?? data.visitors;
  return typeof val === 'number' ? val : null;
}

// ── Fetch with retry ──────────────────────────────────────────────────────────
async function fetchCount(attempt = 1) {
  const response = await fetch(resolveApiUrl(), {
    method:  'GET',
    headers: { 'Content-Type': 'application/json' },
    signal:  AbortSignal.timeout(8000),
  });

  if (!response.ok) throw new Error(`HTTP ${response.status}`);

  const data  = await response.json();
  const count = extractCount(data);
  if (count === null) throw new Error('Unexpected response shape');
  return count;
}

async function fetchWithRetry() {
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      return await fetchCount(attempt);
    } catch (err) {
      if (attempt === MAX_RETRIES) throw err;
      await new Promise((res) => setTimeout(res, BASE_DELAY_MS * attempt));
    }
  }
}

// ── Bootstrap ─────────────────────────────────────────────────────────────────
async function initVisitorCounter() {
  const el = getCountEl();
  if (!el) return;

  const apiUrl = resolveApiUrl();
  if (!apiUrl.startsWith('https://')) {
    showError();
    return;
  }

  try {
    const count = await fetchWithRetry();
    animateCount(el, count);
  } catch (err) {
    console.error('[visitor-counter] Failed after retries:', err.message);
    showError();
  }
}

// Single initialization — safe to call regardless of DOM readiness
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initVisitorCounter, { once: true });
} else {
  initVisitorCounter();
}
