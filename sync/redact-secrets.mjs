#!/usr/bin/env node
// Scans Claude Code conversation history (.jsonl / .txt under projects/) for
// common secret patterns and redacts them in place before they get committed.
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join, extname } from "node:path";

const root =
  process.argv[2] ||
  join(process.env.USERPROFILE || process.env.HOME, ".claude", "projects");

const fullRedact = (name) => () => `[REDACTED:${name}]`;

const PATTERNS = [
  { name: "anthropic-api-key", re: /sk-ant-[a-zA-Z0-9_-]{20,}/g, redact: fullRedact("anthropic-api-key") },
  { name: "openai-api-key", re: /sk-(?:proj-)?[A-Za-z0-9_-]{20,}/g, redact: fullRedact("openai-api-key") },
  { name: "gcp-api-key", re: /AIza[0-9A-Za-z_-]{35}/g, redact: fullRedact("gcp-api-key") },
  { name: "gemini-api-key", re: /AQ\.[A-Za-z0-9_-]{20,}/g, redact: fullRedact("gemini-api-key") },
  { name: "connection-string-password", re: /(PWD|PASSWORD)=([^;"'\s\\[\]]{6,})/gi, redact: (_m, p1) => `${p1}=[REDACTED:connection-string-password]` },
  { name: "private-key-block", re: /-----BEGIN (?:RSA |EC |)PRIVATE KEY-----[\s\S]*?-----END (?:RSA |EC |)PRIVATE KEY-----/g, redact: fullRedact("private-key") },
  { name: "aws-access-key-id", re: /AKIA[0-9A-Z]{16}/g, redact: fullRedact("aws-access-key-id") },
  { name: "github-token", re: /gh[pousr]_[A-Za-z0-9]{36,}/g, redact: fullRedact("github-token") },
  { name: "slack-token", re: /xox[baprs]-[A-Za-z0-9-]{10,}/g, redact: fullRedact("slack-token") },
  { name: "google-oauth-client-secret", re: /GOCSPX-[A-Za-z0-9_-]{20,}/g, redact: fullRedact("google-oauth-secret") },
  { name: "stripe-key", re: /(?:sk|pk)_live_[A-Za-z0-9]{20,}/g, redact: fullRedact("stripe-key") },
  { name: "bearer-token", re: /(Bearer\s+)[A-Za-z0-9\-_.~+/]{20,}=*/g, redact: (_m, p1) => `${p1}[REDACTED:bearer-token]` },
  {
    name: "assigned-secret",
    re: /("(?:api[_-]?key|apikey|access[_-]?token|secret[_-]?key|client[_-]?secret|password)"\s*:\s*")([^"\\[]{8,})(")/gi,
    redact: (_m, p1, _p2, p3) => `${p1}[REDACTED:assigned-secret]${p3}`,
  },
];

const SCAN_EXT = new Set([".jsonl", ".txt", ".json", ".md"]);
const SKIP_DIRS = new Set(["node_modules", ".git"]);

function walk(dir, out = []) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (SKIP_DIRS.has(entry.name)) continue;
    const full = join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else if (SCAN_EXT.has(extname(entry.name))) out.push(full);
  }
  return out;
}

let filesChanged = 0;
let totalRedactions = 0;
const report = [];

for (const file of walk(root)) {
  let original;
  try {
    original = readFileSync(file, "utf8");
  } catch {
    continue;
  }
  let content = original;
  const fileReport = [];
  for (const { name, re, redact } of PATTERNS) {
    re.lastIndex = 0;
    const matches = content.match(re);
    if (matches && matches.length) {
      content = content.replace(re, redact);
      fileReport.push({ file, name, count: matches.length });
    }
  }
  // Only write/report if the redaction actually altered the file — patterns can
  // otherwise re-"match" their own already-redacted placeholder text on rescans.
  if (content !== original) {
    writeFileSync(file, content, "utf8");
    filesChanged++;
    for (const entry of fileReport) {
      totalRedactions += entry.count;
      report.push(entry);
    }
  }
}

if (totalRedactions > 0) {
  console.log(`[redact-secrets] Redacted ${totalRedactions} match(es) across ${filesChanged} file(s):`);
  for (const { file, name, count } of report) {
    console.log(`  - ${name} x${count}  ${file}`);
  }
} else {
  console.log("[redact-secrets] No secrets detected.");
}
