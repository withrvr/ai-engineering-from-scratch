#!/bin/bash
# SessionStart hook: restores the upstream remote that a fresh clone loses
# and reports how far the fork's main trails upstream. Cloud sessions also
# install the Python libraries the early lessons import; local sessions
# activate the .venv that scripts/setup-wsl.sh creates.
set -euo pipefail

cd "$CLAUDE_PROJECT_DIR"

UPSTREAM_URL="https://github.com/rohitg00/ai-engineering-from-scratch.git"
if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote add upstream "$UPSTREAM_URL"
fi

if git fetch --quiet upstream main 2>/dev/null && git fetch --quiet origin main 2>/dev/null; then
  behind=$(git rev-list --count origin/main..upstream/main)
  if [ "$behind" -gt 0 ]; then
    echo "Fork main is $behind commit(s) behind upstream/main. Sync per CLAUDE.md."
  else
    echo "Fork main is up to date with upstream/main."
  fi
else
  echo "Could not fetch upstream; skipping sync check."
fi

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  if [ -f .venv/bin/activate ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo "source \"$CLAUDE_PROJECT_DIR/.venv/bin/activate\"" >> "$CLAUDE_ENV_FILE"
  elif [ ! -d .venv ]; then
    echo "No .venv found. Run: bash scripts/setup-wsl.sh"
  fi
  exit 0
fi

PIP="python3 -m pip install --quiet --disable-pip-version-check --root-user-action=ignore"
$PIP numpy matplotlib

# PyTorch CPU wheels live on download.pytorch.org; the network policy may
# block it, and torch is only needed from the deep-learning phases onward.
if ! python3 -c "import torch" 2>/dev/null; then
  $PIP torch --index-url https://download.pytorch.org/whl/cpu >/dev/null 2>&1 \
    || echo "PyTorch not installed (download.pytorch.org unreachable); lessons that need torch will fail until it is."
fi
