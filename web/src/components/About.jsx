import { motion } from 'framer-motion';
import { Award, GraduationCap } from 'lucide-react';
import { profile } from '../data/profile.js';

const FACTS = [
  { icon: Award, label: 'AWS Certified Solutions Architect – Associate' },
  { icon: Award, label: 'AWS Certified Cloud Practitioner' },
  { icon: GraduationCap, label: 'B.S. Computer Engineering' },
];

export default function About() {
  return (
    <section id="about" className="section">
      <div className="grid md:grid-cols-[1fr_1fr] gap-12 items-start">
        <div>
          <p className="eyebrow mb-3">About</p>
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight mb-5">Focused on reliability, not just uptime.</h2>
          <p className="text-muted leading-relaxed">{profile.about}</p>
        </div>

        <div className="grid gap-3">
          {FACTS.map((f, i) => (
            <motion.div
              key={f.label}
              initial={{ opacity: 0, x: 16 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true, margin: '-60px' }}
              transition={{ delay: i * 0.08, duration: 0.5 }}
              className="card card-hover flex items-center gap-3 px-5 py-4"
            >
              <f.icon size={18} className="text-accent shrink-0" />
              <span className="text-sm text-white/90">{f.label}</span>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
