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
README.md                       the playbook     friction-log.md    discovery template
CLAUDE.md                       this file        CLAUDE.md.example  for consumer projects
packs.md                        which repo gets which automation (ADR-0002)
docs/adr/                       decisions about this repo (0000-template.md is the template)
.claude-plugin/marketplace.json this repo as an installable marketplace (two plugins)
plugins/workbench/              project-scope plugin — the playbook's samples
  commands/                     /adr, /issues-from-adr, /retro
  skills/                       adr-writing, automation-design
  agents/                       skeptic (read-only reviewer)
  hooks/                        verify-before-commit.sh (inert here — no test gate to run)
plugins/workflow/               user-scope plugin — worktree git flow, handoff/pickup
  commands/                     git-{worktree,status,sync,checkpoint,ship,undo}, handoff, pickup
.claude/settings.json           this repo installing workbench at project scope
```

**The automation lives in `plugins/`, not `.claude/`.** This repo is a marketplace, and it
dogfoods itself: `.claude/settings.json` declares the marketplace as `.` and enables
`workbench@ai-workbench`. Two consequences:

- **Editing a file under `plugins/workbench/` changes the published plugin.** It is picked up from
  the working tree, so a local edit is live in the next session — but it's also what a consumer
  installs. Treat it as an edit to the README.
- **`.claude/settings.json` must keep the relative `"path": "."`.** `claude plugin marketplace add`
  rewrites it to an absolute `/Users/…` path, which would break every other machine. If you re-run
  that command, fix the path before committing.

**README section 11 is the manifest.** If you add, move or delete a file, update that tree in the
same commit or the playbook starts lying about itself.

Cross-references that break silently if a file moves:

- `README.md` links `friction-log.md`, `plugins/workbench/agents/skeptic.md`,
  `plugins/workbench/hooks/`, `docs/adr/0000-template.md`
- `plugins/workbench/commands/adr.md` hardcodes `docs/adr/0000-template.md` and `NNNN-kebab-case`
- a skill's directory name must match its frontmatter `name:` (`adr-writing`)
- `.claude-plugin/marketplace.json` hardcodes `./plugins/workbench` and `./plugins/workflow`; each
  `plugin.json` version and its marketplace entry's version must agree
- `workflow`'s git commands are opinionated about a **worktree** flow and conflict with
  `git@devproc`'s feature-branch flow. Don't reconcile them by editing one — they're alternatives.
  See the note in `packs.md`.

## Conventions

### Decisions

This repo follows its own process. Use `/adr` for decisions about the workbench — what belongs in
it, what gets cut, structural changes. Numbering starts at `0001`; `0000-template.md` is the
template.

Records are living documents: edit in place when understanding improves and add a Revisions line.
A new record is only for when the *problem* changed. See `plugins/workbench/skills/adr-writing/SKILL.md` —
which is also the guidance being published, so changing how ADRs work here changes what readers
are told to do.

### Skills

Pack: `meta` (see `packs.md`). Blessed here:

| Skill | Why |
|---|---|
| `adr-writing` | This repo records its own decisions as ADRs |
| `automation-design` | Choosing command / skill / hook / agent — the shape question |

Both ship *in* `workbench@ai-workbench`, so editing them edits the product.

`skill-creator` is **not vendored** — it was, for one afternoon, and that was a mistake: it's
available as a plugin from the `anthropic-skills` marketplace, so vendoring paid context twice for
a pinned copy nobody needed. Install the plugin if you're authoring skills here.

It answers *how to write it*; `automation-design` answers *what shape it should be*. If they ever
overlap again, narrow `automation-design` — `skill-creator` is upstream and wins.

Deliberately absent: everything else in `~/.agents/skills/`. This repo is documentation, so the
Cloudflare, Mantine and marketing sets have no purchase here.

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
