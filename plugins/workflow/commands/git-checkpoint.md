---
description: 'Create a quick checkpoint of current work with all changes. Differentiator: a local work-in-progress commit that stays where it is; /git-ship is what lands work on main.'
argument-hint: [message]
allowed-tools: [Bash]
disable-model-invocation: true
---

Create a quick checkpoint commit with all current changes. Useful for saving work-in-progress before trying something risky or switching context.

**Instructions:**

1. **Check git status**
   ```bash
   git status --short
   ```
   Show user what will be committed

2. **Stage all changes**
   ```bash
   git add -A
   ```
   Stages all modified, new, and deleted files

3. **Create checkpoint commit**
   
   If message provided (`$1`):
   ```bash
   git commit -m "checkpoint: $1"
   ```
   
   If no message provided:
   ```bash
   git commit -m "checkpoint: work in progress"
   ```

4. **Show commit info**
   ```bash
   git log -1 --oneline
   ```

**Output:**
```
Checkpoint Created ✓

Changes committed:
- X files modified
- Y files added
- Z files deleted

Commit: abc1234 checkpoint: $1

This checkpoint can be:
- Reverted with: git reset HEAD~1
- Amended with: git commit --amend
- Landed on main with: /git-ship
```

**Use Cases:**
- Quick save before trying something risky
- End of day - save progress
- Before switching worktrees
- Before pulling changes
- Regular incremental saves during development

**Notes:**
- This creates a real commit (not a stash)
- Prefixed with "checkpoint:" for easy identification
- Can be squashed later during cleanup
- Safe to run frequently

**Example Usage:**
```bash
/git-checkpoint "before refactoring auth"
/git-checkpoint "trying new approach"
/git-checkpoint
```