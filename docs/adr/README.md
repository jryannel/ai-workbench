# Architecture Decision Records

An ADR records a decision that shaped this codebase and — more importantly — **why**, so a future
reader can judge whether the reasoning still holds. The main reader is someone, increasingly some
agent, working out how the system fits together *right now*.

**These are living documents.** A record here is not a contract or a historical artefact; it is
the current best understanding of a problem and the answer chosen for it. Edit one in place when
your understanding improves, and log it under Revisions. Write a new record only when the
*problem* changed, not the answer.

That doesn't make change free — every record carries a **Cost of change** naming the bill, and a
**What would change our mind** naming the trigger. A price is not a veto. If there's a good reason
and a willingness to pay it, that's the system working: the record exists to make the trade
deliberate, not to make the answer permanent.

For how to write each section well, see the `adr-writing` skill. This file covers *when* to write
one and how the directory is organised.

## When to write one

Write an ADR when a choice is hard to reverse, has real trade-offs, or will otherwise be
re-litigated every few months by someone who doesn't know why it went this way. Signals: you
argued about it, you turned down a reasonable alternative, or the answer will surprise someone.

Don't write one for a choice with an obvious default, or for something the code already says
plainly — that belongs in a comment. If you can't name a cost, or no alternative was genuinely
live, it's a note rather than a decision.

Write them early, while the reasoning is fresh and before the decision feels inevitable. A record
written after the fact tends to justify rather than explain.

## Status

Status describes maturity, not approval. There is deliberately no `Accepted` and no `Final`.

| Status | Meaning |
|---|---|
| **Exploring** | Direction chosen, not yet built enough to trust. Expect movement. |
| **Working** | In force, and holding up in practice so far. |
| **Revisiting** | Something has challenged it. Actively being reconsidered. |
| **Replaced** | The problem changed. Points at its replacement and stays for the reasoning trail. |

Status is about the **decision**, not the feature. A decision can be `Working` and deliberately
unbuilt — scope is not a status, so say so in one line under Decision rather than inventing one.

**Confidence** is separate, and is about evidence: `High` (built it, used it, it held), `Medium`
(built it, limited use), `Low` (reasoned about it, haven't felt the consequences). Being honest
here is the whole point — `Working / Low` is a useful signal, not an embarrassment. If nothing in
this directory is ever `Low`, the field has drifted optimistic and stopped carrying information.

## Reviewing

Each record carries a **Last reviewed** date. When you touch an area, glance at its record: if it
still reads true, bump the date; if it doesn't, fix it. A record whose review date is far behind
the code is stale, and a stale document is worse than an absent one.

**What would change our mind** is where a record earns its keep. Hitting one of those conditions
is the cue to reopen the record — not to work around it quietly.

## Writing one

Copy [`0000-template.md`](0000-template.md), take the next free number, and use a short kebab-case
slug: `0007-keyset-pagination.md`. Numbers are allocated in order and never reused. `/adr` does
this for you, including deciding whether to revise an existing record instead.

**Keep it short.** A page is usually enough. A record nobody finishes reading has failed at its
only job.

Do not add process. No approvals, no quorum, no sign-off states. If you changed something
architectural, write down why.

## Index

<!-- Copying this into your own project? Clear the row below. -->

| # | Title |
|---|---|
| [0001](0001-adrs-are-living-documents.md) | An ADR is a living document, and every record names its cost of change |
| [0002](0002-skills-are-scoped-by-repo-intent.md) | A skill is installed per repo, chosen by what the repo is |

Status and Confidence are deliberately **not** duplicated here. A hand-maintained table of them
drifts from the files it describes, and the drift is silent — the record is the single source of
truth. To see the current state of every record at a glance:

```bash
grep -H -e '^- \*\*Status:' -e '^- \*\*Last reviewed:' docs/adr/[0-9]*.md
```

(`0000-template.md` will show its placeholders; everything else is real.)
