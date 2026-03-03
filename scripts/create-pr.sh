#!/usr/bin/env bash
# Create a PR for the current branch.
# Usage: bash scripts/create-pr.sh "title" "body"
# Outputs the PR URL. preview.yml auto-deploys a preview.

set -euo pipefail

TITLE="${1:?Usage: create-pr.sh \"title\" \"body\"}"
BODY="${2:-""}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

BRANCH=$(git branch --show-current)

if [ "$BRANCH" = "main" ]; then
    echo "Cannot create a PR from main."
    exit 1
fi

PR_URL=$(gh pr create \
    --base main \
    --head "$BRANCH" \
    --title "$TITLE" \
    --body "$BODY" \
    --repo jessalvesdesa/shop-pay-gpv \
    2>&1)

echo "$PR_URL"
