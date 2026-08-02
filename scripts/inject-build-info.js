import { execSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import process from 'node:process';

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

const html = readFileSync(targetFile, 'utf8');
const infoLines = [
  `<meta name="build-time" content="${buildTime}">`,
  `<meta name="build-git-hash" content="${gitHash}">`,
].join('\n    ');

const headClose = '</head>';
if (!html.includes(headClose)) {
  console.error('Expected </head> in HTML file:', targetFile);
  process.exit(1);
}

// `</head>` is already indented 2 spaces in the source; align the metas to 4.
const output = html.replace(headClose, `  ${infoLines}\n  ${headClose}`);
writeFileSync(targetFile, output, 'utf8');
