---
description: 'Create a fresh worktree from the latest main (replaces feature branches). Differentiator: worktree flow, not feature branches — /git-start from the devproc git plugin is the alternative, and the two should not both be enabled.'
argument-hint: "<name>"
allowed-tools: [Bash]
---

Create a new git worktree branched off the **latest** default branch, so you can
start a task in an isolated working directory without disturbing other worktrees.
This replaces the old `feature/` branch flow.

Argument: `$ARGUMENTS` — the worktree/branch name (required; e.g. `auth-refactor`).
Slugify it (lowercase, hyphens) for both the branch and the directory.

**Steps:**

1. **Validate.** If no name given: STOP. "Usage: `/git-worktree <name>`".

2. **Detect default branch and repo root.**
   ```bash
   ROOT=$(git rev-parse --show-toplevel)
   DEFAULT=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   DEFAULT=${DEFAULT:-main}
   ```

3. **Fetch so the worktree starts current.**
   ```bash
   git fetch origin
   ```

4. **Worktree location.** Worktrees live under `$ROOT/.claude/worktrees/` — the
   same convention Claude Code's built-in worktrees use. This path is already
   excluded via `.git/info/exclude` (`**/.claude/worktrees/`), so no `.gitignore`
   edit is needed. If for some reason it isn't ignored, add `**/.claude/worktrees/`
   to `$ROOT/.git/info/exclude`.

5. **Create the worktree off the fresh default branch.**
   ```bash
   git worktree add "$ROOT/.claude/worktrees/<name>" -b <name> origin/$DEFAULT
   ```
   - If the branch already exists, either reuse it
     (`git worktree add "$ROOT/.claude/worktrees/<name>" <name>`) or pick a new
     name — ask which.

6. **Report** the new worktree path and remind the user to `cd` into it. When the
   work is done, land it with `/git-ship`.

**Output:**
```
Worktree ready ✓
  path:   <root>/.claude/worktrees/<name>
  branch: <name>  (from origin/$DEFAULT @ <sha>)

→ cd <root>/.claude/worktrees/<name>
→ when done: /git-ship
```

**Notes:**
- Each worktree is an independent checkout sharing one `.git` — ideal for running
  parallel tasks (or parallel agents) without branch-switch churn.
- Branching from `origin/$DEFAULT` (not local `$DEFAULT`) guarantees you start on
  the latest even if your local default is stale.
