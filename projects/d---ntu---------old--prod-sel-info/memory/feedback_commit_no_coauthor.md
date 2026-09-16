---
name: feedback-commit-no-coauthor
description: Do not add the Co-Authored-By Claude trailer to commits in this repo
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7176a53a-101f-43a4-a8cd-cc17169dee73
---

Do not include the `Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>` trailer in commit messages for this repo.

**Why:** User explicitly asked to remove it after two commits went out with it — this repo (`sel-info`, NTU course-selection info site) is a solo-maintained internal project and the user doesn't want AI-authorship trailers in the history.

**How to apply:** When drafting commit messages for this project, omit the Co-Authored-By trailer entirely, even though the default git workflow instructions suggest adding one. If commits already pushed contain the trailer and the user wants them cleaned, `git-filter-repo --message-callback` can strip it (already done once via history rewrite — see [[project_sel_info_js_obfuscation]] for that incident and why force-push was viable here).
