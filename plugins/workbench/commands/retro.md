---
description: Mine the last week of session transcripts and repo artifacts for what to automate, fix, or delete
argument-hint: "[days, default 7] [--all-projects]"
arguments: days scope
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(jq:*), Bash(grep:*), Bash(sort:*), Bash(uniq:*), Bash(awk:*), Bash(wc:*), Bash(tr:*), Bash(sed:*), Bash(ls:*), Bash(git log:*)
---

Produce a friction report for the last `$days` days (default 7, when empty) and recommend at most
three changes. If `$scope` is `--all-projects`, widen beyond this repo and its worktrees.

This replaces the manual friction log. The data already exists — it does not depend on anyone
remembering to write a line while annoyed mid-task.

## Where the data is

Claude Code writes one `.jsonl` per session to `~/.claude/projects/<slug>/`, where `<slug>` is the
working directory with **every non-alphanumeric character** replaced by `-`. Worktrees get their
own sibling directories, so match on the repo slug as a **prefix** or you will miss most of the
traffic.

```bash
DAYS=${DAYS:-7}   # from $days, defaulting to 7
SLUG=$(pwd | sed 's/[^A-Za-z0-9]/-/g')
BASE=~/.claude/projects
# this repo and its worktrees; use $BASE for --all-projects
find $BASE -maxdepth 1 -type d -name "${SLUG}*" 2>/dev/null
```

**Replace dots too, not just slashes.** `github.com` becomes `github-com`, and a path under
`~/.claude/` becomes `--claude`. Transforming only `/` produces a slug that matches nothing, and
`find` reports no directories rather than failing — so the retro silently reports on an empty set.
**If the find returns nothing, stop and check the slug before going further.** A retro over zero
sessions still produces a confident-looking report.

## Step 1 — Extract genuine typed prompts

A "user" record is *not* necessarily something the human typed. Tool results, command expansions
and attachment metadata all arrive as user records, and counting them produces a report about
your own tooling rather than about your work.

```bash
find <dirs> -name '*.jsonl' -mtime -$DAYS -exec jq -r '
  select(.type=="user" and (has("toolUseResult")|not) and (.isSidechain!=true))
  | (if (.message.content|type)=="string" then .message.content
     else ([.message.content[]?|select(.type=="text")|.text]|join(" ")) end)
  | select(.!=null and .!="") | gsub("\n";"  ")' {} + 2>/dev/null > /tmp/retro-raw.txt

grep -v -i -e 'command-message' -e 'command-name' -e 'local-command' \
          -e 'image original' -e 'request interrupted' -e 'caveat:' /tmp/retro-raw.txt \
  | awk 'length($0)<=500 && length($0)>0' > /tmp/retro-clean.txt
```

**Both filters are load-bearing.** Skill and command bodies are injected as user messages and run
to thousands of characters; leaving them in inflates every keyword count by 3–10×. Verify by
checking that the cleaned count is meaningfully lower than the raw count, and report both.

## Step 2 — Count the signals

**Repeated instructions** — the promotion-rule input:

```bash
tr 'A-Z' 'a-z' < /tmp/retro-clean.txt | sed 's/[[:punct:]]//g; s/  */ /g; s/^ //; s/ $//' \
  | grep -v '^$' | sort | uniq -c | sort -rn | awk '$1>=2'
```

Group these into **families** by intent, not by exact string — "push it", "ship it", "open the
pr" and "merge it" are one workflow, and the family count is what the promotion rule needs.

**Commands actually invoked** — these live in markers, not in prose, so they need their own pass.
It has to run through the **same user-record filter as Step 1**, for the same reason:

```bash
find <dirs> -name '*.jsonl' -mtime -$DAYS -exec jq -r '
  select(.type=="user" and (has("toolUseResult")|not) and (.isSidechain!=true))
  | (if (.message.content|type)=="string" then .message.content
     else ([.message.content[]?|select(.type=="text")|.text]|join(" ")) end)
  | select(.!=null) | select(test("<command-name>"))
  | capture("<command-name>(?<c>[^<]*)</command-name>").c' {} + 2>/dev/null \
  | sort | uniq -c | sort -rn
```

**Never grep the raw `.jsonl` for this.** The marker appears in assistant tool calls, in tool
results, and in any transcript where the retro's own output was echoed back — including this
command's. Grepping raw counts all of them as invocations. Measured against 30 days of real
sessions, the naive grep overstated `/handoff` by 4 and `/resume` by 6, and invented a command
called `(.*?)` out of a regex printed in an earlier report. **A count you cannot distinguish from
your own output is not a measurement.**

**Interruptions** — how often work was stopped mid-flight:

```bash
grep -c 'Request interrupted' /tmp/retro-raw.txt
```

**Correction shapes** — case-insensitive counts of `again`, `instead`, `don't|do not`, `still`,
`not what I`, `revert|undo` in the cleaned file.

**Upstream underspecification** — every artifact the ADR template produces carries one:

```bash
grep -A20 -r 'Open questions I had to answer myself' docs/ 2>/dev/null
```

**Rework and staleness** — the living-document model records this as a byproduct:

```bash
grep -H -e '^- \*\*Status:' -e '^- \*\*Last reviewed:' docs/adr/[0-9]*.md
grep -A5 -H '^## Revisions' docs/adr/[0-9]*.md
```

A record revised within a fortnight of being written is upstream having been wrong, and a
`Last reviewed` far behind the code it governs is a stale record.

## Step 3 — Interpret, don't just count

The comparison that matters is **prose family count vs. the matching command's invocation
count.** If a workflow is driven in prose far more often than its command is invoked, the
automation already exists and is not being reached. That is a trigger problem — a better
description, a clearer name, a `CLAUDE.md` line — and building anything new would be waste.

Apply the promotion rule from the README only to families with no existing command:

| Observation | Threshold | Promote to |
|---|---|---|
| Same instruction re-typed | 3× | Command |
| Same output-shape correction | 3× | Skill |
| Same accept/reject judgement | 3× | Loop |
| Step that must always happen, forgotten | 2× | Hook |

Then look for what to **delete**: any command, skill or agent the repo ships — in `.claude/`, or in
a plugin under `plugins/` — with zero invocations in the window is a candidate. Deleting is a
success condition, not a failure.

**Except when the automation is younger than the window.** Something written three days into a
seven-day window has had three days to be used, and a zero against it measures nothing. Check
`git log` for when it landed before recommending its removal, and say so rather than proposing a
deletion the data cannot support:

```bash
git log --diff-filter=A --format='%as' -1 -- <path>
```

## Output

```markdown
## Retro — last N days
Sessions: N across M projects · Typed prompts: N clean (from R raw) · Interruptions: N

### Top friction, by family
| Family | Count | Existing command | Invocations | Read |
|---|---|---|---|---|

### Recommend
1. <change> — because <count and comparison>

### Delete
- <command/skill> — 0 invocations in the window

### Upstream signal
Open questions per artifact, and any ADR revised soon after being written.
```

## Rules

- **Report the raw and cleaned counts.** A reader who can't see how much was filtered can't judge
  the rest.
- **At most three recommendations.** A retro that produces a backlog has produced nothing.
- **Prefer "fix the trigger" and "delete" over "build".** Both are cheaper than a new rung, and
  the counts usually support them.
- **Do not build anything in this command.** It reports. Deciding is a separate step, on purpose.
