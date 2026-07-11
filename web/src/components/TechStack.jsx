import { motion } from 'framer-motion';
import SectionHeading from './SectionHeading.jsx';
import { stackCategories } from '../data/stack.js';
import { handleSpotlightMove } from '../utils/spotlight.js';

export default function TechStack() {
  return (
    <section id="stack" className="section">
      <SectionHeading
        eyebrow="Tech Stack"
        title="Tools I use to ship and run infrastructure"
        description="Grouped by where they sit in the stack — from provisioning to the signals that tell me something's wrong."
      />

      <div className="grid md:grid-cols-3 gap-6">
        {stackCategories.map((cat, ci) => (
          <motion.div
            key={cat.label}
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-60px' }}
            transition={{ delay: ci * 0.1, duration: 0.5 }}
            onMouseMove={handleSpotlightMove}
            className="spotlight card card-hover p-6"
          >
            <h3 className="font-mono text-xs uppercase tracking-[0.14em] text-muted mb-4">{cat.label}</h3>
            <div className="flex flex-wrap gap-2">
              {cat.items.map((item) => (
                <span
                  key={item}
                  className="badge hover:border-accent/40 hover:text-white transition-colors cursor-default"
                >
                  {item}
                </span>
              ))}
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
