import { useEffect, useState } from 'react';

// Public API Gateway endpoint (already exposed in the deployed bundle — not a secret).
// Resilient fallback so the count still renders if the CI injection into
// public/config.js was skipped (e.g. local preview).
const FALLBACK_API_URL = 'https://nm17e5j01b.execute-api.us-east-1.amazonaws.com/prod/count';
const MAX_RETRIES = 3;
const BASE_DELAY_MS = 1000;

function resolveApiUrl() {
  const injected = typeof window !== 'undefined' ? window.API_URL : null;
  return injected && !injected.includes('REPLACE_WITH') ? injected : FALLBACK_API_URL;
}

function extractCount(data) {
  if (typeof data !== 'object' || data === null) return null;
  const val = data.visitor_count ?? data.count ?? data.visitors;
  return typeof val === 'number' ? val : null;
}

async function fetchCount() {
  const response = await fetch(resolveApiUrl(), {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
    signal: AbortSignal.timeout(8000),
  });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const data = await response.json();
  const count = extractCount(data);
  if (count === null) throw new Error('Unexpected response shape');
  return count;
}

// Returns { count: number|null, status: 'loading'|'ready'|'error' }.
// 'error' is surfaced explicitly (e.g. rendered as an em dash) rather than
// silently showing a fabricated number.
export function useVisitorCount() {
  const [state, setState] = useState({ count: null, status: 'loading' });

  useEffect(() => {
    let cancelled = false;

    async function run() {
      const apiUrl = resolveApiUrl();
      if (!apiUrl.startsWith('https://')) {
        if (!cancelled) setState({ count: null, status: 'error' });
        return;
      }
      for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
        try {
          const count = await fetchCount();
          if (!cancelled) setState({ count, status: 'ready' });
          return;
        } catch (err) {
          if (attempt === MAX_RETRIES) {
            console.error('[visitor-counter] Failed after retries:', err.message);
            if (!cancelled) setState({ count: null, status: 'error' });
            return;
          }
          await new Promise((res) => setTimeout(res, BASE_DELAY_MS * attempt));
        }
      }
    }

    run();
    return () => {
      cancelled = true;
    };
  }, []);

  return state;
}
