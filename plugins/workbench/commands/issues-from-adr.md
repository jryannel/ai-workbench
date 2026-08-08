---
description: Turn an ADR that is in force into a set of proposed GitHub issues
argument-hint: <ADR number or path, e.g. 0007>
disable-model-invocation: true
allowed-tools: Read, Glob, Bash(gh issue list:*), Bash(gh issue view:*), Bash(gh label list:*)
---

Propose the GitHub issues that implement the decision in ADR $ARGUMENTS.

## Steps

1. **Read the ADR.** Resolve `$ARGUMENTS` to a file under `docs/adr/` (accept a bare number, a
   filename, or a path).

2. **Check the status carries enough weight to spawn work.**
   - `Working` — go ahead.
   - `Exploring` — say so and stop. The direction isn't trusted yet; building on it is how an
     unsettled decision becomes settled by accident.
   - `Revisiting` — stop. Work proposed now may be undone by the revisit.
   - `Replaced` — stop, and point at the record that replaced it.

   If Confidence is `Low`, say so and ask before proposing anything — low confidence plus new
   work is the combination most likely to be rewritten.

3. **Check for existing work.** `gh issue list --state all --search "<key terms>"` so you don't
   propose duplicates. Mention any near-matches you find.

4. **Decompose the decision into issues.** Each one must be:
   - **Independently shippable** — mergeable on its own without breaking main
   - **Verifiable** — has a definition of done a machine or a five-minute check can confirm
   - **Half a day to two days** of work. Bigger means it's still a milestone, not an issue
   - **Traceable** — body links back to this ADR

5. **Present them as a table for review. Do not create anything.**

   | # | Title | Type | Definition of done | Depends on |
   |---|---|---|---|---|

6. **Wait for my explicit approval**, then create only the ones I approve. Use existing labels —
   check `gh label list` first; propose new labels rather than inventing them silently.

## Issue body format

```markdown
## Context
Implements the decision in ADR-NNNN: <one-line decision>.

## Scope
What this issue covers — and explicitly what it does not.

## Definition of done
- [ ] <verifiable condition>
- [ ] <verifiable condition>

## Notes
Constraints from the ADR that apply here. Link related issues.
```

## Rules

- **Don't create issues for work the ADR doesn't imply.** If you spot adjacent work worth doing,
  list it separately as "noticed, not proposed" and let me decide.
- **Surface sequencing.** If issue B can't start until A lands, say so in the `Depends on` column
  rather than burying it in the body.
- **Flag the gap.** If the ADR is too vague to decompose, say which section is underspecified.
  That's a signal the ADR needs work, not that you should guess harder.
