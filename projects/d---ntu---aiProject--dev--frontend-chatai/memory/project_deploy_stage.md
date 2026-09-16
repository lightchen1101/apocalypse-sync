---
name: project-deploy-stage
description: "chatai frontend/backend repos have no dev branch — main IS the dev stage, system not yet publicly launched"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8198ec2c-9f3d-46c5-869d-f46e09071516
---

The `chatai` frontend repo (git.aca.ntu.edu.tw/acaif/chatai) has only `main`, `cody`, and `gh-pages` branches — no separate `dev` branch. [.gitlab-ci.yml](.gitlab-ci.yml) only triggers on `main`, building and deploying straight through (labelled `deploy-to-prod` stage in CI, but see below).

As of 2026-07-30, the user (lightchen) confirmed: **main currently serves as the dev environment** — the system has **not been officially launched / opened to the public yet**, despite the CI stage being named `deploy-to-prod`.

**Why this matters:** Pushes/merges to `main` go live on the deployed server immediately (no staging gate), but since there are no real end users yet, the blast radius of a bad push is lower than the "prod" naming suggests. Still worth normal care (build/type-check before pushing), but this isn't yet a live-traffic production system — don't apply maximum-caution prod-deploy protocol assuming real users are affected.

**How to apply:** When advising on git workflow, PR strategy, or deployment risk for this project, don't assume a dev/staging branch exists or that merges to main immediately affect real users. If the system later launches publicly, this memory should be updated/removed.

Related: [[chatai_backend_deploy]] (if a similar note is written for the chatai_backend repo — check before assuming the same applies there, as it's a separate git repo).
