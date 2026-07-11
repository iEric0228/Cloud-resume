import { useEffect, useState } from 'react';
import { Github, Linkedin, Menu, X } from 'lucide-react';
import { profile } from '../data/profile.js';

const LINKS = [
  { href: '#projects', label: 'Projects' },
  { href: '#stack', label: 'Stack' },
  { href: '#experience', label: 'Experience' },
  { href: '#contact', label: 'Contact' },
];

export default function Nav() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <header
      className={`fixed top-0 inset-x-0 z-50 transition-all duration-300 ${
        scrolled ? 'bg-bg/80 backdrop-blur-lg border-b border-border' : 'bg-transparent'
      }`}
    >
      <div className="max-w-content mx-auto px-6 sm:px-8 h-16 flex items-center justify-between">
        <a href="#top" className="flex items-center gap-2 font-semibold tracking-tight text-white">
          <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-accent/15 text-accent font-mono text-sm">
            EC
          </span>
          <span className="hidden sm:inline">Eric Chiu</span>
        </a>

        <nav className="hidden md:flex items-center gap-8 text-sm text-muted">
          {LINKS.map((l) => (
            <a key={l.href} href={l.href} className="hover:text-white transition-colors">
              {l.label}
            </a>
          ))}
          <a href={profile.resumeUrl} target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">
            Résumé
          </a>
        </nav>

        <div className="hidden md:flex items-center gap-3">
          <a href={profile.github} target="_blank" rel="noopener noreferrer" aria-label="GitHub" className="text-muted hover:text-white transition-colors">
            <Github size={18} />
          </a>
          <a href={profile.linkedin} target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="text-muted hover:text-white transition-colors">
            <Linkedin size={18} />
          </a>
          <a href="#contact" className="btn-primary text-sm py-2">
            Contact
          </a>
        </div>

        <button
          className="md:hidden text-white"
          onClick={() => setOpen((o) => !o)}
          aria-label="Toggle menu"
          aria-expanded={open}
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {open && (
        <div className="md:hidden border-t border-border bg-bg/95 backdrop-blur-lg px-6 py-4 flex flex-col gap-4 text-sm">
          {LINKS.map((l) => (
            <a key={l.href} href={l.href} className="text-muted hover:text-white" onClick={() => setOpen(false)}>
              {l.label}
            </a>
          ))}
          <a href={profile.resumeUrl} target="_blank" rel="noopener noreferrer" className="text-muted hover:text-white">
            Résumé
          </a>
        </div>
      )}
    </header>
  );
}
