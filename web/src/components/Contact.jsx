import { useState } from 'react';
import { motion } from 'framer-motion';
import { Mail, Github, Linkedin, Globe, Send } from 'lucide-react';
import { profile } from '../data/profile.js';

const LINKS = [
  { icon: Mail, label: profile.email, href: `mailto:${profile.email}` },
  { icon: Github, label: 'github.com/iEric0228', href: profile.github },
  { icon: Linkedin, label: 'linkedin.com/in/eric-chiu', href: profile.linkedin },
  { icon: Globe, label: 'ericchiu.page', href: profile.portfolio },
];

export default function Contact() {
  const [form, setForm] = useState({ name: '', email: '', message: '' });

  // No backend exists for this form, so submitting opens the visitor's mail
  // client with the message pre-filled — honest behavior instead of a fake
  // "message sent" confirmation with nowhere for it to go.
  const handleSubmit = (e) => {
    e.preventDefault();
    const subject = encodeURIComponent(`Portfolio contact from ${form.name || 'a visitor'}`);
    const body = encodeURIComponent(`${form.message}\n\n— ${form.name} (${form.email})`);
    window.location.href = `mailto:${profile.email}?subject=${subject}&body=${body}`;
  };

  return (
    <section id="contact" className="section">
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-80px' }}
        transition={{ duration: 0.5 }}
        className="text-center max-w-xl mx-auto mb-14"
      >
        <p className="eyebrow mb-3">Contact</p>
        <h2 className="text-3xl sm:text-4xl font-bold tracking-tight">Let&rsquo;s connect.</h2>
        <p className="mt-4 text-muted">
          Open to Cloud, DevOps, SRE, and Support Engineering roles. The fastest way to reach me is email.
        </p>
      </motion.div>

      <div className="grid md:grid-cols-[1fr_1.2fr] gap-6 max-w-3xl mx-auto">
        <div className="grid gap-3">
          {LINKS.map((l) => (
            <a
              key={l.label}
              href={l.href}
              target={l.href.startsWith('mailto:') ? undefined : '_blank'}
              rel="noopener noreferrer"
              className="card card-hover flex items-center gap-3 px-5 py-4 text-sm"
            >
              <l.icon size={16} className="text-accent shrink-0" />
              <span className="text-white/90 truncate">{l.label}</span>
            </a>
          ))}
        </div>

        <form onSubmit={handleSubmit} className="card p-6 grid gap-4">
          <div className="grid sm:grid-cols-2 gap-4">
            <input
              required
              type="text"
              placeholder="Name"
              value={form.name}
              onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
              className="rounded-lg bg-white/5 border border-border px-4 py-2.5 text-sm outline-none focus:border-accent/50 transition-colors placeholder:text-muted"
            />
            <input
              required
              type="email"
              placeholder="Email"
              value={form.email}
              onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
              className="rounded-lg bg-white/5 border border-border px-4 py-2.5 text-sm outline-none focus:border-accent/50 transition-colors placeholder:text-muted"
            />
          </div>
          <textarea
            required
            rows={4}
            placeholder="Message"
            value={form.message}
            onChange={(e) => setForm((f) => ({ ...f, message: e.target.value }))}
            className="rounded-lg bg-white/5 border border-border px-4 py-2.5 text-sm outline-none focus:border-accent/50 transition-colors resize-none placeholder:text-muted"
          />
          <button type="submit" className="btn-primary justify-center">
            Send <Send size={15} />
          </button>
        </form>
      </div>
    </section>
  );
}
