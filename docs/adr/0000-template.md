# ADR-NNNN: <The decision, stated as a claim>

- **Status:** Exploring | Working | Revisiting | Replaced by [ADR-NNNN](NNNN-slug.md)
- **Confidence:** High | Medium | Low
- **Replaces:** — <or [ADR-NNNN](NNNN-slug.md)>
- **Decided:** YYYY-MM-DD
- **Last reviewed:** YYYY-MM-DD
- **Issue:** #NN

<!--
Title: a claim with a verb, not a topic.
  Good: "A page is a position, not a distance" / "Use Postgres LISTEN/NOTIFY instead of a broker"
  Bad:  "Pagination" / "Message queue evaluation"

Status is about the DECISION, not the feature:
  Exploring   — direction chosen, not yet built enough to trust. Expect movement.
  Working     — in force, and holding up so far.
  Revisiting  — something has challenged it. Actively being reconsidered.
  Replaced    — the *problem* changed. Points at its replacement and stays for the trail.
A decision can be Working and deliberately unbuilt. Scope is not a status — if the decision is
settled but the work is out of scope, say so in one line under Decision.

Confidence is about EVIDENCE, not enthusiasm:
  High   — built it, used it, it held
  Medium — built it, limited use
  Low    — reasoned about it, haven't felt the consequences yet
Working / Low is a useful signal, not an embarrassment. If nothing here is ever Low, the field
has stopped telling you anything.

Both links are required when replacing: the new record sets Replaces, the old one sets
Replaced by. A one-directional link means the trail only works if you already know where to look.
-->

## Context

The problem, and the constraints that are actually real — team size, deadline, budget, existing
commitments, the differentiator that has to survive. Facts and forces, not the argument that got
you here.

A good test: could a reader, given only this section, predict which way it went? If not, the real
constraint is missing.

Name the closest rejected alternative in one line, and why it lost. Not a survey of every path —
one line, for the one that was genuinely close. On revisit, "has the reason it lost expired?" is
the first question asked, and it's the only part nobody can reconstruct from the code.

## Decision

What we are doing, stated plainly. Present tense, active voice. Then the reason that **actually**
decided it — real decisions usually turn on one dominant constraint, not a weighted average.

## Consequences

**Buys.** The benefits, concretely. Two or three bullets.

**Costs.** The real price, without hedging. Every decision has one, and this is the section the
document exists for. If you can't name a cost, you're recording a non-decision.

## What would change our mind

Two or three observations specific enough to recognise when they happen: "if X takes longer
than Y", not "if it turns out badly". A trigger you can't notice is not a trigger.

## Cost of change

What reversing this would take, in a line or two. Note asymmetry where it exists — cheap in one
direction and expensive in the other is the usual case, and the most important thing to know,
because it's what decides whether to move now or wait.

## Open questions I had to answer myself

Assumptions made because an upstream artifact (concept, requirements, architecture) didn't say.
Be blunt and exhaustive. A long list means the problem is upstream — go fix that first.

-

## Revisions

- YYYY-MM-DD — Written.
