# Pack registry — what to install where

The central answer to "what does *this* repo need?" A repo's **intent** decides its pack; the pack
decides its skills, commands and agents.

A **pack** is the set of automation blessed for one kind of repo. **Where one exists as a plugin,
the pack _is_ the plugin** — Claude Code's plugin system implements this natively, and hand-rolling
it was a mistake this file made for one day. A plugin bundles commands, skills, agents, hooks and
MCP servers under one name, installs per project, is namespaced, and updates from a single source.

The word was originally borrowed from [skills.sh](https://www.skills.sh/packs). Keep it: it still
names the grouping for third-party skills that *aren't* published as plugins, which is the only
place manual vendoring survives.

> **Why this file exists:** anything installed globally is loaded into every session in every repo,
> and its description occupies context permanently whether or not it's relevant. Fifty global
> skills means fifty descriptions carried into a Go library that needs none of them.

---

## Rule 1 — scope follows repo intent

**Install globally only what is useful regardless of what the repo contains.** Domain-shaped
automation belongs to a pack.

| Scope | Lives in | For |
|---|---|---|
| **Global** | `~/.claude/…`, or a plugin at user scope | Useful in every repo, whatever it holds |
| **Pack** | a plugin enabled at `--scope project`, committed | Everything domain-shaped |
| **Vendored** | `<repo>/.claude/…`, committed | Domain-shaped, but no plugin exists for it |
| **Never** | — | Installed "just in case" |

The rule cuts differently by artifact type, and that's correct rather than inconsistent:

- **Skills** are usually domain-shaped — Cloudflare, Mantine, SEO. Almost all belong to a pack.
- **Commands** are usually *workflow* — git operations, session continuity. These pass the global
  test honestly, because git is present regardless of what the repo contains.
- **Agents** are nearly always repo-shaped, since a reviewer's brief depends on what's being
  reviewed. Keep them in the repo.

### The trap — and why plugins avoid it

**Personal overrides project.** A skill in `~/.claude/skills/` silently wins over the same name in
a repo's `.claude/skills/`, so a vendored copy is inert until the global one is removed. Pruning
globals is what makes *vendoring* work at all.

**Plugins don't have this problem.** They're namespaced — `workbench@ai-workbench`,
`review@devproc` — so two copies coexist visibly instead of one silently shadowing the other. That
removes the single sharpest edge in this file, and it's most of why plugins win.

The residual risk is duplication rather than shadowing: enable a marketplace plugin *and* vendor
the same skill, and you pay context for both. `claude plugin details <plugin>` prices it.

### Why committed, not symlinked

A symlink into `~/.agents/` works only on your machine. Committed config travels: a teammate
cloning, a cloud agent, CI, a fresh laptop. Same reasoning as committing handoff docs — state
lives in the repo, not in one machine's home directory.

This applies to the *declaration*, not the payload. A plugin enabled at `--scope project` writes
`enabledPlugins` into `.claude/settings.json`, which is committed and travels; the plugin body
stays in the marketplace cache. One caveat, learned the hard way: `claude plugin marketplace add`
records an **absolute path** for a directory source. Committing that breaks every other machine —
rewrite it to a relative path, or use the `owner/repo` form.

---

## Rule 2 — anything that writes or reaches outward is manual

Scope decides *where* automation lives. This decides *what may fire without you*.

By default Claude can invoke any skill or command whose description matches. That is right for
read-only and advisory work, and wrong for anything that commits, pushes, opens a PR, creates
issues, deletes, or spends real money. `allowed-tools` compounds it: those tools are pre-approved
for the turn that invokes the automation, so a self-invoked command can act without a prompt.

```yaml
disable-model-invocation: true
```

| Then | Example |
|---|---|
| **Guard it** — writes, pushes, deletes, spends | `/git-ship`, `/git-undo`, `/git-checkpoint`, `/handoff`, `/issues-from-adr`, `/retro` |
| **Leave it open** — read-only or advisory | `/git-status`, `adr-writing`, `skeptic` |

The test is not "is it dangerous" but **"would I be surprised to find it had happened?"**

---

## Global — install everywhere

| What | Why global |
|---|---|
| `find-skills` (skill) | Answers "is there a skill for this?" in any repo. Bootstraps this file. |
| `git-*` (commands) | Workflow, not domain — every repo is a git repo |
| `handoff`, `pickup` (commands) | Session continuity is repo-independent |
| `plan-fable` (command) | Delegation pattern, repo-independent |

No global agents. A reviewer's brief depends on what it's reviewing.

> **These nine are loose files in `~/.claude/commands/`, and shouldn't be.** They pass the global
> test on *scope*, but they're still hand-maintained on one machine — invisible to a teammate, a
> cloud agent or CI, which is the same objection this file raises against everything else. Packaging
> them as a `workflow` plugin installed at user scope keeps the scope and fixes the portability.
> Not done yet; it's the obvious next move after ADR-0002's revision.

---

## Packs

Pick the one matching what the repo *is*. A repo may take more than one.

### `meta` — repos that author agent tooling
*ai-workbench, plugin repos, anything with a `.claude/` you maintain rather than merely use.*

All three are plugins. Nothing in this pack needs vendoring.

| Install | Gives you |
|---|---|
| `workbench@ai-workbench` | `/adr`, `/issues-from-adr`, `/retro`, `adr-writing`, `automation-design`, `skeptic`, the commit gate — ~544 always-on tok |
| `anthropic-skills` marketplace | `skill-creator` — authoring, evals, description optimisation |
| `plugin-dev@claude-plugins-official` | Plugin structure, hooks, MCP, agent and command authoring — ~2,349 always-on tok |

`skill-creator` and `automation-design` divide cleanly: the first is *how to write it*, the second
is *what shape it should be*. If they drift back into overlap, narrow `automation-design` —
`skill-creator` is upstream and wins.

`plugin-dev` is the expensive one. Worth it while you're building plugins; disable it when you
aren't, which is what `--scope project` is for.

> **Check for a plugin before vendoring.** Vendoring `skill-creator` into a repo that also enables
> `anthropic-skills` carries it twice, paying context for both. This repo did exactly that for an
> afternoon before the plugin route was found.

### `cloudflare-worker` — Workers, Pages, D1/KV/R2

`agents-sdk` · `cloudflare` · `cloudflare-email-service` · `cloudflare-one` ·
`cloudflare-one-migrations` · `durable-objects` · `sandbox-sdk` · `turnstile-spin` ·
`workers-best-practices` · `wrangler`

> Source unrecorded — these are not in `~/.agents/.skill-lock.json`, so the install can't currently
> be reproduced. Confirm the upstream before relying on this row.

### `web-ui` — anything with a front end

| Skill | Source |
|---|---|
| `frontend-design` | `anthropics/skills` (also `frontend-design@claude-plugins-official` — pick one) |
| `web-perf` | arrived with the Cloudflare set; not Cloudflare-specific |
| `mantine-combobox`, `mantine-custom-components`, `mantine-form` | `mantinedev/skills` — only where Mantine is actually used |

### `marketing-site` — sites whose job is acquisition

All 32 from `coreyhaines31/marketingskills`: `ab-test-setup` `ad-creative` `ai-seo`
`analytics-tracking` `churn-prevention` `cold-email` `competitor-alternatives` `content-strategy`
`copy-editing` `copywriting` `email-sequence` `form-cro` `free-tool-strategy` `launch-strategy`
`marketing-ideas` `marketing-psychology` `onboarding-cro` `page-cro` `paid-ads`
`paywall-upgrade-cro` `popup-cro` `pricing-strategy` `product-marketing-context`
`programmatic-seo` `referral-program` `revops` `sales-enablement` `schema-markup` `seo-audit`
`signup-flow-cro` `site-architecture` `social-content`

Install the whole set only where the repo's *purpose* is marketing. In a product repo that happens
to have a pricing page, take `page-cro` and `copywriting` alone.

### `go-service` — Go libraries and services
*sqlb, valiro-go.*

**None.** Nothing in the current 50 targets Go. Worth stating plainly: the repo where most of the
work happens needs none of the skills that were installed globally for its benefit.

### On demand, no pack

`excalidraw-diagram-generator` — install in whichever repo is producing diagrams that week.

---

## Installing into a repo

### If it's a plugin — the default

```bash
claude plugin marketplace add <owner>/<repo>          # once per machine
claude plugin install <name>@<marketplace> --scope project
```

`--scope project` writes `enabledPlugins` into the repo's `.claude/settings.json`. Commit it, and a
clone, a cloud agent or CI gets the same toolset with no copying. Check the price before you commit
to it:

```bash
claude plugin details <name>@<marketplace>
```

That reports always-on token cost per component — the number this whole file is an argument about.
Anything over a few hundred always-on tokens for a plugin you rarely invoke is a deletion
candidate.

**Updating:** `claude plugin update`. One source, no fan-out. This is the difference that made the
hand-rolled approach not worth keeping.

### If there's no plugin — vendor it

Still the case for most skills.sh content: the Cloudflare, Mantine and marketing sets ship as skill
repos, not marketplaces.

```bash
npx skills add <owner>/<repo>                    # fetches to ~/.agents/skills/, symlinks globally
cp -R ~/.agents/skills/<name> .claude/skills/<name>
git add .claude/skills/<name> && git commit -m "chore: vendor <name>"
rm ~/.claude/skills/<name>                       # required — or the global copy wins
```

That last line is not optional: personal overrides project, so the vendored copy is inert until the
global symlink is gone. Updating means re-running `npx skills add` and re-copying into every repo
that vendors it — the fan-out cost that plugins eliminate. If you're doing this for more than two
repos, package the skills into your own marketplace instead.

### Publishing your own

A repo becomes a marketplace with one manifest at `.claude-plugin/marketplace.json` listing plugins
by relative path; each plugin needs `.claude-plugin/plugin.json` and any of `commands/`, `skills/`,
`agents/`, `hooks/hooks.json`, `.mcp.json`. See this repo's own, and `valiro-ai/devproc`. A repo can
install its own plugin for development:

```bash
claude plugin marketplace add ./ --scope project
```

Then fix the absolute path it writes (see above), or your teammates get a marketplace pointing at
your home directory.

### Either way

Record it under **Skills** in that repo's `CLAUDE.md`, with one line on why it's blessed. Presence
declares *what*; CLAUDE.md declares *why*, and names what's deliberately absent so nobody re-adds
it.

---

## Maintenance

This file is the decision record for scoping; **ADR-0002** records why. A new skill, command or
agent gets a pack here before it gets installed anywhere — one with no pack is one nobody has
justified yet.

Check what a repo actually invoked with `/retro`. A vendored skill with zero invocations over a few
weeks should come out of that repo, and possibly out of this file.
