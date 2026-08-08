# Skill registry — what to install where

The central answer to "which skills does *this* repo need?" A repo's **intent** decides its
pack; the pack decides its skills. Nothing is installed globally because it might be handy
somewhere.

> **Why this file exists:** a skill installed globally is loaded into every session in every repo,
> and its description occupies context permanently whether or not it's relevant. Fifty global
> skills means fifty descriptions carried into a Go library that needs none of them.

---

## The rule

**A skill is global only if it is useful regardless of what the repo contains.** In practice that's
discovery and nothing else — anything domain-shaped belongs to a pack.

| Scope | Install where | For |
|---|---|---|
| **Global** | `~/.claude/skills/` | Useful in every repo, whatever it holds |
| **Pack** | `<repo>/.claude/skills/`, committed | Everything domain-shaped |
| **Never** | — | Installed "just in case" |

### The trap that makes this mandatory

**Personal overrides project.** A skill in `~/.claude/skills/` silently wins over one of the same
name in a repo's `.claude/skills/`. So per-repo versions do not take effect until the global copy
is removed. Pruning globals isn't tidying — it's what makes packs work at all.

### Why committed, not symlinked

A symlink into `~/.agents/` works only on your machine. A committed skill travels: a teammate
cloning, a cloud agent, CI, a fresh laptop. Same reasoning as committing handoff docs — state
lives in the repo, not in one machine's home directory.

---

## Global — install everywhere

| Skill | Source | Why global |
|---|---|---|
| `find-skills` | `vercel-labs/skills` | Answers "is there a skill for this?" in any repo. Bootstraps everything else in this file. |

That's the whole list. Everything below is per-repo.

---

## Packs

Pick the one matching what the repo *is*. A repo may take more than one.

### `meta` — repos that author agent tooling
*ai-workbench, plugin repos, anything with a `.claude/` you maintain rather than merely use.*

| Skill | Source |
|---|---|
| `skill-creator` | `anthropics/skills` — authoring, evals, description optimisation |

Also relevant as a marketplace plugin: `plugin-dev@claude-plugins-official`.

### `cloudflare-worker` — Workers, Pages, D1/KV/R2
*Anything deployed on Cloudflare.*

`agents-sdk` · `cloudflare` · `cloudflare-email-service` · `cloudflare-one` ·
`cloudflare-one-migrations` · `durable-objects` · `sandbox-sdk` · `turnstile-spin` ·
`workers-best-practices` · `wrangler`

> Source unrecorded — these eleven are not in `~/.agents/.skill-lock.json`, so their install can't
> currently be reproduced. Confirm the upstream before relying on this row.

### `web-ui` — anything with a front end
*React/Mantine apps, marketing sites, dashboards.*

| Skill | Source |
|---|---|
| `frontend-design` | `anthropics/skills` (also available as `frontend-design@claude-plugins-official` — **installed twice today**, pick one) |
| `web-perf` | with the Cloudflare set; not Cloudflare-specific |
| `mantine-combobox`, `mantine-custom-components`, `mantine-form` | `mantinedev/skills` — only for repos actually using Mantine |

### `marketing-site` — sites whose job is acquisition
*Landing pages, pricing pages, content and campaign work.*

All 32 from `coreyhaines31/marketingskills`: `ab-test-setup` `ad-creative` `ai-seo`
`analytics-tracking` `churn-prevention` `cold-email` `competitor-alternatives` `content-strategy`
`copy-editing` `copywriting` `email-sequence` `form-cro` `free-tool-strategy` `launch-strategy`
`marketing-ideas` `marketing-psychology` `onboarding-cro` `page-cro` `paid-ads`
`paywall-upgrade-cro` `popup-cro` `pricing-strategy` `product-marketing-context`
`programmatic-seo` `referral-program` `revops` `sales-enablement` `schema-markup` `seo-audit`
`signup-flow-cro` `site-architecture` `social-content`

Install the whole set only in a repo whose *purpose* is marketing. In a product repo that happens
to have a pricing page, take `page-cro` and `copywriting` alone.

### `go-service` — Go libraries and services
*sqlb, valiro-go.*

**None.** Nothing in the current 50 targets Go. Worth stating plainly: the repo where most of the
work happens needs none of the skills that were installed globally for its benefit.

### On demand, no pack

`excalidraw-diagram-generator` — install in whichever repo is producing diagrams that week.

---

## Installing into a repo

Downloading and scoping are **two separate steps**. [skills.sh](https://www.skills.sh) documents
`npx skills add <owner/repo>`, which fetches into `~/.agents/skills/` and symlinks it into
`~/.claude/skills/` — i.e. globally, with no documented project-scope flag. So:

```bash
# 1. fetch (once per machine) — skips this if already in ~/.agents/skills/
npx skills add <owner>/<repo>

# 2. scope it to the repo that needs it
mkdir -p .claude/skills
cp -R ~/.agents/skills/<skill-name> .claude/skills/<skill-name>
git add .claude/skills/<skill-name> && git commit -m "chore: vendor <skill-name>"

# 3. stop it loading everywhere — required, or the global copy wins
rm ~/.claude/skills/<skill-name>
```

Step 3 is not optional: personal overrides project, so the vendored copy is inert until the global
symlink is gone.

Then record it under **Skills** in that repo's `CLAUDE.md`, with one line on why it's blessed.
Presence declares *what*; CLAUDE.md declares *why*, and names what's deliberately absent so nobody
re-adds it.

**On the word "pack".** [skills.sh](https://www.skills.sh/packs) uses it for a bundle installed by
one command, and it's the right word for the grouping — so this file borrows the term. It does not
use the feature. Their packs address *fetching*; nothing documented suggests one installs anywhere
other than globally, which leaves the problem this registry exists for untouched. A hosted bundle
also can't record why a skill is blessed for a repo, or what was deliberately left out, and that's
the part doing the actual work here.

Same vocabulary, so a shared bundle can be adopted later without renaming anything.

**Updating:** re-run `npx skills add`, then re-copy into each repo that vendors it. That fan-out is
the real cost of this approach — see ADR-0002. If skills.sh gains a project-scope flag, steps 2
and 3 collapse and this file should change.

**Removing a global:** `rm ~/.claude/skills/<skill-name>`. These are symlinks; the skill stays in
`~/.agents/skills/` as the source to vendor from.

---

## Maintenance

This file is the decision record for scoping; **ADR-0002** records why. When a new skill arrives,
it gets a pack here before it gets installed anywhere. A skill with no pack is a skill
nobody has justified yet.

Check what a repo actually invoked with `/retro` — a vendored skill with zero invocations over a
few weeks should be removed from that repo, and possibly from this file.
