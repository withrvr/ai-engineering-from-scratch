#!/bin/bash
# SessionStart hook for cloud sessions: restores the upstream remote that a
# fresh clone loses, reports how far the fork's main trails upstream, and
# installs the Python libraries the early lessons import.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

UPSTREAM_URL="https://github.com/rohitg00/ai-engineering-from-scratch.git"
if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$UPSTREAM_URL"
fi

if git fetch --quiet upstream main 2>/dev/null && git fetch --quiet origin main 2>/dev/null; then
  behind=$(git rev-list --count origin/main..upstream/main)
  if [ "$behind" -gt 0 ]; then
    echo "Fork main is $behind commit(s) behind upstream/main. Sync with: git checkout main && git merge upstream/main && git push origin main"
  else
    echo "Fork main is up to date with upstream/main."
  fi
else
  echo "Could not fetch upstream; skipping sync check."
fi

PIP="python3 -m pip install --quiet --disable-pip-version-check --root-user-action=ignore"
$PIP numpy matplotlib

# PyTorch CPU wheels live on download.pytorch.org; the network policy may
# block it, and torch is only needed from the deep-learning phases onward.
if ! python3 -c "import torch" 2>/dev/null; then
  $PIP torch --index-url https://download.pytorch.org/whl/cpu >/dev/null 2>&1 \
    || echo "PyTorch not installed (download.pytorch.org unreachable); lessons that need torch will fail until it is."
fi
