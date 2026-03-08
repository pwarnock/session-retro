#!/usr/bin/env bash
# Stop hook: prompt for retro when session has un-retrospected work
# Blocks Claude's stop ONCE per session to ask about running /retro
set -euo pipefail

# Read hook input, extract session ID for marker
INPUT=$(cat)
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty')

# Session marker: only prompt once per session
MARKER="/tmp/claude-retro-${SESSION_ID:-$$}"
[ -f "$MARKER" ] && exit 0

# Must be in a git repo with retro infrastructure
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -d "$REPO_ROOT/docs/session-logs" ] || exit 0
cd "$REPO_ROOT"

# Find commits since last retro
LAST_RETRO_HASH=$(git log --oneline --all \
  --grep="session retrospective" \
  --grep="docs/session-logs" \
  -1 --format="%H" 2>/dev/null || true)

if [ -n "$LAST_RETRO_HASH" ]; then
  COMMIT_COUNT=$(git log --oneline "$LAST_RETRO_HASH"..HEAD --no-merges 2>/dev/null | wc -l | tr -d ' ')
else
  COMMIT_COUNT=$(git log --oneline --since="midnight" --no-merges 2>/dev/null | wc -l | tr -d ' ')
fi

# Need at least 2 commits to warrant a retro
[ "$COMMIT_COUNT" -lt 2 ] && exit 0

# Mark as offered (won't ask again this session)
touch "$MARKER"

# Block the stop — stderr message tells Claude what to do
printf '%d commits since last retro. Ask the user: "Run /retro before wrapping up? (y/n)"' "$COMMIT_COUNT" >&2
exit 2
