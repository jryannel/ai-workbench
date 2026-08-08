# Agentic Workflow Playbook

A practical guide for growing an automation workflow around Claude Code — starting from commands
and skills, and only climbing to loops and graphs when the work forces it.

Written for a solo product builder / architect who already works this way:
concept → requirements → architecture → ADRs → GitHub issues → implementation → review → ship.

> **The filter for everything in here: does it make the boat faster?**
> Not "is it clever," not "is it the current thing on X." If a piece of automation doesn't
> reduce time-to-first-working-slice or reduce rework, delete it.

---

## Table of contents

1. [The core idea](#1-the-core-idea)
2. [The abstraction ladder](#2-the-abstraction-ladder)
3. [The promotion rule](#3-the-promotion-rule)
4. [Discovery: the friction log](#4-discovery-the-friction-log)
5. [State is the foundation, not the framework](#5-state-is-the-foundation-not-the-framework)
6. [Build order](#6-build-order)
7. [Where a graph actually earns its keep](#7-where-a-graph-actually-earns-its-keep)
8. [Validating any of this, fast](#8-validating-any-of-this-fast)
9. [Anti-patterns](#9-anti-patterns)
10. [Metrics worth tracking](#10-metrics-worth-tracking)
11. [What's in this repo](#11-whats-in-this-repo)

---

## 1. The core idea

Most advice about agent automation is written backwards. It starts with the most sophisticated
structure (multi-agent graphs) and works down. That order produces frameworks nobody uses.

The order that works is the opposite: **automation should accrete from work you were already doing.**
You notice you've typed the same instruction three times, so you make it a command. You notice
you keep correcting the same shape of output, so you write a skill. Each piece exists because
something real demanded it, which is also why each piece survives.

The corollary is uncomfortable but load-bearing: **building an automation framework so you can
later automate things is itself not automation.** It's a project that competes with the boat.
Every abstraction in this playbook should be introduced in response to a count, not in anticipation
of a need.

---

## 2. The abstraction ladder

Four rungs. The useful way to read them is not "increasing sophistication" but
**"what has become stable enough to encode."**

| Rung | Encode when… | What it is | Lives in |
|---|---|---|---|
| **Command** | The *invocation* is stable | A prompt you invoke by name, with arguments | `.claude/commands/*.md` |
| **Skill** | The *format / procedure* is stable | Instructions Claude loads when the task matches | `.claude/skills/<name>/SKILL.md` |
| **Loop** | The *verifier* is stable | Agent iterates until a check passes | Skill + hook + a real test |
| **Graph** | The *routing* is stable | Several specialised nodes, edges, shared state | Subagents + orchestrator |

**Always pick the lowest rung that matches.** A surprising amount of what looks like graph work
is skill work — an SOP written down once, rather than an orchestration layer. Writing the procedure
into a skill and letting one agent follow it is usually cheaper, more debuggable, and more portable
than wiring three subagents together.

### The distinction that matters most: loop vs. graph

A loop is one node with an edge back to itself. A graph is several loops that hand off.
Two consequences:

- **A graph of weak nodes is just slop produced in parallel.** If a single node's loop doesn't
  reliably ship on its own, wiring three together multiplies the unreliability.
- **You cannot skip a rung.** A good graph is full of good loops; a good loop needs good context
  and tools. Skip a lower layer and the top layer fails in a more elaborate, more expensive way.

---

## 3. The promotion rule

Keep the trigger mechanical so you're not negotiating with yourself:

| Observation | Threshold | Promote to |
|---|---|---|
| I typed roughly the same instruction again | 3× | **Command** |
| I corrected the same *shape* of output again | 3× | **Skill** |
| I applied the same accept/reject judgement again | 3× | **Loop** (that judgement is your verifier) |
| I forgot a step that must always happen | 2× | **Hook** |
| I hand-carried output between two different kinds of work | 5× *and* the steps are genuinely parallel or need different tools | **Edge / subagent** |

Two disciplines make this work:

1. **Promote only when the count forces it.** Never in anticipation.
2. **Demote without ceremony.** A command you haven't used in a month is dead weight in your
   context. Delete it. The repo should shrink sometimes.

---

## 4. Discovery: the friction log

You cannot design the right automation from an armchair; you have to observe your own workflow.
The cheapest instrument is a text file.

For two weeks, one line every time you:

- re-explain context Claude should already have had
- re-type a similar instruction
- fix the same class of output problem
- carry an artifact from one step to the next by hand
- catch a mistake you've caught before

Nothing else. No categorising while you log — that biases what you notice. At the end, sort by
frequency and apply the promotion rule. The top three entries are your entire roadmap.

See [`friction-log.md`](friction-log.md) for the template.

**Better: don't rely on remembering.** The log's weak point is that it asks you to stop and write
a line at the exact moment you're mid-task and irritated — which is why most attempts lapse within
days. Claude Code already writes a transcript of every session to `~/.claude/projects/`, and the
same signals are recoverable from it after the fact. `/retro` does that pass and applies the
promotion rule to the result, so discovery costs no discipline at all. Keep the manual log for
friction that never reaches a prompt — a tool that's awkward, a doc you couldn't find.

**Expected result, honestly stated:** most people's top entries are context re-supply, not
orchestration. That's why the first build step below is a file, not a subagent.

---

## 5. State is the foundation, not the framework

The hard part of multi-step agent work is not routing. It is **shared state that survives** — a
durable, inspectable record every step can read and write.

Most people building this from scratch reach for an orchestration framework partly to get
checkpointing. If you already run an ADR process and track work in GitHub issues, **you already
have the state layer**, and it's better than what a framework would give you:

- **Durable** — outlives any context window
- **Inspectable** — you can read it without a debugger
- **Versioned** — it's in git, with history and blame
- **Universally readable** — every node is just an agent that can read markdown and call `gh`

So the rule for every piece of automation you add:

> **Read from the repo. Write back to the repo. Never hold state only in a conversation.**

Each node's contract becomes: *read the relevant ADRs and open issues → do one job → write an
artifact back.* That single convention is what makes later composition possible, and it costs
nothing to adopt today.

### The artifact chain

```
concept.md ──► requirements.md ──► architecture.md ──► ADRs ──► issues ──► code ──► tests
     ▲                                                   │
     └────────────── revisits / replaces ◄──────────────┘
```

The ADRs are the connective tissue: they're the only artifact that records *why*, which is the
context every downstream step needs and the thing most likely to be re-explained by hand.

---

## 6. Build order

Strictly sequential. Do not start step *n+1* before step *n* is boring.

### Step 0 — `CLAUDE.md` (highest payoff, lowest effort)

Before any command or skill: a project memory file pointing at your conventions.

- where ADRs live and how they're numbered
- issue conventions (labels, templates, how an issue links to an ADR)
- the artifact chain and where each document lives
- stack, constraints, and the decisions that are already settled

If your friction log's top entry is context re-supply — and it usually is — this single file is
your biggest available speedup, and it isn't automation at all.

### Step 1 — Commands and skills around ADRs

Highest frequency, most stable format, and ADRs are what everything downstream needs.

- `/adr` — create a correctly numbered ADR from your template, linked to the originating issue
- `/issues-from-adr` — fan a decision out into tracked work
- an **ADR skill** — encodes what a good ADR looks like *for you*: the constraint that actually
  decided it, the costs stated without hedging, what would change your mind, and what reversing
  it would take

Samples for all three are in this repo.

### Step 2 — Concept and architecture skills

Same move, applied to the front of the pipeline: your house format and your standard for
"specific enough to build from."

Then add **one adversarial reviewer skill** that reads a concept or architecture doc and emits
*only* objections, weak assumptions, and unanswered questions — never a rewrite. Read-only is what
makes it worth having; a reviewer that rewrites just launders its own opinions into the artifact.

### Step 3 — One subagent, and make it the reviewer

The smallest possible step past what you do today, on the safest possible task. Read-only tools,
different brief, checks work it did not produce. Separate-reviewer is consistently the
highest-value node in every write-up of this pattern; it also teaches you subagent mechanics with
nothing at risk.

Sample: [`.claude/agents/skeptic.md`](.claude/agents/skeptic.md)

### Step 4 — One hook

For the check you currently forget. Tests before a handoff; ADR link present before an issue
closes; lint before commit. Hooks are the cheapest reliability win available, because they turn
"the agent usually does X" into "X always happens."

### Step 5 — A graph, maybe

Only if [section 7](#7-where-a-graph-actually-earns-its-keep) describes your actual situation.

**Honest expectation:** steps 0–4 capture most of the available gain for a solo builder. Graphs
are the last rung for a reason, and you may never need them.

---

## 7. Where a graph actually earns its keep

A graph needs three things at once: **separable work**, **a check that a different node can
perform**, and **enough volume that coordination overhead amortises**. Most steps fail at least one.

### Your pipeline, honestly assessed

`concept → requirements → architecture → implementation` is a **chain**, not a graph. The
graph-ness lives in exactly three places:

| Where | Shape | Verdict |
|---|---|---|
| Competitor / baseline research | Fan-out → skeptic → synthesiser | **Genuine graph.** Real parallelism, real separable check |
| Distil steps (requirements, architecture) | Reviewer node | **Not a graph** — it's a read-only reviewer on a chain |
| Implement ↔ validate | Conditional loop-back edge | **A loop**, and it's already how you work |
| Everything else | Sequential | Keep it a chain |

### The chain's two failure modes

**Compounding.** Ten steps at 90% each is 35% end to end. Worse, errors get *laundered* — a wrong
assumption in requirements arrives at architecture as established fact and becomes invisible.

**No verifier until the end.** In a coding task the test runner tells you the truth at every step.
In concept→architecture work nothing is decidable until code runs, many steps downstream.

**The fix for both is the same:** make each artifact's validity decidable *by the next node.*

> Requirements are good if the architecture step can proceed without inventing anything.
> Architecture is good if the implementation step doesn't have to guess.

So instrument for it: have every step emit an explicit **`## Open questions I had to answer myself`**
section. A step that guessed five times is telling you the *upstream* artifact failed — and it tells
you now, not nine steps later. This is the single highest-value instrumentation in the whole
pipeline and it costs one heading.

### Two things stay human

- **Hard gates after requirements and after architecture.** Not review-if-convenient — actual stops.
  These are the two places where a wrong turn is cheap to fix and everything downstream is where
  it isn't.
- **The twist.** Automate the research that feeds it and every artifact downstream of it, but the
  vision-with-a-differentiator is the product. An agent handed three competitor teardowns will
  produce their *average*, confidently. That failure has the worst
  payoff-to-detectability ratio in the entire workflow.

### Cost, stated plainly

Multi-agent setups buy quality and parallelism with tokens and coordination overhead. Anthropic's
own multi-agent research system reported a large quality gain over a single-agent baseline at
roughly **15× the tokens** of a normal chat turn, with early orchestrator versions over-spawning
subagents. Measure cost on your *real* task distribution, not on the hardest case you can imagine —
graphs look great on the pathological example and burn tokens on the 80% that were always one loop.

---

## 8. Validating any of this, fast

Fake the graph before you build it. All of this is a day, not a sprint.

1. **Get a gold set first.** 5–10 real tasks where you already know what good looks like. Fewer
   than five and you're measuring noise; toy tasks and you're measuring nothing. If you can't
   assemble this, stop — you have no way to tell whether anything you build helps.
2. **Write the rubric before you see output.** 3–5 *binary* checks ("every claim has a source",
   "no invented figures", "runs without edits", "covers all four sections"). Binary matters:
   "seems better" is why most productivity claims are unfalsifiable. Set the pass bar now too
   (e.g. must win 7 of 10 at under 3× the cost).
3. **Run an honest baseline.** One well-scoped agent, one loop, a real verifier — not a strawman.
   Record output, tokens, wall-clock. Rigged baselines are the main reason people "prove" the
   graph won.
4. **Hand-run the graph in separate chat windows,** copy-pasting state yourself. No subagents, no
   framework. This is the step that saves days: if the pattern doesn't beat the baseline when
   *you* are routing perfectly, it will not beat it once an orchestrator is making those calls.
   Orchestration adds failure modes; it doesn't add quality.
5. **Grade blind.** Strip labels, shuffle, score against the rubric.
6. **Ablate before committing.** Test *loop + reviewer* as its own arm. If that captures most of
   the improvement, you don't need a graph — you need a second pass, and you just avoided building
   an org chart to answer an email.

### Validating the full pipeline

Don't run the whole chain against a synthetic gold set. **Use your own shipped projects.** Feed a
real past concept in and check whether the pipeline re-derives the requirements, architecture and
decisions you actually landed on. The ground truth is already sitting in your git history and ADRs.
Deltas are the interesting part: some will be the pipeline being wrong, some will be it catching
something you missed. Both are worth knowing.

Then validate **node-pairs**, not the chain: requirements→architecture, architecture→implementation.
Fix the worst handoff before wiring anything together.

Keep the gold set and rubric afterwards as regression tests — they're what tells you whether a
prompt tweak six weeks from now actually helped.

---

## 9. Anti-patterns

| Anti-pattern | Why it bites |
|---|---|
| **Framework-first** | Building orchestration before you have a workflow worth orchestrating |
| **The meta-project** | Automating your automation setup instead of shipping the product |
| **Nodes that aren't specialties** | "Steps I could inline" are not nodes. If collapsing five nodes back into one loop loses nothing, collapse them |
| **Self-verification** | An agent grading its own work has no independent signal. The reviewer must be a different node with a different brief |
| **Reviewer with write access** | It stops reviewing and starts rewriting; you lose the check and gain an opinion |
| **State only in the conversation** | Nothing is inspectable, resumable, or diffable when it goes wrong |
| **Distil = compress** | Summarising makes error-laundering *worse*. Distil steps must be adversarial, not shorter |
| **Unbounded spend** | A graph is many loops; a weak verifier burns tokens in parallel. Cap it |
| **Anticipatory abstraction** | Every rung you climb before the count forces it is overhead you now maintain |
| **Never demoting** | Dead commands and stale skills are context pollution with a maintenance cost |

---

## 10. Metrics worth tracking

Two numbers, tracked roughly, beat ten tracked precisely:

1. **Time from concept to first working slice.**
2. **Rework rate** — how often you redo an artifact because an upstream one was wrong.

Optionally, once you're running loops: **tokens per shipped artifact**, to catch the case where
quality held steady and cost quietly tripled.

If a piece of automation doesn't move (1) or (2) within a couple of real projects, delete it.
That is the whole boat test, operationalised.

---

## 11. What's in this repo

```
.
├── README.md                          ← this playbook
├── CLAUDE.md                          ← conventions for working on this repo
├── friction-log.md                    ← manual discovery template (see /retro first)
├── CLAUDE.md.example                  ← project memory starting point
├── docs/
│   └── adr/
│       ├── README.md                  ← when to write one, status vocabulary, index
│       ├── 0000-template.md           ← ADR template
│       └── 0001-…-living-documents.md ← why this template departs from Nygard
└── .claude/
    ├── commands/
    │   ├── adr.md                     ← /adr — create a numbered ADR
    │   ├── issues-from-adr.md         ← /issues-from-adr — fan a decision into work
    │   └── retro.md                   ← /retro — mine transcripts for what to build or delete
    ├── skills/
    │   └── adr-writing/SKILL.md       ← what a good ADR looks like
    └── agents/
        └── skeptic.md                 ← read-only reviewer subagent
```

**How to use it:** copy the pieces you want into your own project. The samples are deliberately
opinionated so they're worth editing — the point is that they encode *your* conventions, and a
generic version of them would be worth nothing. (`CLAUDE.md` is the exception: it's this repo's
own memory, for agents editing the playbook. The one to copy is `CLAUDE.md.example`.)

**Suggested first session:** write `CLAUDE.md`, copy the ADR command + skill, start the friction
log. Come back in two weeks with data and let the log tell you the second step.

---

### Further reading

- Anthropic — [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents):
  prompt chaining, routing, parallelisation, orchestrator-workers, evaluator-optimizer
- Anthropic — [How we built our multi-agent research system](https://www.anthropic.com/engineering/built-multi-agent-research-system):
  the pattern *and* its cost, honestly reported
- [Claude Code subagents documentation](https://code.claude.com/docs/en/sub-agents)
- Michael Nygard — the original ADR format. The template here deliberately departs from it:
  records are living documents rather than immutable ones, and carry a *Cost of change*. The
  reasoning is in ADR-0001 and in the `adr-writing` skill

*Caveat on the discourse: "graph engineering" trended in mid-2026, but the mechanics — directed
graphs of states and transitions, orchestration engines, agent-to-agent delegation — are decades
old, and frameworks like LangGraph, AutoGen GraphFlow and Google ADK implemented them before the
term existed. The label is optional. The escalation from one loop to coordinated nodes is real.
Just don't reach for it before the work forces your hand.*
