#!/bin/bash
# One-time local setup for this learning fork on WSL (Ubuntu) or Linux.
# Installs uv, Python 3.12 in .venv with the course libraries, the GitHub
# CLI for pushing, and Claude Code, then runs the Phase 0 environment check.
# Safe to re-run: every step skips what is already in place.
set -euo pipefail

cd "$(dirname "$0")/.."
REPO_DIR="$PWD"
UPSTREAM_URL="https://github.com/rohitg00/ai-engineering-from-scratch.git"
export PATH="$HOME/.local/bin:$PATH"

step() { printf '\n==> %s\n' "$1"; }

step "System packages (git, curl)"
missing=()
for pkg in git curl; do
  command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done
if [ ${#missing[@]} -gt 0 ]; then
  sudo apt-get update && sudo apt-get install -y "${missing[@]}" ca-certificates
else
  echo "git and curl already installed."
fi

step "Git identity"
if [ -z "$(git config --global user.name || true)" ]; then
  read -rp "Your name for git commits: " name
  git config --global user.name "$name"
fi
if [ -z "$(git config --global user.email || true)" ]; then
  read -rp "Your email for git commits (use your GitHub email): " email
  git config --global user.email "$email"
fi
git config pull.rebase true
echo "Committing as $(git config --global user.name) <$(git config --global user.email)>"

step "Upstream remote and latest progress"
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git fetch --quiet upstream main
git checkout --quiet main
git pull --quiet origin main
behind=$(git rev-list --count main..upstream/main)
echo "On main. Fork is $behind commit(s) behind upstream (ask Claude to sync if > 0)."

step "uv and Python 3.12 virtual environment (.venv)"
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install 3.12
[ -d .venv ] || uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python numpy matplotlib jupyter
# CPU wheels keep the download small; swap the index URL for a CUDA build
# (see Phase 0 lesson 03) if your WSL has an NVIDIA GPU.
uv pip install --python .venv/bin/python torch --index-url https://download.pytorch.org/whl/cpu \
  || echo "PyTorch install failed; rerun this script later. Only needed from Phase 3."

step "GitHub CLI (lets git push to your fork)"
if ! command -v gh >/dev/null 2>&1; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update && sudo apt-get install -y gh
fi
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git

step "Claude Code"
command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
claude --version || true

step "Phase 0 environment check"
.venv/bin/python phases/00-setup-and-tooling/01-dev-environment/code/verify.py --route beginner || true

cat <<EOF

Setup complete. To continue learning:
  cd $REPO_DIR
  claude
Then type /learn. Claude activates .venv automatically in this repo.
EOF
