#!/usr/bin/env bash
# Stage site/ changes, commit, and push.
# Usage: bash scripts/commit-and-push.sh "commit message"

set -euo pipefail

MESSAGE="${1:?Usage: commit-and-push.sh \"commit message\"}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

BRANCH=$(git branch --show-current)

if [ "$BRANCH" = "main" ]; then
    echo "Cannot commit directly to main. Create a feature branch first."
    exit 1
fi

git add site/

if git diff --cached --quiet; then
    echo "No changes to commit in site/"
    exit 1
fi

git commit -m "$MESSAGE"
git push -u origin "$BRANCH"

echo "Pushed to $BRANCH"
