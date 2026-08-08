# ADR-0002: Automation is installed per repo, chosen by what the repo is

- **Status:** Working
- **Confidence:** Low
- **Replaces:** —
- **Decided:** 2026-08-08
- **Last reviewed:** 2026-08-08 (revised same day — see Revisions)
- **Issue:** — (no tracker on this repo yet)

## Context

Fifty skills were installed globally in `~/.claude/skills/` (symlinks into `~/.agents/skills/`).
Every one of their descriptions is carried into every session in every repo, whether or not it
could apply. Thirty-two are marketing skills; eleven are Cloudflare; three are Mantine. The repo
where most work actually happens — a Go SQL-builder — is served by none of them.

Two forces made this decidable now rather than later.

**Descriptions are permanently in context; bodies are not.** That asymmetry is the whole design of
skills: long reference material is nearly free, a description is not. Global install spends the
expensive half on skills that cannot fire.

**Personal overrides project.** A skill in `~/.claude/skills/` silently beats one of the same name
in a repo's `.claude/skills/`. So per-repo tuning is inert until the global copy is removed — the
scoping decision cannot be deferred and layered on later.

The closest rejected alternative was keeping everything global and suppressing per repo with
`skillOverrides: "off"`. It lost on defaults: a deny-list means each newly installed skill leaks
into every repo until someone remembers to suppress it, and it does nothing for a teammate, a
cloud agent, or CI, none of which have your home directory. "Do nothing" was live and lost to the
same arithmetic — the cost is silent and recurring, so it never announces the moment to fix it.

## Decision

Skills, commands and agents are installed **per repo, into a committed `.claude/`**, chosen by the
repo's intent rather than by convenience. Global install is reserved for what is useful regardless
of repo content.

The rule cuts differently by artifact type, which is correct rather than inconsistent: skills are
usually domain-shaped and belong to a pack; commands are usually *workflow* — git, session
continuity — and pass the global test honestly; agents are nearly always repo-shaped, because a
reviewer's brief depends on what it reviews.

`packs.md` in this repo is the registry: repo intent → pack → skills, commands and agents, with the
reason each is blessed. It is the central place to consult before installing anything, and it
carries a companion rule on invocation — anything that writes or reaches outward is manual-only —
which is a separate decision about *what may fire*, not about where things live.

What decided it: the primary reader of a repo is increasingly an agent that has only the repo.
Tooling that lives in one machine's home directory is invisible to it.

## Consequences

**Buys.**
- A repo declares its own toolset, so a clone, a cloud agent or CI gets the same one.
- Context is spent on skills that can actually fire.
- A skill with no pack is visibly unjustified, which is a decision prompt rather than a default.

**Costs.**
- **Duplication.** A skill used by four repos exists four times, and updating means re-copying to
  each. There is no `skills` CLI on PATH and no documented project-scope flag, so the fan-out is
  manual and will drift.
- Vendored copies are pinned by accident rather than intent — nothing reports that a repo is three
  versions behind.
- A new repo needs a setup step that global install did not.

## What would change our mind

- skills.sh gaining a project-scope install flag, or its hosted packs turning out to install per
  project — either collapses the manual vendoring and makes most of this cheap.
- Discovering a vendored skill is materially out of date in a way that mattered. That's the
  duplication cost arriving, and it means the registry needs version tracking rather than prose.
- The registry going stale: a new skill installed without being given a pack first means the
  central place is not actually central, and the rule is not being followed.

## Cost of change

Cheap to reverse, expensive to have deferred. Re-installing globally is one `npx skills add` per
skill, and the vendored copies can simply be deleted. What is *not* cheap is the reverse
direction: every week spent globally installed is more repos whose `.claude/` doesn't describe
what they need, and the per-repo audit only gets longer.

Note the asymmetry runs opposite to most decisions here — this one gets **cheaper** to undo over
time and more expensive to keep postponing.

## Open questions I had to answer myself

- Whether `skill-creator` belongs global or in the `meta` pack. Assumed pack, on the rule
  that authoring skills is an activity of some repos rather than all. Debatable; it's the single
  most likely candidate for a second global entry.
- Whether skills.sh's hosted packs install per project. Unverified — the page requires sign-in and
  the CLI docs don't mention them. The registry assumes global and says so. Note this repo borrows
  the *word* "pack" from them for its own groupings while using none of the feature, so the two
  senses will need keeping apart in conversation.
- The eleven Cloudflare skills are absent from `~/.agents/.skill-lock.json`, so their provenance is
  unrecorded and their install can't be reproduced. Assumed they came from somewhere reinstallable.
- Whether four repos × one skill is really the duplication scale. Guessed from the project
  directories present; no count was taken.

## Revisions

- 2026-08-08 — Written.
- 2026-08-08 — Widened from skills to commands and agents. The scoping question turned out to be
  the same one for all three, so this is an edit rather than a new record — the problem didn't
  change, the understanding did. Auditing the nine global commands is what surfaced it: they pass
  the global test where skills mostly don't, which sharpened the rule from "install locally" to
  "scope follows what the artifact depends on". Registry renamed `skills.md` → `packs.md` to match.
