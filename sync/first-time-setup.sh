#!/usr/bin/env bash
# First-time setup for a new machine joining Claude Code conversation-history sync.
# Safely handles the case where this machine already has its own pre-existing
# ~/.claude/projects data (e.g. memory/*.md for a project path also used elsewhere)
# by backing up any conflicting local files before pulling in the shared history.
set -uo pipefail
CLAUDE_DIR="$HOME/.claude"
cd "$CLAUDE_DIR"

if [ ! -d .git ]; then
  git init
fi
if ! git remote | grep -q '^origin$'; then
  git remote add origin https://github.com/lightchen1101/apocalypse-sync.git
fi

git fetch origin || { echo "git fetch failed" >&2; exit 1; }

if git rev-parse --verify main >/dev/null 2>&1; then
  echo "Branch 'main' already exists -- setup already done on this machine. Use sync.sh instead."
  exit 0
fi

err_file=$(mktemp)
git checkout -b main origin/main 2>"$err_file"
status=$?

if [ $status -ne 0 ]; then
  conflicts=$(grep -E '^[[:space:]]+projects/' "$err_file" | sed 's/^[[:space:]]*//')
  if [ -z "$conflicts" ]; then
    echo "git checkout failed for a reason other than file conflicts:" >&2
    cat "$err_file" >&2
    rm -f "$err_file"
    exit 1
  fi
  echo "Found pre-existing local file(s) that collide with the synced history. Backing them up:"
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    full="$CLAUDE_DIR/$rel"
    [ -f "$full" ] || continue
    dir=$(dirname "$full")
    base=$(basename "$full")
    name="${base%.*}"
    ext="${base##*.}"
    backup="$dir/$name.pre-sync-backup.$ext"
    mv "$full" "$backup"
    echo "  $rel -> $(basename "$backup")"
  done <<< "$conflicts"
  rm -f "$err_file"
  git checkout -b main origin/main || { echo "git checkout still failed after backing up conflicts" >&2; exit 1; }
else
  rm -f "$err_file"
fi

node "$CLAUDE_DIR/sync/redact-secrets.mjs"

git add .gitignore projects sync
if git diff --cached --quiet; then
  echo "Nothing new to add from this machine."
else
  git commit -m "sync: add this machine's existing history"
  git push origin main
fi

echo
echo "Done. If any *.pre-sync-backup files were created, review them and manually merge"
echo "anything worth keeping into the corresponding memory/*.md file, then delete the backup."
