# ADR-0001: An ADR is a living document, and every record names its cost of change

- **Status:** Working
- **Confidence:** Medium
- **Replaces:** —
- **Decided:** 2026-08-08
- **Last reviewed:** 2026-08-08
- **Issue:** — (no tracker on this repo yet)

## Context

This repo publishes an ADR template, a skill and a command that other people copy. Two forces
narrowed the choice.

First, the primary reader of an ADR here is someone — increasingly some *agent* — trying to work
out how a system fits together **right now**. A directory where most records are historical and a
minority are current serves that reader badly: they must first work out which records are live,
and getting that wrong is silent.

Second, the workbench only has value if its samples encode conventions its author actually
practises. The `sqlb` repo runs the living-document model across 51 records; shipping the
immutable model here would mean the playbook teaches something its author demonstrably doesn't
do. Two contradictory templates across two repos is worse than either model chosen consistently.

The closest rejected alternative was Nygard's immutable record — accepted ADRs never edited, a
change of mind means a superseding document. It lost on the first force: it optimises for an
audit trail, and nobody reading these is auditing. "Document both models and let the reader
choose" was also live, and lost because the playbook's whole method is to be opinionated enough
to be worth editing; a template that hedges its central question hands the reader the hardest
decision with no evidence.

## Decision

ADRs are living documents. Edit one in place when understanding improves, logging the change in
Revisions. Write a new record only when the **problem** changed, not the answer — and link
`Replaces` / `Replaced by` in both directions.

Status becomes `Exploring | Working | Revisiting | Replaced`, with no `Accepted` and no `Final`,
and describes the decision rather than whether the feature is built. Confidence is tracked
separately and is about evidence. Every record carries *What would change our mind* and *Cost of
change*.

What actually decided it: the reader is trying to learn what is true today, not what was believed
in March.

## Consequences

**Buys.**
- The directory is true today, and staleness is visible via `Last reviewed` rather than inferred.
- Reversal cost is stated at decision time, so the trade gets made deliberately instead of
  discovered in a diff.
- `Working / Low` becomes expressible — a decision can be in force and honestly weakly evidenced,
  which the Proposed/Accepted vocabulary cannot say.

**Costs.**
- **The audit trail is gone.** What a record said last quarter survives only in git history,
  which is a worse interface than a superseded file sitting next to its replacement.
- Discipline moves from a rule the format enforces ("never edit an accepted ADR") to a habit that
  has to be maintained ("add a Revisions line"). Habits decay; rules don't.
- "Read the ADR" now needs a freshness check attached, which is a step reviewers will skip.
- This is published guidance. People may already have copied it, so changing back has a blast
  radius beyond this repo.

## What would change our mind

- Records that visibly changed but whose Revisions sections are empty. That means the discipline
  isn't holding, and the audit trail was given up for nothing.
- Needing to reconstruct what a decision said at a past point in time, and resorting to `git log`
  to do it, more than twice.
- Any reader arriving with a compliance or audit brief — that reader needs immutability, and no
  amount of Revisions discipline substitutes.

## Cost of change

Sharply asymmetric. Reverting the template, skill and command to the immutable model is an hour's
work and affects only future records. Recovering the history of records already edited in place is
manual archaeology through git, and no tooling here does it. So: cheap going forward, expensive
retroactively — which means the moment to reconsider is early, while few records exist, and the
cost of waiting compounds quietly with every edit.

## Open questions I had to answer myself

- Whether to keep a dedicated *Options considered* section. Assumed no — one line in Context for
  the closest rejected alternative — on the reasoning that the rejected option is what gets
  questioned on revisit, but a full survey bloats a record nobody finishes. Not validated.
- Whether `Working` should assert that the thing is built. Assumed no, because this pipeline
  records architecture decisions before code exists. `sqlb` needed a footnote to patch exactly
  this ambiguity, which is the evidence the assumption rests on.
- Whether Confidence earns its keep at this repo's scale. In `sqlb`'s index the field is
  effectively two-valued — roughly 20 High, 28 Medium, 1 Low — so it may drift optimistic here
  too. Unknown until there are enough records to see a distribution.
- This repo has no issue tracker, so the template's `Issue` field has nothing to point at. Left
  in the template because consumer projects will have one.

## Revisions

- 2026-08-08 — Written.
