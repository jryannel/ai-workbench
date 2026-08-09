---
name: adr-writing
description: 'Write, review, revise, and replace Architecture Decision Records (ADRs) in docs/adr/. Use this skill whenever a decision needs recording, when the user mentions ADRs, decision records, "why did we choose X", or when a conversation has reached a technical or architectural decision worth capturing — even if the user doesn''t say "ADR". Also use when reviewing an existing ADR for quality, when new evidence challenges a recorded decision, or when a decision needs revisiting. Differentiator: this is the standard a record is judged against; the /adr command creates or revises the file itself.'
---

# Writing ADRs

An ADR records **why** a decision was made, under what constraints, and what it costs. Its reader
is you-in-a-year, or an agent that needs the reasoning behind a structure it's about to modify.

The value is almost entirely in three places: the constraints in **Context**, the honest
**Costs**, and the price of reversing it. Everything else is filing.

## These are living documents

An ADR here is **not** a contract or a historical artefact. It is the current best understanding
of a problem and the answer chosen for it. Understanding changes; when it does, the ADR changes
with it.

This departs from the original Nygard convention, where an accepted record is immutable and a
change of mind means writing a superseding one. That model optimises for an audit trail. This one
optimises for a document that is **true today**, because the main reader is someone — or some
agent — trying to work out how the system fits together right now, and a directory of
mostly-obsolete records serves them badly.

That doesn't make changing one free. A decision that code has been built on has a price to
revise: work to redo, clients to migrate, sometimes data to move. **Name the price rather than
letting someone discover it.** But a price is not a veto — if there's a good reason and a
willingness to pay, that's the system working. The record exists to make the cost visible so the
trade is deliberate, not to make the answer permanent.

## When to write one — and when not to

Write an ADR when a choice is **hard to reverse**, has **real trade-offs**, or will otherwise be
re-litigated every few months by someone who doesn't know why it went this way. Signals: you
argued about it, you turned down a reasonable alternative, or the answer will surprise someone.

Don't write one for a choice with an obvious default, or for something the code already states
plainly — that belongs in a comment. Two further tests, and either one means stop:

- **No cost you can name** → this isn't a decision, it's a note.
- **No alternative that was genuinely live** → also not a decision. Say so rather than
  manufacturing a rejected option to fill the section.

**Prefer revising an existing record to adding one.** A directory that grows a record per
conversation stops being readable, and unreadable is a worse failure than missing.

**Write them early**, while the reasoning is fresh and before the decision starts to feel
inevitable. A record written after the fact justifies rather than explains — a difference obvious
to every reader except its author.

## Structure

Always follow `docs/adr/0000-template.md`. Never improvise a different structure — the
consistency is what makes ADRs skimmable and machine-readable across a project.

The sections are Context, Decision, Consequences, What would change our mind, Cost of change,
Open questions I had to answer myself, and Revisions. That is the whole set.

**Keep it short.** A page is usually enough. A record nobody finishes reading has failed at its
only job.

## What makes each section good

### Title
States the **decision** as a claim, not the topic. If there's no verb and no object, it's a topic.

- Good: `A page is a position, not a distance`
- Bad: `Pagination approach`

### Status and Confidence
Two different questions, and conflating them is the most common failure.

**Status** is where the decision stands: `Exploring` (chosen, not yet trusted), `Working` (in
force, holding up), `Revisiting` (something has challenged it), `Replaced` (the problem changed).
There is deliberately no `Accepted` and no `Final`.

Status is about the **decision**, not the feature. A decision can be `Working` and deliberately
unbuilt — scope is not a status. If the work is out of scope, say so in one line under Decision
rather than inventing a status for it.

**Confidence** is about evidence: `High` (built it, used it, it held), `Medium` (built it,
limited use), `Low` (reasoned about it, haven't felt the consequences). `Working / Low` is a
useful signal, not an embarrassment. If nothing in a directory is ever `Low`, the field has
drifted optimistic and stopped carrying information.

### Context
Write the **forces**, not the background. Constraints that actually narrowed the options: team
size, deadline, budget, existing commitments, the differentiator that must survive.

A good test: could a reader, given only this section, predict which option won? If not, the real
constraint is missing.

Name the closest rejected alternative in **one line**, with why it lost — including "do nothing"
where it was genuinely live. This is not a survey of every path not taken; re-arguing the whole
case bloats the record and nobody reads it. But the rejected option is the first thing questioned
on revisit, and the reason it lost is the one thing that can't be reconstructed from the code
later.

Keep opinions out. Opinions belong in Decision.

### Decision
Stated plainly, present tense, active voice. Then the reason that **actually** decided it — real
decisions turn on one dominant constraint, not a weighted average of pros and cons. Name that
constraint.

### Consequences
**Buys** and **Costs**, concretely, two or three bullets each. The costs are the reason the
document exists. A record listing only benefits is either a non-decision or hasn't been thought
through.

### What would change our mind
Observations specific enough to recognise when they occur: a scale threshold, a date, a
dependency's version, a metric crossing a line. "When it becomes a problem" is not a trigger — it
guarantees the record is never revisited. This section is where a record earns its keep: hitting
one of these conditions is the cue to reopen it, not to work around it quietly.

### Cost of change
What reversing this would take. **Note asymmetry** — cheap to widen and expensive to narrow again
is the usual shape, and it's the most important thing to know, because it decides whether to move
now or wait. Decisions that are expensive in one direction are the ones to change slowly.

### Open questions I had to answer myself
Every assumption made because an upstream artifact (concept, requirements, architecture) didn't
specify. Be exhaustive and blunt. A long list is a signal that the upstream artifact needs work —
surfacing that now is much cheaper than discovering it during implementation.

### Revisions
One line per substantive change: what changed and why. Distinct from **Last reviewed**, which
means "read it, still true, changed nothing." Bump the review date when you touch the area; add a
revision line only when the content moved.

## Changing an ADR

**Edit in place when your understanding improves.** Add a line to Revisions saying what changed
and why, and bump Last reviewed. Reversing a decision is normal — it means you learned something.
Record what you learned.

**Write a new record only when the *problem* changed, not the answer.** That's genuinely a
different decision. When you do:

1. New record sets `Replaces: ADR-NNNN` and explains in Context **what changed** — the old
   decision was probably right at the time, and why it stopped being right is the valuable part.
2. Old record's status becomes `Replaced by ADR-MMMM`, and it stays for the reasoning trail.
3. **Both links, always.** A one-directional link means the trail only works if you already know
   where to look.

Weigh the cost, then decide. The bar is a good reason and a willingness to pay it — not consensus,
not seniority, and not process.

## Reviewing an existing ADR

When asked to review rather than write, produce **objections only** — do not rewrite the
document. Check for:

- Title states a topic instead of a decision
- Context that doesn't explain why this option won
- No rejected alternative named, where one obviously existed
- Consequences with no costs, or costs that are hedged into meaninglessness
- Rationale that appears reverse-engineered rather than recorded
- A "what would change our mind" trigger you couldn't actually notice occurring
- Cost of change missing, or asymmetry unstated where it plainly exists
- Status claiming more maturity than Confidence supports, or a status outside the vocabulary
- `Last reviewed` far behind the code it governs — a stale record is worse than an absent one
- Replaced records missing one side of the link pair
- Contradiction with another record that's in force and isn't acknowledged
- Missing link to the originating issue

Report as a numbered list of specific objections with the section each applies to. If it's sound,
say so plainly rather than manufacturing critique.

## Never

- **Invent rationale.** If you don't know why an option was rejected, list it under open
  questions. Fabricated reasoning is worse than a gap, because it reads as settled fact and gets
  built upon.
- **Add process.** No approvals, no quorum, no sign-off states. If something architectural
  changed, write down why.
- **Bury a contradiction.** If a decision conflicts with another record in force, stop and raise
  it.
- **Let a record rot quietly.** If it no longer reads true, fix it or mark it `Revisiting`.
