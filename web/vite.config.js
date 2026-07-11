import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Builds into ../frontend so the existing deploy pipeline (scripts/publish-frontend.sh,
// Terraform S3 sync) keeps working unchanged — it just syncs whatever is in frontend/.
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5000,
    allowedHosts: true,
  },
  build: {
    outDir: '../frontend',
    emptyOutDir: true,
  },
});
