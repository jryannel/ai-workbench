---
description: Ship the current worktree's work as a self-merging PR (preflight + push + auto-merge), without waiting for CI
argument-hint: "[commit message] [--no-preflight] [--no-auto]"
allowed-tools: [Bash, Read]
disable-model-invocation: true
---

Land the current branch/worktree onto `main` via a **PR that merges itself**:
commit anything pending, rebase onto the latest `main`, run a short local
preflight, push the branch, open a PR with auto-merge enabled, and **return
immediately**.

**You do not wait for CI.** CI is the gate — it runs on the PR, on GitHub's
runners, and it merges the PR itself when it goes green. Waiting for it costs
the user minutes per ship and buys nothing, because a red result arrives as a
notification either way.

**You do not run the full gate locally.** Running `mise run ci` on the user's
machine duplicates, serially, what CI already runs in parallel jobs — and when
several worktrees do it at once it starves the machine. The preflight below is
the local half; everything else belongs to CI.

Arguments: `$ARGUMENTS`
- Free text (not starting with `--`) is the commit message for pending changes.
- `--no-preflight` skips the local preflight (docs-only changes).
- `--no-auto` opens the PR but leaves it for the user to merge by hand.

**Steps:**

1. **Detect the default branch and the current branch** (don't assume `main`):
   ```bash
   DEFAULT=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   DEFAULT=${DEFAULT:-main}
   CURRENT=$(git branch --show-current)
   ```
   - If `CURRENT` == `DEFAULT`: STOP. "You're on `$DEFAULT` itself — ship is for
     landing a worktree branch. Just commit and `/git-sync`."
   - If `CURRENT` is empty (detached HEAD, which `/git-worktree` can leave):
     create a branch first — `git switch -c claude/<short-slug>` derived from the
     work — and use that as `CURRENT`.

2. **Handle uncommitted changes — never blanket-commit a dirty tree.**
   ```bash
   git status --short
   ```
   - If clean: continue.
   - If dirty: **show the full working tree and decide what belongs in this
     ship.** Do NOT `git add -A` blindly — a messy branch often carries unrelated
     noise (stray logs, generated files, an unrelated edit) that must not ride
     onto `$DEFAULT`. Classify what you see:
     - **Relevant** to this work → stage those specific paths and commit (use the
       provided message, or a summary you derive from the diff; match the repo's
       commit-trailer style from `git log`).
     - **Unrelated / noise** (pre-existing files you didn't touch, logs, scratch
       files) → **set aside**, don't land:
       `git stash push -m "ship-stash: unrelated" -- <paths>` and restore it
       with `git stash pop` after the push (step 7).
     - **Unsure** → STOP and ask the user which paths to include. When ambiguous,
       default to *excluding* — it's safer to leave a file behind than to push it
       by accident.

3. **Fetch and rebase onto the latest default branch.**
   ```bash
   git fetch origin
   git rebase origin/$DEFAULT
   ```
   - On conflict: STOP. Show `git status --short`, explain the conflicting
     files, and tell the user to resolve → `git add` → `git rebase --continue`,
     then re-run `/git-ship`. Offer `git rebase --abort` as the escape hatch.

4. **Run the preflight** (unless `--no-preflight`). Auto-detect, in order:
   - If `mise.toml` defines a `preflight` task (`grep -q '\[tasks.preflight\]' mise.toml`)
     → `mise run preflight`.
   - Else if a `test` task exists → `mise run test`.
   - Else the project's native build+test (`go build ./... && go test ./...`,
     `npm test`, `cargo test` — infer from the repo).

   Never `mise run ci` — that is the CI gate, and it runs on GitHub.

   If preflight fails: STOP and report. It only covers compile-and-fast-tests, so
   a failure here is real and cheap to fix now. Note that a preflight task may
   *heal* the tree (reformat, regenerate); if it leaves changes, amend them into
   the commit before pushing.

5. **Push the branch** — never straight to `$DEFAULT`.
   ```bash
   git push -u origin HEAD:$CURRENT
   ```

6. **Open the PR and let it merge itself.**
   ```bash
   gh pr view --json url --jq .url 2>/dev/null \
     || gh pr create --base "$DEFAULT" --title "<title>" --body "<body>"
   ```
   - Title and body follow the repo's conventions — read a recent merged PR with
     `gh pr list --state merged --limit 3` if unsure. End the body with the
     Claude Code attribution line if the repo's history uses one.
   - Then, unless `--no-auto`:
     ```bash
     gh pr merge --auto --squash --delete-branch
     ```
   - If that errors with something like *"Auto-merge is not allowed"* or *"Pull
     request is in clean status"*, the repo has no required status checks, so
     there is nothing for auto-merge to wait on. Report it and tell the user the
     one-time fix: add a ruleset on `$DEFAULT` requiring the CI checks. Leave the
     PR open rather than merging it yourself.

7. **Report and exit. Do not poll CI.**
   - **If you stashed unrelated changes in step 2**, restore them now:
     `git stash pop` (and confirm the tree matches what it held before).
   - Do NOT run `gh pr checks --watch`, do NOT sleep-and-poll, do NOT re-check the
     run. The PR merges on its own. If the user wants the result, they can ask —
     or `gh pr checks` when they choose to.
   - Offer worktree cleanup as a *later* step, since the branch is not merged yet:
     once the PR lands, from another worktree run
     `git worktree remove <this-path>`. Do **not** try to remove the worktree
     you're currently standing in, and do not delete the branch (GitHub deletes it
     on merge).

**Output:**
```
Shipped ✓  <N> commit(s) → PR #<n>

  <url>

Preflight: mise run preflight (passed, <T>s)
Auto-merge: enabled (squash) — merges itself when CI is green, ~<T> min
Not waiting for CI.

Later:
  • /git-sync                    → fast-forward your local $DEFAULT
  • git worktree remove <path>   → once the PR has landed
```

**Notes:**
- The gate is CI, not this command. The preflight exists to catch a broken
  compile and healable drift, both of which would otherwise cost a full CI cycle
  to discover.
- Auto-merge needs required status checks on `$DEFAULT`; without them GitHub has
  nothing to hold the PR against. That is repo configuration, set once.
- Squash-merge keeps `$DEFAULT` linear, which is what the rebase in step 3 is
  protecting.
- Several worktrees shipping at once is normal and fine: each PR rebases itself
  against `$DEFAULT` at ship time, and GitHub serializes the merges.
