#!/usr/bin/env bash
# Syncs Claude Code conversation history (~/.claude/projects) across machines via git.
# Redacts known secret patterns before every commit.
set -euo pipefail
CLAUDE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CLAUDE_DIR"

node "$CLAUDE_DIR/sync/redact-secrets.mjs"

if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
  git pull origin main --no-edit
fi

git add .gitignore projects sync
if git diff --cached --quiet; then
  echo "Nothing to sync."
  exit 0
fi

git commit -m "sync: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
