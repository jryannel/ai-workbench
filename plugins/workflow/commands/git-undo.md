---
description: Safely undo recent changes with multiple options
argument-hint: [commits|files|last]
allowed-tools: [Bash]
disable-model-invocation: true
---

Safely undo recent changes. Provides multiple undo options with clear explanations.

**Instructions:**

1. **Show undo options menu**
   
   Output:
   ```
   Git Undo Options
   ================
   
   1. Undo last commit (keep changes)
      git reset --soft HEAD~1
      → Uncommits last commit but keeps changes staged
   
   2. Undo last commit (discard changes)
      git reset --hard HEAD~1
      → DESTRUCTIVE: Removes commit and all changes
   
   3. Undo uncommitted changes
      git restore .
      → DESTRUCTIVE: Discards all uncommitted changes
   
   4. Undo specific file
      git restore <file>
      → Discard changes to specific file
   
   5. Unstage files
      git restore --staged .
      → Keeps changes but unstages them
   
   6. Undo last N commits
      git reset --soft HEAD~N
      → Uncommits last N commits, keeps changes
   
   7. Revert commit (safe)
      git revert HEAD
      → Creates new commit that undoes last commit
   
   Which option? (1-7 or 'cancel'):
   ```

2. **Execute selected option**

   **Option 1: Undo last commit (soft)**
   ```bash
   git reset --soft HEAD~1
   git status
   ```
   Output:
   ```
   Last commit undone ✓
   Changes are still staged
   
   Undone commit: abc1234 feat: add feature
   
   Next steps:
   - Modify files if needed
   - Recommit: git commit -m "new message"
   - Or unstage: git restore --staged .
   ```

   **Option 2: Undo last commit (hard)**
   ```bash
   # Show what will be lost
   git log -1 --stat
   
   # Confirm
   echo "⚠️  DESTRUCTIVE: This will permanently delete:"
   git log -1 --oneline
   git diff HEAD~1 --stat
   
   echo "Type 'DELETE' to confirm:"
   # Wait for confirmation
   
   # If confirmed:
   git reset --hard HEAD~1
   ```
   Output:
   ```
   Commit and changes deleted ⚠️
   
   Deleted commit: abc1234 feat: add feature
   Files affected: [list]
   
   Recovery:
   - May be in reflog: git reflog
   - Recovery: git reset --hard abc1234
   ```

   **Option 3: Undo uncommitted changes**
   ```bash
   # Show what will be lost
   git status --short
   git diff --stat
   
   # Confirm
   echo "⚠️  DESTRUCTIVE: Discard all uncommitted changes?"
   echo "Type 'DISCARD' to confirm:"
   # Wait for confirmation
   
   # If confirmed:
   git restore .
   git clean -fd  # Remove untracked files
   ```
   Output:
   ```
   Uncommitted changes discarded ⚠️
   
   Files reverted: [list]
   Files deleted: [untracked files]
   
   Working directory is now clean
   ```

   **Option 4: Undo specific file**
   ```bash
   # List modified files
   git status --short
   
   echo "Which file to restore? (full path):"
   # Wait for file path
   
   # Preview changes
   git diff $FILE
   
   # Confirm and restore
   git restore $FILE
   ```
   Output:
   ```
   File restored: $FILE ✓
   Changes discarded in this file only
   ```

   **Option 5: Unstage files**
   ```bash
   git restore --staged .
   git status
   ```
   Output:
   ```
   All files unstaged ✓
   Changes preserved but not staged
   
   Unstaged files: [list]
   
   Next steps:
   - Review changes
   - Stage selectively: git add <file>
   - Or discard: /git-undo → option 3
   ```

   **Option 6: Undo last N commits**
   ```bash
   echo "How many commits to undo? (1-10):"
   # Get N
   
   # Show what will be undone
   git log --oneline -$N
   
   echo "Undo these $N commits? (yes/no):"
   # Confirm
   
   git reset --soft HEAD~$N
   git status
   ```
   Output:
   ```
   Last $N commits undone ✓
   All changes are still staged
   
   Undone commits:
   - abc1234 commit 1
   - def5678 commit 2
   ...
   
   Next steps:
   - Review combined changes
   - Recommit as single commit
   - Or split into new commits
   ```

   **Option 7: Revert commit (safe)**
   ```bash
   # Show commit to revert
   git log -1
   
   # Create revert commit
   git revert HEAD --no-edit
   git log -1
   ```
   Output:
   ```
   Commit reverted safely ✓
   
   Original: abc1234 feat: add feature
   Revert:   xyz9876 Revert "feat: add feature"
   
   This is safe:
   - Original commit still in history
   - New commit undoes the changes
   - Can be pushed to shared branches
   ```

3. **Show safety reminder**
   ```
   Undo Safety Guide:
   
   ✓ SAFE operations:
   - git revert (creates new commit)
   - git reset --soft (keeps changes)
   - git restore --staged (unstages only)
   
   ⚠️  DESTRUCTIVE operations:
   - git reset --hard (loses uncommitted work)
   - git restore (discards changes)
   - git clean (deletes untracked files)
   
   Recovery options:
   - Check reflog: git reflog
   - Stash if unsure: git stash
   - Checkpoint first: /git-checkpoint
   ```

**Argument Shortcuts:**

If `$1 = "last"`:
→ Automatically do Option 1 (undo last commit, keep changes)

If `$1 = "hard"`:
→ Automatically do Option 2 (undo last commit, discard changes)
→ Still requires confirmation

If `$1 = "files"`:
→ Automatically do Option 3 (undo uncommitted changes)
→ Still requires confirmation

**Example Usage:**
```bash
/git-undo              # Show menu
/git-undo last         # Undo last commit (soft)
/git-undo hard         # Undo last commit (hard)
/git-undo files        # Discard uncommitted changes
```

**Common Workflows:**

**Wrong commit message:**
```bash
/git-undo last
# Edit files or just recommit
git commit -m "Correct message"
```

**Want to split commit:**
```bash
/git-undo last
# Now changes are staged
git restore --staged .
git add file1.ts
git commit -m "feat: part 1"
git add file2.ts
git commit -m "feat: part 2"
```

**Committed to wrong branch:**
```bash
git log -1  # Copy commit hash
/git-undo last
git checkout correct-branch
git cherry-pick <commit-hash>
```

**Started work but want to discard:**
```bash
/git-undo files
# All uncommitted changes gone
```

**Use Cases:**
- Fix wrong commit message
- Split commit into multiple commits
- Discard experimental changes
- Undo accidental commits
- Clean up work-in-progress
- Remove sensitive data from last commit
