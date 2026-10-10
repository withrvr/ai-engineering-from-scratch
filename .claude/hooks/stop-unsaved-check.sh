#!/bin/bash
# Stop hook for local sessions: before Claude finishes a turn, make sure
# progress is committed and pushed to origin/main. Cloud sessions already
# run an equivalent built-in check, so this exits there.
set -uo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] && exit 0

input=$(cat)
active=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active", False))' 2>/dev/null || echo False)
[ "$active" = "True" ] && exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

if [ -n "$(git status --porcelain)" ]; then
  echo "There are uncommitted changes. Commit them per CLAUDE.md, then push to origin main." >&2
  exit 2
fi

branch=$(git branch --show-current)
if git rev-parse --verify --quiet "origin/$branch" >/dev/null; then
  ahead=$(git rev-list --count "origin/$branch..HEAD")
  if [ "$ahead" -gt 0 ]; then
    echo "There are $ahead unpushed commit(s) on $branch. Push them per CLAUDE.md." >&2
    exit 2
  fi
fi
exit 0
