# Pack registry — what to install where

The central answer to "what does *this* repo need?" A repo's **intent** decides its pack; the pack
decides its skills, commands and agents.

A **pack** is the set of automation blessed for one kind of repo. The term is borrowed from
[skills.sh](https://www.skills.sh/packs), which uses it for a bundle installed by one command —
the same grouping instinct. This registry uses the word, not the service: their packs address
*fetching*, and nothing documented suggests one installs anywhere other than globally, which
leaves the problem this file exists for untouched. Sharing vocabulary means a hosted bundle could
be adopted later without renaming anything.

> **Why this file exists:** anything installed globally is loaded into every session in every repo,
> and its description occupies context permanently whether or not it's relevant. Fifty global
> skills means fifty descriptions carried into a Go library that needs none of them.

---

## Rule 1 — scope follows repo intent

**Install globally only what is useful regardless of what the repo contains.** Domain-shaped
automation belongs to a pack.

| Scope | Lives in | For |
|---|---|---|
| **Global** | `~/.claude/{skills,commands,agents}/` | Useful in every repo, whatever it holds |
| **Pack** | `<repo>/.claude/…`, committed | Everything domain-shaped |
| **Never** | — | Installed "just in case" |

The rule cuts differently by artifact type, and that's correct rather than inconsistent:

- **Skills** are usually domain-shaped — Cloudflare, Mantine, SEO. Almost all belong to a pack.
- **Commands** are usually *workflow* — git operations, session continuity. These pass the global
  test honestly, because git is present regardless of what the repo contains.
- **Agents** are nearly always repo-shaped, since a reviewer's brief depends on what's being
  reviewed. Keep them in the repo.

### The trap that makes this mandatory

**Personal overrides project.** Anything in `~/.claude/` silently wins over the same name in a
repo's `.claude/`. So per-repo versions do not take effect until the global copy is removed.
Pruning globals isn't tidying — it's what makes packs work at all.

### Why committed, not symlinked

A symlink into `~/.agents/` works only on your machine. A committed copy travels: a teammate
cloning, a cloud agent, CI, a fresh laptop. Same reasoning as committing handoff docs — state
lives in the repo, not in one machine's home directory.

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

---

## Packs

Pick the one matching what the repo *is*. A repo may take more than one.

### `meta` — repos that author agent tooling
*ai-workbench, plugin repos, anything with a `.claude/` you maintain rather than merely use.*

| Skill | Source |
|---|---|
| `skill-creator` | `anthropics/skills` — authoring, evals, description optimisation (Apache-2.0; keep its LICENSE when vendoring) |

Also relevant as a marketplace plugin: `plugin-dev@claude-plugins-official`.

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

Downloading and scoping are **two separate steps**. skills.sh documents
`npx skills add <owner>/<repo>`, which fetches into `~/.agents/skills/` and symlinks it into
`~/.claude/skills/` — globally, with no documented project-scope flag. So:

```bash
# 1. fetch (once per machine) — skip if already in ~/.agents/skills/
npx skills add <owner>/<repo>

# 2. scope it to the repo that needs it
mkdir -p .claude/skills
cp -R ~/.agents/skills/<name> .claude/skills/<name>
git add .claude/skills/<name> && git commit -m "chore: vendor <name>"

# 3. stop it loading everywhere — required, or the global copy wins
rm ~/.claude/skills/<name>
```

Step 3 is not optional: personal overrides project, so the vendored copy is inert until the global
symlink is gone.

Then record it under **Skills** in that repo's `CLAUDE.md`, with one line on why it's blessed.
Presence declares *what*; CLAUDE.md declares *why*, and names what's deliberately absent so nobody
re-adds it.

**Updating:** re-run `npx skills add`, then re-copy into each repo that vendors it. That fan-out is
the real cost — see ADR-0002. If skills.sh gains a project-scope flag, steps 2 and 3 collapse and
this file should change.

**Removing a global:** `rm ~/.claude/skills/<name>`. These are symlinks; the source stays in
`~/.agents/skills/` to vendor from.

---

## Maintenance

This file is the decision record for scoping; **ADR-0002** records why. A new skill, command or
agent gets a pack here before it gets installed anywhere — one with no pack is one nobody has
justified yet.

Check what a repo actually invoked with `/retro`. A vendored skill with zero invocations over a few
weeks should come out of that repo, and possibly out of this file.
