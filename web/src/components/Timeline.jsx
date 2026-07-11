import { motion, useScroll, useTransform } from 'framer-motion';
import { GraduationCap, Briefcase } from 'lucide-react';
import { useRef } from 'react';
import SectionHeading from './SectionHeading.jsx';
import { timeline, transferableSkills } from '../data/stack.js';

export default function Timeline() {
  const trackRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: trackRef,
    offset: ['start 85%', 'end 65%'],
  });
  const lineHeight = useTransform(scrollYProgress, [0, 1], ['0%', '100%']);

  return (
    <section id="experience" className="section">
      <SectionHeading
        eyebrow="Experience"
        title="Education, and years of live-operations leadership"
        description="Before infrastructure, I ran real-time operations — the instincts transfer directly to incident response and on-call work."
      />

      <div ref={trackRef} className="relative pl-8 sm:pl-10">
        <div className="absolute left-[7px] sm:left-[9px] top-1 bottom-1 w-px bg-border" aria-hidden="true" />
        <motion.div
          style={{ height: lineHeight }}
          className="absolute left-[7px] sm:left-[9px] top-1 w-px bg-accent shadow-glow origin-top"
          aria-hidden="true"
        />
        <div className="space-y-10">
          {timeline.map((entry, i) => (
            <motion.div
              key={entry.title + entry.org}
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-60px' }}
              transition={{ delay: i * 0.08, duration: 0.5 }}
              className="relative"
            >
              <span className="absolute -left-8 sm:-left-10 top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-accent ring-4 ring-bg" aria-hidden="true" />
              <div className="flex items-center gap-2 text-xs font-mono text-muted mb-1.5">
                {entry.type === 'education' ? <GraduationCap size={14} /> : <Briefcase size={14} />}
                {entry.date}
              </div>
              <h3 className="font-semibold text-white">{entry.title}</h3>
              <p className="text-sm text-accent">{entry.org}</p>
              {entry.points.length > 0 && (
                <ul className="mt-2 space-y-1.5">
                  {entry.points.map((p) => (
                    <li key={p} className="text-sm text-muted flex gap-2 leading-relaxed">
                      <span className="text-accent">–</span>
                      {p}
                    </li>
                  ))}
                </ul>
              )}
            </motion.div>
          ))}
        </div>
      </div>

      <div className="mt-10 flex flex-wrap gap-2">
        {transferableSkills.map((s) => (
          <span key={s} className="badge">
            {s}
          </span>
        ))}
      </div>
    </section>
  );
}
