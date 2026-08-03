import { execSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import process from "node:process";

const args = process.argv.slice(2);
const targetFile = args[0];
if (!targetFile) {
	console.error("Usage: bun ./scripts/inject-build-info.js <path-to-html>");
	process.exit(1);
}

const buildTime = new Date().toISOString();
let gitHash = "";
try {
	gitHash = execSync("git rev-parse --short HEAD", { encoding: "utf8" }).trim();
} catch {
	gitHash = "unknown";
}

const html = readFileSync(targetFile, "utf8");
const infoLines = [
	`<meta name="build-time" content="${buildTime}">`,
	`<meta name="build-git-hash" content="${gitHash}">`,
].join("\n\t\t");

const headClose = "</head>";
if (!html.includes(headClose)) {
	console.error("Expected </head> in HTML file:", targetFile);
	process.exit(1);
}

// The source indents `</head>` with one tab; replace() keeps that tab, so this
// puts the metas at two tabs and restores the tab before `</head>`.
const output = html.replace(headClose, `\t${infoLines}\n\t${headClose}`);
writeFileSync(targetFile, output, "utf8");
