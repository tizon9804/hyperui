import { readFileSync } from 'node:fs';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vite.dev/config/ · https://vitest.dev/config/
const pkg = JSON.parse(readFileSync(new URL('./package.json', import.meta.url), 'utf8'));
const commit = (
  process.env.CF_PAGES_COMMIT_SHA || process.env.VERCEL_GIT_COMMIT_SHA || process.env.COMMIT_REF ||
  process.env.GITHUB_SHA || process.env.AWS_COMMIT_ID || 'local'
).slice(0, 7);

// Version stamp: the version comes from package.json at build time, never typed into the UI.
function versionStamp() {
  return {
    name: 'version-stamp',
    transformIndexHtml(html) {
      return html.replace('</head>', `  <meta name="app-version" content="${pkg.version}+${commit}" />\n  </head>`);
    },
    generateBundle() {
      this.emitFile({
        type: 'asset',
        fileName: 'version.json',
        source: JSON.stringify({ version: pkg.version, commit, builtAt: new Date().toISOString() }),
      });
    },
  };
}

export default defineConfig({
  plugins: [react(), versionStamp()],
  define: { __APP_VERSION__: JSON.stringify(pkg.version), __COMMIT__: JSON.stringify(commit) },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.js',
  },
});
