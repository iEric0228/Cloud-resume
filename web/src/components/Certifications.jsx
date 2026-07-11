import { motion } from 'framer-motion';
import { BadgeCheck, Clock } from 'lucide-react';
import SectionHeading from './SectionHeading.jsx';
import { certifications } from '../data/stack.js';
import { handleSpotlightMove } from '../utils/spotlight.js';

export default function Certifications() {
  return (
    <section id="certifications" className="section">
      <SectionHeading eyebrow="Certifications" title="Verified AWS credentials" />
      <div className="grid sm:grid-cols-3 gap-6">
        {certifications.map((c, i) => (
          <motion.div
            key={c.name}
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-60px' }}
            transition={{ delay: i * 0.08, duration: 0.5 }}
            onMouseMove={handleSpotlightMove}
            className="spotlight card card-hover p-6 flex flex-col gap-3"
          >
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-accent/15 text-accent">
              {c.status === 'Certified' ? <BadgeCheck size={20} /> : <Clock size={20} />}
            </div>
            <h3 className="font-semibold leading-snug">{c.name}</h3>
            {c.code && <p className="text-xs font-mono text-muted">{c.code}</p>}
            <span
              className={`mt-auto text-xs font-mono inline-flex w-fit rounded-full px-2.5 py-1 ${
                c.status === 'Certified' ? 'bg-accent/15 text-accent' : 'bg-white/5 text-muted'
              }`}
            >
              {c.status}
            </span>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
