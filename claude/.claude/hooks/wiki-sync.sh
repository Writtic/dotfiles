#!/bin/bash
# Claude Code PostToolUse hook — superpowers specs/plans → LLM Wiki sync reminder.
#
# Fires when a spec or plan lands under docs/superpowers/specs/ or
# docs/superpowers/plans/, and injects a reminder to mirror a synthesized page
# into LLMWiki/specs/. This is the automation behind the SYNC step in
# ~/.claude/CLAUDE.md ("LLM Wiki" section): text instructions get forgotten,
# a hook does not.
#
# Wired as: hooks.PostToolUse[matcher="Write|Edit"] → this script.
# Non-matching writes exit 0 silently (no context injected).

set -u

# Desktop app may launch with a minimal PATH; ensure jq is reachable.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

INPUT=$(cat)

# jq is required to parse stdin and emit safe JSON. Without it, do nothing
# rather than risk malformed output blocking the tool result.
command -v jq >/dev/null 2>&1 || exit 0

# Write and Edit both carry the target in tool_input.file_path.
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")
[ -z "$FILE" ] && exit 0

case "$FILE" in
  *docs/superpowers/specs/*.md|*docs/superpowers/plans/*.md)
    REL="docs/superpowers/${FILE##*docs/superpowers/}"
    jq -n --arg f "$REL" '{
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: (
          "LLM Wiki SYNC trigger (spec-sync): a superpowers spec/plan landed at \($f). " +
          "Per ~/.claude/CLAUDE.md (LLM Wiki — SYNC) and canon §6.3, mirror a *synthesized* spec " +
          "page into LLMWiki/specs/ (spec_status, plan link), connect related systems/ and " +
          "decisions/ pages, then update index.md and append a `spec-sync` entry to log.md. " +
          "Synthesize, do not copy-paste. If the iCloud wiki path is unreachable, leave a note " +
          "in the repo and reconcile next session."
        )
      }
    }'
    ;;
  *)
    exit 0
    ;;
esac
