import { motion } from 'framer-motion';
import SectionHeading from './SectionHeading.jsx';

const STAGES = [
  { label: 'GitHub Actions', hint: 'OIDC — zero static keys' },
  { label: 'Terraform', hint: 'Plan → apply, modular by env' },
  { label: 'AWS', hint: 'us-east-1' },
  { label: 'VPC', hint: '3-tier network isolation' },
  { label: 'ALB', hint: 'TLS termination + routing' },
  { label: 'ECS / EKS', hint: 'Fargate + Karpenter autoscaling' },
  { label: 'RDS', hint: 'Multi-AZ Postgres' },
  { label: 'CloudWatch', hint: 'Metrics + logs' },
  { label: 'SNS', hint: 'Alerting' },
  { label: 'AI Incident Analysis', hint: 'Bedrock-generated RCA' },
];

export default function Architecture() {
  return (
    <section id="architecture" className="section">
      <SectionHeading
        eyebrow="Cloud Architecture"
        title="From commit to a self-diagnosing production system"
        description="A simplified view of how a change moves from a pull request to running, observed, and self-analyzing infrastructure."
      />

      <div className="card p-6 sm:p-10 overflow-x-auto">
        <div className="flex md:flex-col gap-3 min-w-[640px] md:min-w-0">
          {STAGES.map((s, i) => (
            <div key={s.label} className="flex md:flex-row flex-col items-center md:items-stretch gap-3">
              <motion.div
                initial={{ opacity: 0, x: -12 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: '-40px' }}
                transition={{ delay: i * 0.05, duration: 0.4 }}
                whileHover={{ scale: 1.02 }}
                className="flex-1 flex items-center justify-between gap-4 rounded-xl border border-border bg-white/[0.03] px-5 py-3.5 hover:border-accent/40 transition-colors"
              >
                <span className="font-mono text-sm text-white">{s.label}</span>
                <span className="text-xs text-muted hidden sm:inline">{s.hint}</span>
              </motion.div>
              {i < STAGES.length - 1 && (
                <div className="flex justify-center md:py-0">
                  <div className="h-4 w-px md:h-4 md:w-px bg-border" aria-hidden="true" />
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
