---
description: Fast-forward local main to origin and show which worktrees have drifted
allowed-tools: [Bash]
---

Bring your local default branch (`main`) up to date with `origin` after a direct
push, and report which worktrees have fallen behind. This is the answer to "I
pushed to main from a worktree and now my local main is stale."

**Steps:**

1. **Detect the default branch and fetch.**
   ```bash
   DEFAULT=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   DEFAULT=${DEFAULT:-main}
   git fetch origin --prune
   ```

2. **Update the local default branch ref** (without needing to be on it):
   - If you're currently **on** `$DEFAULT`:
     ```bash
     git pull --ff-only origin $DEFAULT
     ```
   - If `$DEFAULT` is **not checked out anywhere**:
     ```bash
     git fetch origin $DEFAULT:$DEFAULT
     ```
   - If `$DEFAULT` is checked out in **another worktree** (the common case — a
     dedicated main worktree), git won't let you move its ref from here. Report
     where it lives (`git worktree list`) and tell the user to run `/git-sync`
     from that worktree, or just `cd` there and `git pull --ff-only`. Do not
     force it.

3. **Show worktree drift.** For every worktree, report branch + how far it is
   ahead/behind `origin/$DEFAULT`:
   ```bash
   git worktree list --porcelain
   # for each worktree's branch B:
   #   behind = git rev-list --count B..origin/$DEFAULT
   #   ahead  = git rev-list --count origin/$DEFAULT..B
   ```

4. **Offer to rebase the current branch** if it's behind `origin/$DEFAULT` and
   you're on a feature worktree (not on `$DEFAULT`): `git rebase origin/$DEFAULT`
   (only if the working tree is clean; otherwise tell the user to commit first).

**Output:**
```
Synced ✓  local $DEFAULT → origin/$DEFAULT (<sha>)

Worktrees:
  • main         $DEFAULT     up to date
  • auth-refactor auth-refactor  3 behind · 2 ahead   → rebase: /git-ship handles this
  • spike         spike         clean, up to date

[if current worktree drifted] → rebase onto latest? (runs git rebase origin/$DEFAULT)
```

**Notes:**
- No pushing here — this command is about pulling the world up to date.
  Landing your own work is `/git-ship`.
- `/git-ship` already rebases onto the latest `$DEFAULT` before pushing, so you
  rarely need to manually rebase a worktree you're actively shipping.
