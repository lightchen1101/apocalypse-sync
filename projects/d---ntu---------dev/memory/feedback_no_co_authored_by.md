---
name: feedback-no-co-authored-by
description: "Never add a Co-Authored-By Claude/Anthropic line to git commits or PR descriptions, in any project"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a3e70dab-d008-410c-a4cc-b0d2095c7391
---

Do not include a `Co-Authored-By: Claude ...` line (or any other Claude/Anthropic attribution) in git commit messages or PR descriptions.

**Why:** User explicitly asked for this to be removed from all commits/PRs across every project, not just this one.

**How to apply:** This is enforced globally via `~/.claude/CLAUDE.md` (`C:\Users\lightchen\.claude\CLAUDE.md`), which applies to all projects automatically. When drafting any commit message or `gh pr create` body, omit the attribution line entirely — don't just remove it after the fact, don't include it in the first draft.
