# Friction Log

**Purpose:** discover which automation to build by observing what actually costs you time —
rather than guessing from an armchair.

**Duration:** two weeks. Then sort by frequency and apply the promotion rule.

**Rules:**
- One line per incident. Log it *when it happens*, not at end of day.
- Don't categorise while logging — that biases what you notice.
- Don't fix anything during the logging period. You're collecting data, not optimising.
- Boring repeated annoyances beat interesting one-off ones. The boring ones are the automatable ones.

---

## What counts as friction

- Re-explaining context Claude should already have had
- Re-typing a similar instruction
- Fixing the same *class* of output problem (structure, tone, missing section)
- Hand-carrying an artifact from one step to the next
- Catching a mistake you've caught before
- Forgetting a step that should always happen

---

## Log

| Date | What happened | Where in the pipeline | Cost (min) |
|---|---|---|---|
| | | | |

<!--
Example entries — delete these:

| 2026-08-08 | Re-explained the auth decision from ADR-0007 to Claude | implementation | 5 |
| 2026-08-08 | Had to restructure ADR output; consequences section missing again | ADR | 8 |
| 2026-08-09 | Copied architecture doc into a new chat by hand | architecture → issues | 3 |
| 2026-08-09 | Forgot to run tests before opening the PR | validation | 15 |
-->

---

## Review (end of two weeks)

Sort the log by frequency of the *same underlying cause*, then:

| Count | Pattern | Promote to | Built? |
|---|---|---|---|
| | | | |

### Promotion thresholds

| Observation | Threshold | Promote to |
|---|---|---|
| Same instruction re-typed | 3× | Command |
| Same output-shape correction | 3× | Skill |
| Same accept/reject judgement | 3× | Loop (that judgement is the verifier) |
| Step that must always happen, forgotten | 2× | Hook |
| Hand-carried handoff, genuinely parallel or needs different tools | 5× | Edge / subagent |

### Sanity checks before building anything

- [ ] Is this actually **context re-supply**? Then it's a `CLAUDE.md` entry, not automation.
- [ ] Is the *format* stable, or just the *topic*? Unstable format → too early for a skill.
- [ ] Could a lower rung solve it? Always take the lower rung.
- [ ] Will this move time-to-first-slice or rework rate? If neither — don't build it.

---

## Retrospective (after building)

| Built | Date | Did it move the metric? | Keep / delete |
|---|---|---|---|
| | | | |

Deleting things is a success condition, not a failure. A shrinking `.claude/` directory means
you're keeping only what earns its place.
