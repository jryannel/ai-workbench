---
name: skill-writing
description: Write or revise a skill, command, or hook in .claude/. Use when adding a new automation to a project, when an existing skill fires at the wrong times or never fires at all, when deciding whether something should be a command, a skill, or a hook, or when a section of CLAUDE.md has grown into a procedure.
---

# Writing skills

A skill is a procedure you would otherwise paste into chat. It earns its place when the
**procedure** has stabilised — not when the topic has.

## Pick the rung before writing anything

Commands and skills are the same mechanism: `.claude/commands/foo.md` and
`.claude/skills/foo/SKILL.md` both produce `/foo`. What differs is who pulls the trigger, and
that's one line of frontmatter. So the only decision that actually matters is this one:

| If the thing… | Write a… |
|---|---|
| is invoked deliberately, by you, at a moment you choose | **command** (`disable-model-invocation: true`) |
| should apply whenever the task matches | **skill** (leave model invocation on) |
| **must always happen**, with no exceptions | **hook** |

The third row is the one people get wrong. A skill saying "you MUST always verify before claiming
done" is a *request* — it competes with everything else in context and loses on a long turn. The
same rule as a `PreToolUse` hook either opens the gate or doesn't. **If you find yourself writing
absolutes, you have written the wrong artifact.** See
`.claude/hooks/verify-before-commit.sh` for the shape.

## The description is a trigger, not documentation

It is the only part loaded before the skill runs, so it's doing all the matching work. Write the
**conditions**, not the contents.

- Start with "Use when…" and name concrete situations, including the phrases you'd actually type.
- Third person. Not "I help you write ADRs" but "Write, review and supersede ADRs".
- **Do not summarise the workflow in the description.** If the steps appear there, they get
  followed from the summary and the body is never read — you get a worse version of your own
  procedure, and it looks like the skill is bad rather than the description.
- Name the technology only if the skill is genuinely specific to it.

```
❌ description: Helps with database stuff
❌ description: First runs migrations, then checks the schema, then reports drift
✅ description: Diagnose schema drift between migrations and a live database. Use when
   migrations and the deployed schema disagree, after a failed deploy, or when someone asks
   "why is this column missing".
```

`description` plus `when_to_use` is truncated at 1,536 characters in the listing, so put the
distinguishing case first. Every skill's description is in context permanently — the body is not.
That asymmetry is the whole design: **long reference material is nearly free, a vague description
is not.**

## Keep the body short

Load-bearing content only. Reference material, examples and long tables go in sibling files the
skill points at, so they cost nothing until needed. A body nobody finishes has failed the same way
an unread ADR has.

## Write for composition

Your skill runs alongside other skills, `CLAUDE.md`, and the user's own instructions. Anything
written as though it were the only thing in context degrades the rest:

- No `EXTREMELY IMPORTANT`, no all-caps mandates, no "this is not negotiable". If two skills both
  claim absolute priority, nothing resolves the conflict — and treating everything as critical
  means nothing is.
- Don't instruct the model to ignore or outrank user instructions.
- Don't demand invocation before clarifying questions. A one-line answer should stay a one-line
  answer; the lowest rung that matches is still the rule.

Emphasis is a budget. Spend it on the one or two things that actually break.

## Test the trigger before trusting it

A skill that never fires and a skill that fires constantly look identical from the inside — both
present as "the prompt is bad". Check it directly:

1. Start a fresh session and type the phrasing you expect users to use. Did it load?
2. Type something adjacent but out of scope. Did it stay out?
3. If it fires when it shouldn't, the description is too broad — narrow the conditions rather than
   adding "only use this when…" to the body, which is read too late to help.

## Never

- **Never write a skill for something that must always happen.** That's a hook.
- **Never let the description drift from the body.** The description is a promise about what the
  body does; when they disagree, the skill fires for the wrong tasks.
- **Never add a rung you haven't earned.** Three repetitions, then encode it. Anticipated
  automation is maintenance you took on for a need that hasn't arrived.
- **Never keep a skill you don't invoke.** A dead skill costs context on every session and pays
  nothing. Deleting is a success condition.
