# CLAUDE.md — ai-workbench

## What this project is

A playbook for growing a Claude Code automation workflow, plus the sample commands, skills and
agents it describes. The deliverable is **documentation and prompts** — there is no application,
no build, no test suite. "Does it work" means "does a person or agent reading this do the right
thing."

Read `README.md` before changing anything. It is the playbook; this file is only the conventions
for working *on* it.

> The filter for every change: **does it make the boat faster?** Automation that doesn't reduce
> time-to-first-working-slice or rework gets deleted, including from this repo.

## The thing that makes this repo unusual

`.claude/` is **both live tooling and sample content.** The commands, skill and agent here are
loaded into any session in this directory *and* are what a reader copies into their own project.

Two consequences:

- Edit them for the **consumer**, not for this repo. They should stay opinionated (a generic
  version is worth nothing) but must not depend on anything specific to ai-workbench.
- Changing one is a change to published guidance, not a local tweak. Treat it as an edit to the
  README.

`CLAUDE.md.example` is a *third* thing: a starting point for a consumer's product repo. It is not
this file, it is not synced with this file, and the two should be allowed to diverge freely.

## Layout

```
README.md              the playbook          friction-log.md      discovery template
CLAUDE.md              this file             CLAUDE.md.example    for consumer projects
packs.md               which repo gets which skills, commands and agents (ADR-0002)
docs/adr/              decisions about this repo (0000-template.md is the template, not an ADR)
.claude/commands/      /adr, /issues-from-adr, /retro
.claude/skills/        adr-writing, skill-writing
.claude/hooks/         verify-before-commit.sh (inert here — no test gate to run)
.claude/settings.json  wires the hook up; live in this repo, and a sample for consumers
.claude/agents/        skeptic (read-only reviewer)
```

**README section 11 is the manifest.** If you add, move or delete a file, update that tree in the
same commit or the playbook starts lying about itself.

Cross-references that break silently if a file moves:

- `README.md` links `friction-log.md`, `.claude/agents/skeptic.md`, `docs/adr/0000-template.md`
- `.claude/commands/adr.md` hardcodes `docs/adr/0000-template.md` and the `NNNN-kebab-case` format
- a skill's directory name must match its frontmatter `name:` (`adr-writing`)

## Conventions

### Decisions

This repo follows its own process. Use `/adr` for decisions about the workbench — what belongs in
it, what gets cut, structural changes. Numbering starts at `0001`; `0000-template.md` is the
template.

Records are living documents: edit in place when understanding improves and add a Revisions line.
A new record is only for when the *problem* changed. See `.claude/skills/adr-writing/SKILL.md` —
which is also the guidance being published, so changing how ADRs work here changes what readers
are told to do.

### Prose

The docs have a deliberate voice — match it rather than normalising it:

- **British spelling** (`categorising`, `amortises`, `favoured`)
- Claims are load-bearing and hedged honestly. If you can't source a number, say so; the README
  criticises invented rationale at length and must not contain any.
- Tables for anything with a threshold or a verdict. Prose for anything with a why.
- No new marketing register. The whole document's credibility rests on it stating costs plainly.

### Commits

Conventional commits: `docs(scope): …`, `feat(scope): …`. Most changes here are `docs`.

## Working agreements

- **Prefer deleting.** A shrinking `.claude/` is a success condition. If a sample no longer earns
  its place, cut it and remove it from README section 11.
- **Don't add a rung the repo hasn't earned.** No hooks, subagents or orchestration in here unless
  the playbook argues for that specific thing — shipping unearned abstraction while telling readers
  not to would be self-refuting.
- **Surface guesses.** End any substantial artifact with
  `## Open questions I had to answer myself`.
- **Don't invent requirements or rationale.** Flag the gap instead.
- **Ask before scope expansion.** Doing more than asked is a cost, not a bonus.
