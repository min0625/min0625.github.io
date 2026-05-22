import { execSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const args = process.argv.slice(2);
const targetFile = args[0];
if (!targetFile) {
  console.error('Usage: bun ./scripts/inject-build-info.js <path-to-html>');
  process.exit(1);
}

const buildTime = new Date().toISOString();
let gitHash = '';
try {
  gitHash = execSync('git rev-parse --short HEAD', { encoding: 'utf8' }).trim();
} catch {
  gitHash = 'unknown';
}

let version = '';
try {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const packageJsonPath = path.resolve(__dirname, '../package.json');
  const pkg = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
  version = pkg.version || '';
} catch {
  version = '';
}

const html = readFileSync(targetFile, 'utf8');
const infoLines = [
  `<meta name="build-time" content="${buildTime}">`,
  `<meta name="build-git-hash" content="${gitHash}">`,
  version ? `<meta name="build-version" content="${version}">` : null,
]
  .filter(Boolean)
  .join('\n  ');

const headClose = '</head>';
if (!html.includes(headClose)) {
  console.error('Expected </head> in HTML file:', targetFile);
  process.exit(1);
}

const output = html.replace(headClose, `  ${infoLines}\n${headClose}`);
writeFileSync(targetFile, output, 'utf8');
