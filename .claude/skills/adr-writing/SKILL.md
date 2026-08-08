---
name: adr-writing
description: Write, review, and supersede Architecture Decision Records (ADRs) in docs/adr/. Use this skill whenever a decision needs recording, when the user mentions ADRs, decision records, "why did we choose X", or when a conversation has reached a technical or architectural decision worth capturing — even if the user doesn't say "ADR". Also use when reviewing an existing ADR for quality or when a new decision may supersede an old one.
---

# Writing ADRs

An ADR records **why** a decision was made, under what constraints, and what it costs. Its reader
is you-in-a-year, or an agent that needs the reasoning behind a structure it's about to modify.

The value is almost entirely in three places: the constraints in **Context**, the options that were
genuinely rejected, and the honest **Consequences**. Everything else is filing.

## Structure

Always follow `docs/adr/0000-template.md`. Never improvise a different structure — the consistency
is what makes ADRs skimmable and machine-readable across a project.

## What makes each section good

### Title
States the **decision**, not the topic.

- Good: `Use Postgres LISTEN/NOTIFY instead of a message broker`
- Bad: `Message queue evaluation`

If the title doesn't contain a verb and an object, it's a topic.

### Context
Write the **forces**, not the background. Constraints that actually narrowed the option space:
team size, deadline, budget, existing commitments, the product differentiator that must survive.

A good test: could a reader, given only this section, predict which option was chosen? If not,
the real constraint is missing.

Keep opinions out. Opinions belong in Decision.

### Options considered
At least two real options, described as someone who *favoured* each would describe them. A
strawman option is worse than no option — it makes the record look thorough while hiding that only
one thing was actually considered.

Always include the "do nothing / defer" option explicitly. It is frequently correct and almost
always instructive.

If you genuinely cannot construct a second option, say so in the conversation. That usually means
this is a note, not a decision.

### Decision
One sentence, then the reason that **actually decided it**. Real decisions usually turn on a single
dominant constraint, not a weighted average of pros and cons. Name that constraint.

### Consequences
The negatives are the reason the document exists. An ADR listing only benefits is either recording
a non-decision or hasn't been thought through.

Include a **"now harder to change"** list. That's the part future-you most needs and most often
isn't told.

### Revisit when
Concrete triggers: a scale threshold, a date, a dependency's version, a metric crossing a line.
"When it becomes a problem" is not a trigger — it guarantees the ADR is never revisited.

### Open questions I had to answer myself
Every assumption made because an upstream artifact (concept, requirements, architecture) didn't
specify. Be exhaustive and blunt here. A long list is a signal that the upstream artifact needs
work — surfacing that now is much cheaper than discovering it during implementation.

## Superseding

When a new decision changes an old one:

1. Write a **new** ADR. Never edit an accepted ADR's decision.
2. New ADR: set `Supersedes: ADR-NNNN`, and explain in Context **what changed** — the old decision
   was probably right at the time, and why it stopped being right is the valuable part.
3. Old ADR: status becomes `Superseded by ADR-MMMM`. Change nothing else.

The pair of documents is the record. Deleting or rewriting history destroys exactly the reasoning
someone will need.

## Reviewing an existing ADR

When asked to review rather than write, produce **objections only** — do not rewrite the document.
Check for:

- Title states a topic instead of a decision
- Context that doesn't explain why this option won
- Fewer than two genuine options, or a strawman among them
- No "do nothing" option
- Consequences with no negatives, or no "harder to change" list
- Rationale that appears reverse-engineered rather than recorded
- Revisit trigger that isn't concrete
- Contradiction with an existing accepted ADR that isn't acknowledged
- Missing link to the originating issue

Report as a numbered list of specific objections with the section each applies to. If it's sound,
say so plainly rather than manufacturing critique.

## Never

- **Invent rationale.** If you don't know why an option was rejected, list it under open questions.
  Fabricated reasoning is worse than a gap, because it reads as settled fact and gets built upon.
- **Record a decision that hasn't been made.** Status stays `Proposed` until a human accepts it.
- **Bury a contradiction.** If this decision conflicts with an accepted ADR, stop and raise it.
