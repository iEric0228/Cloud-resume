import { motion, useScroll, useSpring } from 'framer-motion';

// Thin accent-colored progress bar pinned to the top of the viewport,
// smoothed with a spring so it doesn't feel like a raw scrollbar readout.
export default function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, { stiffness: 200, damping: 30, restDelta: 0.001 });

  return (
    <motion.div
      style={{ scaleX }}
      className="fixed top-0 left-0 right-0 h-[2px] origin-left bg-accent z-[60]"
      aria-hidden="true"
    />
  );
}
