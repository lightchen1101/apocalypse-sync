---
name: project-local-dev-only
description: "Course-select-redesign repo is now private; work locally only, don't push/deploy until demo hosting location is finalized"
metadata: 
  node_type: memory
  type: project
  originSessionId: a3e70dab-d008-410c-a4cc-b0d2095c7391
---

As of 2026-07-21, the repo (`lightchen1101/course-select-redeisgn`) was switched to private, which broke the GitHub Pages demo (free plan doesn't support Pages on private repos — deploy job fails with 404, confirmed via Actions logs). User explicitly chose to keep the repo private rather than revert to public.

User then said: "目前先在本機開發就好 demo位置會在異動" — for now, develop locally only; the demo hosting location is going to change/move.

Follow-up, more explicit: "repo 的部分改成不需要幫我自動發佈,都由我手動commit pr" — stop doing git operations (commit, push, PR) on this repo entirely. The user will commit and open PRs themselves manually (they use the Fork GUI app locally).

**Why:** Demo site location is in flux (moving away from GitHub Pages on this repo, destination not yet decided as of this note), and the user wants full manual control over what lands in git history.

**How to apply:** Edit files as requested, run local verification (build/sass/Playwright) as needed, but do NOT run `git commit`, `git push`, or create PRs/branches on this repo unless the user explicitly asks again. Leave changes uncommitted in the working tree and just summarize what changed so the user can review and commit themselves. Don't assume the old `https://lightchen1101.github.io/course-select-redeisgn/` URL is still the target. If commit conventions ever come up again, see [[feedback_no_co_authored_by]].
