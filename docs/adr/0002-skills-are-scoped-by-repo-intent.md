# ADR-0002: Automation is installed per repo, chosen by what the repo is

- **Status:** Working
- **Confidence:** Medium
- **Replaces:** —
- **Decided:** 2026-08-08
- **Last reviewed:** 2026-08-08 (revised twice same day — see Revisions)
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

Skills, commands and agents are installed **per repo, chosen by the repo's intent** rather than by
convenience. Global install is reserved for what is useful regardless of repo content.

**The mechanism is Claude Code's plugin system.** A pack is a plugin: `claude plugin install
<name>@<marketplace> --scope project` writes `enabledPlugins` into the repo's committed
`.claude/settings.json`. Hand-copying into a committed `.claude/` is the fallback, used only where
no plugin exists — which today means most skills.sh content.

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
- A new repo needs a setup step that global install did not — now two commands rather than a
  copy-and-prune ritual.
- The marketplace body lives in `~/.claude/plugins/`, not the repo. What travels is the
  *declaration*. A fully offline clone gets the settings but must still fetch the plugin, where a
  vendored copy would have been self-contained.
- `claude plugin marketplace add` writes an **absolute path** for a directory source. Committing
  that breaks every other machine; it has to be hand-corrected to a relative path.
- **Where no plugin exists, the original costs stand in full:** a skill used by four repos exists
  four times, updating means re-copying to each, and vendored copies are pinned by accident rather
  than intent. This is now the exception rather than the rule, but it still covers the Cloudflare,
  Mantine and marketing sets.

## What would change our mind

- ~~skills.sh gaining a project-scope install flag~~ — **this fired**, via Claude Code's plugin
  system rather than skills.sh. See the second revision below.
- The plugin cache proving unreliable offline, or a marketplace going away and taking a repo's
  toolset with it. That's the argument for vendoring returning, and it would be a real one.
- Discovering a vendored skill is materially out of date in a way that mattered — still live for
  everything with no plugin.
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
- ~~Whether skills.sh's hosted packs install per project.~~ Moot: the plugin system does, so the
  question stopped mattering before it was answered.
- Whether the plugin cache is safe to depend on. Not tested offline, not tested on a cold CI
  runner. The decision assumes a fetch is available at setup time; if that's wrong, vendoring comes
  back for anything that has to work air-gapped.
- Whether one `workbench` plugin is the right granularity, or whether ADR tooling and
  automation-design should ship separately. Assumed one, because they're always wanted together in
  practice. Splitting later is cheap; a consumer who wants only `/adr` currently pays for all of it.
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
- 2026-08-08 — **Mechanism replaced: packs are plugins.** The *What would change our mind* clause
  above fired within a day, from an unexpected direction. Claude Code's plugin system already
  provides everything the hand-rolled scheme was reaching for — `--scope project` install written
  into committed settings, namespacing that removes the personal-overrides-project trap entirely,
  central update with no fan-out, and `claude plugin details` to price a plugin's always-on context
  instead of arguing about it in prose.

  Found by looking in `~/.claude/plugins/`: `valiro-ai/devproc` has been running this way since
  January, with `git@devproc` and `sep@devproc` scoped to a single project. The decision this record
  describes was reinvented in ignorance of a working example on the same machine. That is the
  failure worth recording — the audit that produced this ADR read `~/.claude/skills/` and
  `~/.agents/`, and never checked what else the tool already did.

  Still an edit, not a new record: the problem is unchanged and the ruling — *scope follows repo
  intent* — survives intact. Only the implementation was wrong. `packs.md` rewritten accordingly,
  and this repo now ships its automation as `workbench@ai-workbench`, installing its own plugin at
  project scope.
