---
description: Worktree-aware repository status with next-step suggestions
allowed-tools: [Bash]
---

Show a concise, worktree-aware snapshot of the repository: where you are, how the
current work compares to `main`, and what every worktree is doing.

**Steps:**

1. **Detect default branch + current location.**
   ```bash
   DEFAULT=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   DEFAULT=${DEFAULT:-main}
   git fetch origin --quiet
   CURRENT=$(git branch --show-current)
   ```

2. **Current worktree state.**
   ```bash
   git status --short
   git rev-list --count origin/$DEFAULT..HEAD   # ahead of main
   git rev-list --count HEAD..origin/$DEFAULT   # behind main
   git log --oneline origin/$DEFAULT..HEAD      # this worktree's unshipped commits
   ```

3. **All worktrees.** For each, show path, branch, dirty/clean, and ahead/behind
   `origin/$DEFAULT`:
   ```bash
   git worktree list --porcelain
   ```

4. **Stashes.** `git stash list`

5. **Recommend a next step** based on what you found (see logic below).

**Output:**
```
Repository: <repo>   default: $DEFAULT

This worktree: <path>
  branch:  <CURRENT>
  vs $DEFAULT:  N ahead · M behind
  working:  <X modified, Y staged, Z untracked  |  clean>
  unshipped:
    - abc1234 <subject>
    - def5678 <subject>

Worktrees:
  • <path>  <branch>  <clean|●dirty>  <ahead/behind main>
  • ...

Stashes: <n>

Next:
  <one targeted recommendation>
```

**Recommendation logic** (pick the first that applies):
- Uncommitted changes → `→ /git-checkpoint "<desc>"` (or `/git-ship "<desc>"` to land directly).
- Clean + ahead of `$DEFAULT` → `→ /git-ship` to land this work on $DEFAULT.
- Behind `$DEFAULT` (on a feature worktree) → `→ /git-sync` then rebase.
- On `$DEFAULT` and behind origin → `→ /git-sync` to fast-forward.
- Fully clean and in sync → `→ /git-worktree <name>` to start something new.

**Notes:**
- Read-only: this command never changes state.
- "Unshipped" = commits on this worktree not yet on `origin/$DEFAULT`.
