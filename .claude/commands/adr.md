---
description: Create a new numbered Architecture Decision Record from the template
argument-hint: <decision to record, plus any context or constraints>
allowed-tools: Read, Write, Glob, Bash(gh issue view:*), Bash(gh issue list:*), Bash(git log:*)
---

Create a new ADR recording this decision: $ARGUMENTS

## Steps

1. **Find the next number.** Glob `docs/adr/*.md`, take the highest existing number, add one,
   zero-pad to 4 digits. Filename: `docs/adr/NNNN-kebab-case-title.md`.

2. **Read the template** at `docs/adr/0000-template.md` and follow its structure exactly.

3. **Gather context before writing.**
   - Read existing ADRs that touch the same area. If this decision changes one of them, this is a
     **supersede**, not a new independent decision — set `Supersedes:` here and note in the
     conversation that the old ADR's status needs updating to `Superseded by ADR-NNNN`.
   - If an issue number is mentioned or inferable, run `gh issue view` to pull the real context.
   - Read `docs/architecture.md` if the decision is structural.

4. **Draft the ADR.** Apply the `adr-writing` skill for what makes each section good.

5. **Stop and check with me before writing the file** if any of these are true:
   - You could not find at least two genuine options
   - The decision contradicts an accepted ADR
   - You had to invent a constraint that isn't written down anywhere

6. **Write the file.** Then report: the path, the one-line decision, and the contents of the
   `Open questions I had to answer myself` section.

## Rules

- **Title states the decision, not the topic.** "Use Postgres for the event store", not
  "Database choice".
- **Never edit an accepted ADR to change its decision.** Supersede it and link both directions.
- **Do not invent the rationale.** If you don't know why an option was rejected, list it as an
  open question rather than reverse-engineering a plausible reason. Invented rationale is worse
  than no rationale, because it reads as settled.
- Status is `Proposed` unless I explicitly said the decision is made.

## After writing

Suggest — do not create — the issues that would implement this decision. Creating them is
`/issues-from-adr`, and it's a separate step on purpose.
