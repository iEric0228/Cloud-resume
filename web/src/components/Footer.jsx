import { useVisitorCount } from '../hooks/useVisitorCount.js';

export default function Footer() {
  const { count, status } = useVisitorCount();

  return (
    <footer className="border-t border-border">
      <div className="max-w-content mx-auto px-6 sm:px-8 py-8 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-muted">
        <p>&copy; {new Date().getFullYear()} Eric Chiu. Built with React, Tailwind CSS &amp; Framer Motion.</p>
        <p className="font-mono">
          Visitor #{status === 'ready' ? count.toLocaleString() : status === 'loading' ? '…' : '—'}
        </p>
      </div>
    </footer>
  );
}
