#!/bin/bash
# ============================================================
# Push branding-machine to GitHub
# Run ONCE from Mac Mini Terminal:
#   cd ~/openclaw/branding-machine && bash push-to-github.sh
#
# Requires: gh (brew install gh) and gh auth login
# ============================================================
set -e

cd "$(dirname "$0")"

# Check gh is available
if ! command -v gh &> /dev/null; then
    echo "gh CLI not found. Installing..."
    brew install gh
fi

# Check gh auth
if ! gh auth status &> /dev/null 2>&1; then
    echo "Not logged into GitHub. Running gh auth login..."
    gh auth login
fi

echo "Initializing git repo..."
git init
git add -A
git commit -m "Branding Machine v1.0 — Personal content factory

Docker Compose stack: ComfyUI, Forge, Remotion, n8n, Postgres, SearXNG
One-liner installer for customer deployment testing (Co.8 Docker Store)"

echo ""
echo "Creating GitHub repo and pushing..."
gh repo create branding-machine --public --source=. --remote=origin --push

echo ""
echo "============================================"
echo "  REPO LIVE"
echo "============================================"
GITHUB_USER=$(gh api user --jq .login)
echo ""
echo "  URL: https://github.com/$GITHUB_USER/branding-machine"
echo ""
echo "  Install on Acer:"
echo "  curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/branding-machine/main/install.sh | bash"
echo ""
echo "  This script can be deleted now:"
echo "  rm push-to-github.sh"
echo "============================================"
