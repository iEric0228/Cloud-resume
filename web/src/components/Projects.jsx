import SectionHeading from './SectionHeading.jsx';
import ProjectCard from './ProjectCard.jsx';
import { projects } from '../data/projects.js';

export default function Projects() {
  return (
    <section id="projects" className="section">
      <SectionHeading
        eyebrow="Featured Projects"
        title="Production-style AWS infrastructure, built end to end"
        description="Each one starts from a real operational problem — not a tutorial. Infrastructure as code, CI/CD, and cost/security tradeoffs made deliberately."
      />
      <div className="grid md:grid-cols-2 gap-6">
        {projects.map((p, i) => (
          <ProjectCard key={p.title} project={p} index={i} />
        ))}
      </div>
    </section>
  );
}
