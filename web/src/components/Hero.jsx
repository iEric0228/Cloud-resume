import { motion } from 'framer-motion';
import { Download, Github, Linkedin, Mail, ArrowRight } from 'lucide-react';
import { profile } from '../data/profile.js';
import Magnetic from './Magnetic.jsx';
import Stats from './Stats.jsx';
import { handleSpotlightMove } from '../utils/spotlight.js';

const NODES = ['AWS', 'Terraform', 'Docker', 'Kubernetes', 'CI/CD'];

const fadeUp = {
  hidden: { opacity: 0, y: 16 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { delay: 0.08 * i, duration: 0.6, ease: [0.16, 1, 0.3, 1] },
  }),
};

export default function Hero() {
  return (
    <section id="top" className="relative overflow-hidden pt-40 pb-24 sm:pt-48 sm:pb-32">
      <div className="max-w-content mx-auto px-6 sm:px-8 grid md:grid-cols-[1.1fr_0.9fr] gap-16 items-center">
        <div>
          <motion.p initial="hidden" animate="visible" variants={fadeUp} custom={0} className="eyebrow mb-5">
            Available for new opportunities
          </motion.p>

          <motion.h1
            initial="hidden"
            animate="visible"
            variants={fadeUp}
            custom={1}
            className="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight leading-[1.08]"
          >
            Hi, I&rsquo;m {profile.name}.
            <br />
            <span className="text-muted">{profile.role}</span>
          </motion.h1>

          <motion.p
            initial="hidden"
            animate="visible"
            variants={fadeUp}
            custom={2}
            className="mt-6 text-lg text-muted max-w-xl leading-relaxed"
          >
            {profile.statement}
          </motion.p>

          <motion.div initial="hidden" animate="visible" variants={fadeUp} custom={3} className="mt-9 flex flex-wrap items-center gap-3">
            <Magnetic strength={0.3}>
              <a href="#projects" className="btn-primary">
                View Projects <ArrowRight size={16} />
              </a>
            </Magnetic>
            <Magnetic strength={0.3}>
              <a href={profile.resumeUrl} target="_blank" rel="noopener noreferrer" className="btn-secondary">
                <Download size={16} /> Download Resume
              </a>
            </Magnetic>
          </motion.div>

          <motion.div initial="hidden" animate="visible" variants={fadeUp} custom={4} className="mt-8 flex items-center gap-5 text-muted">
            <a href={profile.github} target="_blank" rel="noopener noreferrer" aria-label="GitHub" className="hover:text-white transition-colors">
              <Github size={20} />
            </a>
            <a href={profile.linkedin} target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="hover:text-white transition-colors">
              <Linkedin size={20} />
            </a>
            <a href={`mailto:${profile.email}`} aria-label="Email" className="hover:text-white transition-colors">
              <Mail size={20} />
            </a>
          </motion.div>

          <Stats />
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.94 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1], delay: 0.15 }}
          className="relative mx-auto w-full max-w-sm aspect-square"
        >
          <div className="absolute inset-0 rounded-full bg-accent/10 blur-3xl" aria-hidden="true" />
          <div
            onMouseMove={handleSpotlightMove}
            className="spotlight relative h-full w-full rounded-2xl card p-8 flex items-center justify-center"
          >
            <div className="grid grid-cols-2 gap-4 w-full">
              {NODES.map((n, i) => (
                <motion.div
                  key={n}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3 + i * 0.08, duration: 0.5 }}
                  whileHover={{ y: -3 }}
                  className={`rounded-xl border border-border bg-white/[0.03] px-4 py-4 text-center font-mono text-sm text-muted hover:text-white hover:border-accent/40 transition-colors ${
                    i === NODES.length - 1 ? 'col-span-2' : ''
                  }`}
                >
                  {n}
                </motion.div>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
