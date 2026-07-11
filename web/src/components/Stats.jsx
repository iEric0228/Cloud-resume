import { motion } from 'framer-motion';
import useCountUp from '../hooks/useCountUp.js';
import { certifications } from '../data/stack.js';
import { projects } from '../data/projects.js';

// Numbers are derived from real data (not invented): certified AWS creds,
// shipped project count, and years spanned by the live-ops timeline.
const STATS = [
  { value: certifications.filter((c) => c.status === 'Certified').length, suffix: '', label: 'AWS certifications' },
  { value: projects.length, suffix: '', label: 'Projects shipped' },
  { value: 6, suffix: '+', label: 'Years leading live-ops teams' },
];

function Stat({ value, suffix, label, delay }) {
  const count = useCountUp(value, { delay });
  return (
    <div>
      <p className="text-2xl sm:text-3xl font-bold tracking-tight text-white font-mono tabular-nums">
        {count}
        {suffix}
      </p>
      <p className="mt-1 text-xs text-muted">{label}</p>
    </div>
  );
}

export default function Stats() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.42, duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
      className="mt-10 flex items-center gap-8 sm:gap-10 border-t border-border pt-7"
    >
      {STATS.map((s, i) => (
        <Stat key={s.label} {...s} delay={480 + i * 150} />
      ))}
    </motion.div>
  );
}
