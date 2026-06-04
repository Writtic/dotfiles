#!/bin/bash
# Claude Code PreToolUse hook — superpowers brainstorming/writing-plans → LLM Wiki RECALL reminder.
#
# Fires before the Skill tool runs. When the invoked skill is superpowers brainstorming or
# writing-plans, inject a reminder to dispatch the two recall researchers in parallel before
# designing. Per ~/.claude/CLAUDE.md (LLM Wiki — RECALL).
#
# Wired as: hooks.PreToolUse[matcher="Skill"] → this script.
# Non-matching skills exit 0 silently (no context injected).

set -u
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || exit 0

SKILL=$(printf '%s' "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null || echo "")
[ -z "$SKILL" ] && exit 0

case "$SKILL" in
  *brainstorming|*writing-plans)
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        additionalContext: (
          "LLM Wiki RECALL trigger: superpowers brainstorming/writing-plans is starting. " +
          "Per ~/.claude/CLAUDE.md (LLM Wiki — RECALL), before designing, dispatch the " +
          "llmwiki-researcher agent (central wiki, cross-repo) AND the learnings-researcher " +
          "agent (repo-local docs/solutions/) in parallel with the same <work-context>. " +
          "Surface prior knowledge first; flag any conflict with current code by date, do not " +
          "follow stale findings blindly. The wiki is a secondary artifact — if it is " +
          "unreachable, proceed without it."
        )
      }
    }'
    ;;
  *)
    exit 0
    ;;
esac
