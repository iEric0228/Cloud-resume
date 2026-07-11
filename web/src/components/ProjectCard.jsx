import { motion } from 'framer-motion';
import { Github, ExternalLink, Workflow, ChevronRight } from 'lucide-react';
import { useState } from 'react';
import { handleSpotlightMove } from '../utils/spotlight.js';

export default function ProjectCard({ project, index }) {
  const [open, setOpen] = useState(false);

  return (
    <motion.article
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-60px' }}
      transition={{ delay: (index % 2) * 0.08, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
      onMouseMove={handleSpotlightMove}
      className="spotlight card card-hover p-7 flex flex-col"
    >
      <div className="flex items-start justify-between gap-4">
        <h3 className="text-xl font-semibold tracking-tight">{project.title}</h3>
      </div>
      <p className="mt-2 text-sm text-accent font-mono">{project.tagline}</p>

      <p className="mt-4 text-sm text-muted leading-relaxed">
        <span className="text-white/80 font-medium">Problem: </span>
        {project.problem}
      </p>

      <button
        onClick={() => setOpen((o) => !o)}
        className="mt-4 inline-flex items-center gap-1 text-sm text-muted hover:text-white transition-colors self-start"
        aria-expanded={open}
      >
        <ChevronRight size={14} className={`transition-transform ${open ? 'rotate-90' : ''}`} />
        {open ? 'Hide details' : 'How it works'}
      </button>

      {open && (
        <div className="mt-3 space-y-3">
          <p className="text-sm text-muted leading-relaxed">{project.description}</p>
          <ul className="space-y-1.5">
            {project.highlights.map((h) => (
              <li key={h} className="text-sm text-white/80 flex gap-2">
                <span className="text-accent">–</span>
                {h}
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="mt-5 flex flex-wrap gap-2">
        {project.tech.map((t) => (
          <span key={t} className="badge">
            {t}
          </span>
        ))}
      </div>

      <div className="mt-6 pt-5 border-t border-border flex flex-wrap gap-3">
        {project.github && (
          <a href={project.github} target="_blank" rel="noopener noreferrer" className="btn-secondary text-xs py-2">
            <Github size={14} /> GitHub
          </a>
        )}
        {project.demo && (
          <a href={project.demo} target="_blank" rel="noopener noreferrer" className="btn-secondary text-xs py-2">
            <ExternalLink size={14} /> Live Demo
          </a>
        )}
        {project.architecture && (
          <a href={project.architecture} target="_blank" rel="noopener noreferrer" className="btn-secondary text-xs py-2">
            <Workflow size={14} /> Architecture
          </a>
        )}
      </div>
    </motion.article>
  );
}
