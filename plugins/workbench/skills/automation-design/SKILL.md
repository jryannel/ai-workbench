---
name: automation-design
description: 'Decide what shape a piece of automation should take — command, skill, hook, or agent — and where it should live. Use when an instruction keeps getting ignored or restated, when deciding whether something belongs in CLAUDE.md or its own file, when a repeated procedure looks ready to encode, or when a skill fires at the wrong times. Differentiator: this answers what shape to build and where it lives; skill-creator authors and evaluates the skill once the shape is settled.'
---

# Choosing the shape

This skill answers *what kind of thing should this be, and where does it live*. Once that's
settled, `skill-creator` does the authoring, the evals, and the description tuning — it's better
at all three than anything written here.

## Pick the rung

Commands and skills are the same mechanism: `.claude/commands/foo.md` and
`.claude/skills/foo/SKILL.md` both produce `/foo`. What differs is who pulls the trigger, and
that's one line of frontmatter. So the real decision is this:

| If the thing… | Write a… |
|---|---|
| is invoked deliberately, by you, at a moment you choose | **command** (`disable-model-invocation: true`) |
| should apply whenever the task matches | **skill** (leave model invocation on) |
| **must always happen**, with no exceptions | **hook** |
| needs a different brief and its own context to judge work | **agent** |

Always take the lowest rung that matches. Most things that look like they need an agent are a
skill; most things that look like they need a skill are a line in `CLAUDE.md`.

## The hook test

The third row is the one people get wrong, and it has a tell.

**If you find yourself writing absolutes — MUST, ALWAYS, "this is not negotiable" — you have
written the wrong artifact.** A skill saying "always verify before claiming done" is a *request*.
It competes with everything else in context and loses on a long turn, right when it matters. The
same rule as a `PreToolUse` hook either opens the gate or doesn't.

Prose asking a model not to rationalise is the weakest possible enforcement of a rule you believe
is absolute. See `.claude/hooks/verify-before-commit.sh` for the shape.

## Write for composition

Your automation runs alongside other skills, `CLAUDE.md`, and the user's own instructions.
Anything written as though it were alone in context degrades everything else:

- No `EXTREMELY IMPORTANT`, no all-caps mandates. If two skills both claim absolute priority,
  nothing resolves the conflict — and treating everything as critical means nothing is.
- Don't instruct the model to ignore or outrank user instructions.
- Don't demand invocation before clarifying questions. A one-line answer should stay a one-line
  answer.

Emphasis is a budget. Spend it on the one or two things that actually break.

## Name what it isn't

The description is the only part loaded before the model decides whether to open the artifact, so
two things describing overlapping territory compete on every turn with nothing to resolve them.
This repo shipped that failure: a `skill-writing` skill sitting next to `skill-creator`, both
plausibly matching "create a skill". Renaming fixed it; a differentiator would have prevented it.

End the description with an explicit contrast against the nearest neighbour:

```
Differentiator: this answers what shape to build; skill-creator authors it once the shape is settled.
```

Add one only where something else could plausibly claim the same request. A differentiator against
an artifact nobody would confuse it with is noise, and emphasis is a budget.

Two mechanical rules come with it:

- **Quote the value.** A mid-sentence `: ` makes the description invalid YAML under a strict
  parser, which reads it as a nested mapping. Claude Code is lenient and accepts it; a stricter
  runtime rejects the file and the artifact silently never loads. Single-quote the whole value and
  double any inner apostrophe — `doesn''t`.
- **Say *what* and *when*, never *how*.** A description that summarises the steps invites the model
  to follow the summary instead of opening the body. It answers "should I open this now?", not
  "what are the steps?"

## Then decide scope and trigger

Both are covered by `packs.md`, and both are easy to get wrong:

- **Scope follows what the artifact depends on.** Domain-shaped → the repo, committed. Workflow
  that applies regardless of repo content → global. Remember personal overrides project, so a
  global copy silently beats a repo one of the same name.
- **Anything that writes or reaches outward is manual.** `disable-model-invocation: true` on
  anything that commits, pushes, opens a PR, deletes, or spends. The test isn't "is it dangerous"
  but *"would I be surprised to find it had happened?"*

## Never

- **Never write a skill for something that must always happen.** That's a hook.
- **Never add a rung you haven't earned.** Three repetitions, then encode it. Anticipated
  automation is maintenance taken on for a need that hasn't arrived.
- **Never keep automation you don't invoke.** It costs context every session and pays nothing.
  `/retro` will tell you which ones those are. Deleting is a success condition.
