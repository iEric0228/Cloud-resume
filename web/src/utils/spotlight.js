// Sets --x/--y CSS custom properties on the hovered element so the shared
// `.spotlight` class (see index.css) can render a radial glow that follows
// the cursor. Kept as a plain function (not a hook) so it can be attached
// directly to onMouseMove without extra state/re-renders.
export function handleSpotlightMove(e) {
  const el = e.currentTarget;
  const rect = el.getBoundingClientRect();
  el.style.setProperty('--x', `${e.clientX - rect.left}px`);
  el.style.setProperty('--y', `${e.clientY - rect.top}px`);
}
