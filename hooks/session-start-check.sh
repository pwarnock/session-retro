#!/usr/bin/env bash
# SessionStart hook: advisory check for un-retrospected work
# Non-blocking — prints a reminder to stderr but does NOT block (exit 0)
set -euo pipefail

# Clean up stale session markers (>2 hours old)
find /tmp -maxdepth 1 -name 'claude-retro-*' -mmin +120 -delete 2>/dev/null || true

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

# Need at least 2 commits to warrant mentioning
[ "$COMMIT_COUNT" -lt 2 ] && exit 0

# Advisory only — do NOT use exit 2 (that would block session start)
printf '%d un-retrospected commits detected. Consider running /retro to capture learnings.' "$COMMIT_COUNT" >&2
exit 0
