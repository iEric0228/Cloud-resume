import { motion } from 'framer-motion';
import { useRef, useState } from 'react';

/**
 * Wraps a single interactive child (e.g. a button) and nudges it a few
 * pixels toward the cursor on hover for a subtle "magnetic" feel, then
 * springs back on mouse leave. No-ops for reduced-motion users.
 */
export default function Magnetic({ children, strength = 0.25 }) {
  const ref = useRef(null);
  const [pos, setPos] = useState({ x: 0, y: 0 });
  const reduced =
    typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (reduced) return children;

  const handleMove = (e) => {
    const rect = ref.current.getBoundingClientRect();
    setPos({
      x: (e.clientX - rect.left - rect.width / 2) * strength,
      y: (e.clientY - rect.top - rect.height / 2) * strength,
    });
  };

  return (
    <motion.div
      ref={ref}
      onMouseMove={handleMove}
      onMouseLeave={() => setPos({ x: 0, y: 0 })}
      animate={{ x: pos.x, y: pos.y }}
      transition={{ type: 'spring', stiffness: 150, damping: 12, mass: 0.4 }}
      className="inline-block"
    >
      {children}
    </motion.div>
  );
}
