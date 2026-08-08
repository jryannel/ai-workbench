---
description: Write a structured handoff doc so a future session can resume cold
argument-hint: "[short-slug]"
allowed-tools: [Bash, Read, Write]
disable-model-invocation: true
---

Capture the current state of work into a durable handoff document under
`.handoffs/` so a later session (or another agent) can pick up exactly where you
left off — without re-reading the whole conversation.

Argument: `$ARGUMENTS` — optional short slug for the filename (e.g. `nexus-merge`).
If absent, derive one from the current branch or the work in progress.

**Steps:**

1. **Resolve location and ensure it's TRACKED (not ignored).**
   Handoffs are committed so they survive worktree archiving/cleanup — a
   gitignored handoff lives only in the worktree and is lost when it's deleted.
   ```bash
   ROOT=$(git rev-parse --show-toplevel)
   mkdir -p "$ROOT/.handoffs"
   # Un-ignore .handoffs/ if a previous run (or an old skill version) ignored it.
   if grep -qxF '.handoffs/' "$ROOT/.gitignore" 2>/dev/null; then
     grep -vxF '.handoffs/' "$ROOT/.gitignore" > "$ROOT/.gitignore.tmp" \
       && mv "$ROOT/.gitignore.tmp" "$ROOT/.gitignore"
   fi
   TS=$(date +%Y%m%d-%H%M)
   ```
   Filename: `$ROOT/.handoffs/<TS>-<slug>.md`.

2. **Gather the git facts** (don't make these up — read them):
   ```bash
   git branch --show-current
   git status --short
   DEFAULT=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'); DEFAULT=${DEFAULT:-main}
   git log --oneline origin/$DEFAULT..HEAD      # unshipped commits
   git diff --stat                              # uncommitted, unstaged
   git diff --cached --stat                     # staged
   ```

3. **Optionally checkpoint** uncommitted work so nothing is lost between sessions.
   Ask, or if the user clearly wants a clean handoff, run `/git-checkpoint
   "handoff <slug>"`. Note in the doc whether a checkpoint was made.

4. **Write the handoff doc** with these sections (fill the narrative ones from the
   conversation context — be concrete and specific, this is for a cold reader):

   ```markdown
   # Handoff — <slug>  (<date time>)

   ## Where
   - Repo / worktree: <path>
   - Branch: <branch>  ·  <N unshipped commits, M uncommitted files>

   ## Goal
   One-paragraph statement of what we're trying to achieve.

   ## Done so far
   - <concrete outcomes, with file paths and commit shas>

   ## In progress / not finished
   - <what's half-done, what's uncommitted, any known-broken state>

   ## Next steps
   1. <the very next concrete action>
   2. ...

   ## How to verify
   - <the exact gate/test command for this repo, e.g. `mise run ci`>

   ## Open questions / decisions pending
   - <anything blocked on a human decision>

   ## Key files & pointers
   - `path:line` — why it matters
   ```

5. **Commit the handoff** (on the current branch) so it travels with the work and
   survives worktree cleanup. Push if the branch tracks a remote.
   ```bash
   git add "$ROOT/.gitignore" "$ROOT/.handoffs/$TS-<slug>.md"
   git commit -m "chore: handoff <slug>"
   git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1 && git push || true
   ```
   If committing onto the current branch is undesirable (e.g. you're on a shared
   branch mid-work), skip the commit, leave the file staged, and say so in the report.

6. **Report** the written path and a one-line summary. Remind the user that
   `/pickup` will pick it up.

**Output:**
```
Handoff written ✓  .handoffs/<TS>-<slug>.md  (committed)
  branch <branch> · <N> unshipped · <M> uncommitted
→ pick up later with: /pickup
```

**Notes:**
- `.handoffs/` is TRACKED and committed — handoffs must survive worktree archiving,
  so they cannot be gitignored working notes. (They merge into history; squash or
  drop them at merge time if that's noise.)
- Prefer specifics over summaries: real file paths, real commit shas, the real
  next command. A good handoff lets a cold session skip rediscovery.
