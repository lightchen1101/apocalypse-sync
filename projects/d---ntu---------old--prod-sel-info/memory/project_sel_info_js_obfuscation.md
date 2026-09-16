---
name: project-sel-info-js-obfuscation
description: sel-info js/main.js build/obfuscation pipeline setup and git history rewrite done 2026-07-17
metadata: 
  node_type: memory
  type: project
  originSessionId: 7176a53a-101f-43a4-a8cd-cc17169dee73
---

This repo (`sel-info`, NTU 教務處選課系統首頁, GitLab `acaif/sel-info`) has a build pipeline so `js/main.js` (readable source) never ships — only the obfuscated `js/main.min.js` does.

**Setup (as of 2026-07-17):**
- `scripts/build-js.js` obfuscates `js/main.js` (javascript-obfuscator, `medium-obfuscation` preset) into `js/main.min.js`, hashes the output (md5, 8 chars), and rewrites the `<script src="js/main.min.js?v=...">` tag in `index.html`.
- `.vscode/tasks.json` auto-starts `npm run watch:js` (chokidar) on folder open, so saving `js/main.js` rebuilds automatically.
- `.git/hooks/pre-commit` (local only, not tracked by git) rebuilds unconditionally before every commit as a safety net.
- `js/main.js` is gitignored and untracked — it lives only on the user's local disk, intentionally never pushed. This was a deliberate ask (user doesn't want the readable JS logic visible to anyone with repo access).
- `main` branch was protected against force-push; user got that permission enabled via GitLab project settings, at which point full git history was rewritten with `git-filter-repo` to strip `js/main.js`, `_dev/js/main.js`, and `new/js/main.js` (old renamed path) from every past commit, then force-pushed.
- User is the **sole maintainer/clone** of this repo, which is why force-push history rewriting was judged safe here — this would not be safe in a multi-clone repo.
- `_dev/` was a duplicate on-server "dev" subfolder (no real dev environment existed) kept manually in sync with root; it has since been deleted by the user.
- CI (`.gitlab-ci.yml` → Jenkins) deploys by copying files directly, no build step — so `js/main.min.js` must always be committed as a build artifact, it's not generated at deploy time.

See [[feedback-commit-no-coauthor]] for a related commit-message preference learned during this same work.
