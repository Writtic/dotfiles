#!/bin/bash
# Claude Code → Slack DM notification hook
# Sends directory, git branch, and summary to Slack DM on Stop events.
# Requires SLACK_BOT_TOKEN env var (set in ~/.zshrc.local).

set -u

# Ensure common tool paths are available (desktop app may have minimal PATH)
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

INPUT=$(cat)

if [ -z "${SLACK_BOT_TOKEN:-}" ]; then
  exit 0
fi

SLACK_USER_ID="${SLACK_USER_ID:-U03UA4WQJRH}"

EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "Unknown"' 2>/dev/null || echo "Unknown")
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
[ -z "$CWD" ] && CWD=$(pwd)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

BRANCH=""
if [ -d "$CWD" ]; then
  BRANCH=$(cd "$CWD" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

SUMMARY=""
# 1) last_assistant_message (available in both CLI and desktop app)
SUMMARY=$(echo "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null || echo "")
# 2) Truncate to 300 chars
[ -n "$SUMMARY" ] && SUMMARY=$(echo "$SUMMARY" | tr '\n' ' ' | cut -c1-300)

DIR_NAME=$(basename "$CWD")
TEXT=":robot_face: *Claude Code — ${EVENT}*"$'\n'":file_folder: \`${DIR_NAME}\` (${CWD})"
[ -n "$BRANCH" ] && TEXT="${TEXT}"$'\n'":herb: \`${BRANCH}\`"
[ -n "$SUMMARY" ] && TEXT="${TEXT}"$'\n'":speech_balloon: ${SUMMARY}"

curl -sS -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json; charset=utf-8" \
  --data "$(jq -n --arg ch "$SLACK_USER_ID" --arg txt "$TEXT" '{channel:$ch, text:$txt}')" \
  >/dev/null 2>&1 || true

exit 0
