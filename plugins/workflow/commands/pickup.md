---
description: Pick up work from the latest handoff doc — re-orient against the saved state and continue from the documented next step
argument-hint: "[handoff-file-or-slug]"
allowed-tools: [Bash, Read]
disable-model-invocation: true
---

Pick up work from a handoff written by `/handoff`. Re-orient against the saved
state, sanity-check the working tree, and continue from the documented next step.

Argument: `$ARGUMENTS` — optional handoff filename or slug. If absent, use the
**most recent** file in `.handoffs/`.

**Steps:**

1. **Locate the handoff.**
   ```bash
   ROOT=$(git rev-parse --show-toplevel)
   ls -1t "$ROOT/.handoffs"/*.md 2>/dev/null | head -5
   ```
   - If an arg was given, match it by filename/slug substring.
   - Else take the newest. If none exist: STOP. "No handoffs found in
     `.handoffs/`. Start one with `/handoff`."

2. **Read it fully** (`Read` the chosen file). This is the source of truth for
   intent and next steps.

3. **Reconcile with reality** — the repo may have moved since the handoff:
   ```bash
   git branch --show-current
   git status --short
   DEFAULT=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'); DEFAULT=${DEFAULT:-main}
   git fetch origin --quiet
   git log --oneline origin/$DEFAULT..HEAD
   ```
   - Flag mismatches: wrong branch/worktree, commits that landed since, files
     that changed. If the handoff says work was on a branch you're not on, tell
     the user how to get there (`cd` to the worktree, or `/git-worktree`).

4. **Quick green-start check** (optional but recommended): if the handoff names a
   verify command (e.g. `mise run ci`), offer to run it — or at least a fast
   subset (build/lint) — so you start from a known-good baseline rather than
   inheriting a hidden break.

5. **Re-orient and propose the next action.** Summarize in a few lines: the goal,
   what's done, and the **single next concrete step** from the handoff's "Next
   steps". Then ask to proceed (or just proceed if it's unambiguous and safe).

**Output:**
```
Picking up: <slug>  (<handoff date>)

State check:
  • branch <branch> (matches handoff)  |  ⚠ <mismatch + how to fix>
  • <N> unshipped commits · <M> uncommitted
  • verify: <green | not run>

Goal: <one line>
Next: <the next concrete step>

→ proceed?
```

**Notes:**
- Treat the handoff as intent, the git state as truth — when they disagree,
  surface it instead of blindly following the doc.
- After finishing the resumed work, land it with `/git-ship` (and consider a
  fresh `/handoff` if you're stopping mid-stream again).
