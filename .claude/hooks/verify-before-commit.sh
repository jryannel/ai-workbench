#!/usr/bin/env bash
# PreToolUse hook — refuse a commit while the project's fast gate is red.
#
# The point of a hook rather than an instruction: "always verify before claiming
# done" written into a skill is a request the model can talk itself out of.
# Written here, it is a gate that either opens or does not.
#
# Runs the *fast* gate (preflight / unit tests), never the full CI suite — CI is
# the real gate and it runs on the server. This one exists to catch a broken
# build before it becomes a commit.
#
# Wire it up in .claude/settings.json:
#   "PreToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command",
#     "if": "Bash(git commit *)",
#     "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/verify-before-commit.sh" }]}]
#
# Escape hatches, because a gate you cannot bypass gets disabled entirely:
#   - put [skip-verify] in the commit message
#   - export WORKBENCH_SKIP_VERIFY=1

set -uo pipefail

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
cwd=$(printf '%s' "$input" | jq -r '.cwd // "."')
cd "$cwd" 2>/dev/null || exit 0

[ "${WORKBENCH_SKIP_VERIFY:-}" = "1" ] && exit 0
case "$command" in *"[skip-verify]"*) exit 0 ;; esac

deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# Detect the fast gate. Order matters: a project-declared task beats a guess.
mise=$(ls mise.toml .mise.toml 2>/dev/null | head -1)
gate=""
if   [ -n "$mise" ] && grep -q '^\[tasks\.preflight\]' "$mise"; then gate="mise run preflight"
elif [ -n "$mise" ] && grep -q '^\[tasks\.test\]'      "$mise"; then gate="mise run test"
elif [ -f package.json ] && grep -q '"test"' package.json;      then gate="npm test --silent"
elif [ -f go.mod ];                                             then gate="go test ./..."
elif [ -f Cargo.toml ];                                         then gate="cargo test --quiet"
elif [ -f pyproject.toml ] && command -v pytest >/dev/null 2>&1; then gate="pytest -q"
fi

# No gate found — a docs repo, or a language this doesn't know. Stay out of the
# way rather than inventing a check. Silence here is deliberate.
[ -z "$gate" ] && exit 0

out=$(eval "$gate" 2>&1); status=$?
[ $status -eq 0 ] && exit 0

deny "The gate is red, so the commit is blocked.

\$ $gate   (exit $status)

$(printf '%s' "$out" | tail -25)

Fix it, or — if the failure is genuinely unrelated to this change — say so and
commit with [skip-verify] in the message."
