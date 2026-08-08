---
description: Record an architecture decision — as a new numbered ADR, or as a revision to the one that already covers it
argument-hint: <decision to record, plus any context or constraints>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh issue view:*), Bash(gh issue list:*), Bash(git log:*)
---

Record this decision: $ARGUMENTS

## Steps

1. **Check whether a record already covers this.** Glob and grep `docs/adr/` first. ADRs here are
   living documents, so the default action is often to **revise an existing record, not add one**.

   - Same problem, better understanding → **edit that record in place.** Update the sections that
     moved, add a Revisions line saying what changed and why, bump `Last reviewed`.
   - The *problem* itself changed → **new record.** Set `Replaces: ADR-NNNN` on the new one and
     `Replaced by ADR-MMMM` on the old one. Both links, always.
   - Nothing covers it → new record.

   Say which of these you're doing, and why, before you write anything.

2. **Find the next number** (new records only). Highest existing number plus one, zero-padded to
   4 digits. Numbers are allocated in order and never reused. Filename:
   `docs/adr/NNNN-kebab-case-slug.md`.

3. **Read the template** at `docs/adr/0000-template.md` and follow its structure exactly.

4. **Gather context before writing.**
   - Read the records that touch the same area — a decision that contradicts one in force is a
     contradiction to raise, not to bury.
   - If an issue number is mentioned or inferable, run `gh issue view` for the real context.
   - Read `docs/architecture.md` if the decision is structural.

5. **Draft it.** Apply the `adr-writing` skill for what makes each section good.

6. **Stop and check with me before writing** if any of these are true:
   - You could not name a single genuine alternative, or a real cost
   - The decision contradicts a record that is currently `Working`
   - You had to invent a constraint that isn't written down anywhere
   - You're about to edit a record whose Cost of change is high — that's a trade I want to make
     deliberately, not discover in a diff

7. **Write it.** Then report: the path, the one-line decision, the Status and Confidence you set
   and why, the Cost of change, and the contents of the
   `Open questions I had to answer myself` section.

## Rules

- **Title states the decision as a claim, not the topic.** "A page is a position, not a distance",
  not "Pagination approach".
- **Status is `Exploring` unless the thing is built and holding up.** Status describes the
  decision, not the feature — a decision can be `Working` and deliberately unbuilt.
- **Confidence is about evidence, not enthusiasm.** `Low` means you reasoned about it and haven't
  felt the consequences yet. Say `Low` when it's `Low`.
- **Do not invent the rationale.** If you don't know why an option was rejected, list it as an
  open question rather than reverse-engineering a plausible reason. Invented rationale is worse
  than no rationale, because it reads as settled.
- **Name the cost of change, including the asymmetry.** Cheap one way and expensive the other is
  the usual case and the most important thing to write down.
- **Never delete a replaced record.** It stays for the reasoning trail.

## After writing

Suggest — do not create — the issues that would implement this decision. Creating them is
`/issues-from-adr`, and it's a separate step on purpose.
