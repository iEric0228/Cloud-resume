/**
 * visitor-counter.js
 * Fetches and animates the visitor count from AWS API Gateway → Lambda → DynamoDB.
 * The CI/CD pipeline replaces REPLACE_WITH_API_URL at deploy time.
 */

const VISITOR_API_URL = 'REPLACE_WITH_API_URL';

const MAX_RETRIES   = 3;
const BASE_DELAY_MS = 1000;
const ANIM_DURATION = 2000;

// ── DOM helpers ───────────────────────────────────────────────────────────────
function getCountEl() {
  return document.getElementById('visitor-count');
}

function showError(message) {
  const el = getCountEl();
  if (!el) return;
  el.textContent = message;
  el.style.color = '#ff6b6b';
  el.style.fontSize = '';
  el.style.removeProperty('-webkit-text-fill-color');
  el.style.background = 'none';
}

// ── Counter animation ─────────────────────────────────────────────────────────
function animateCount(el, target) {
  const start     = Date.now();
  const easeOut   = (t) => 1 - Math.pow(1 - t, 3);

  const tick = () => {
    const progress = Math.min((Date.now() - start) / ANIM_DURATION, 1);
    el.textContent = Math.floor(target * easeOut(progress)).toLocaleString();

    if (progress < 1) {
      requestAnimationFrame(tick);
    } else {
      el.textContent = target.toLocaleString();
      // Apply golden gradient via CSS class (not inline style) to avoid conflict
      el.classList.add('counter-display__number--final');
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
  const response = await fetch(VISITOR_API_URL, {
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
  // Guard: URL not yet injected (local dev / preview)
  if (!VISITOR_API_URL || VISITOR_API_URL.includes('REPLACE_WITH')) {
    showError('(dev mode)');
    return;
  }

  if (!VISITOR_API_URL.startsWith('https://')) {
    showError('Invalid API URL');
    return;
  }

  const el = getCountEl();
  if (!el) return;

  try {
    const count = await fetchWithRetry();
    animateCount(el, count);
  } catch (err) {
    console.error('[visitor-counter] Failed after retries:', err.message);
    showError('Unavailable');
  }
}

// Single initialization — safe to call regardless of DOM readiness
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initVisitorCounter, { once: true });
} else {
  initVisitorCounter();
}
