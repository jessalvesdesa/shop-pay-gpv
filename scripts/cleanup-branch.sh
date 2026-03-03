#!/usr/bin/env bash
# Abandon the current feature branch and return to main.
# Usage: bash scripts/cleanup-branch.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

BRANCH=$(git branch --show-current)

if [ "$BRANCH" = "main" ]; then
    echo "Already on main, nothing to clean up."
    exit 0
fi

echo "Abandoning branch: $BRANCH"

git checkout -- . 2>/dev/null || true
git clean -fd 2>/dev/null || true
git checkout main
git branch -D "$BRANCH"

echo "Cleaned up. Back on main."
