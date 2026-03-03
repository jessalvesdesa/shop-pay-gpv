#!/usr/bin/env bash
# Create a feature branch from main.
# Usage: bash scripts/create-branch.sh "short description"

set -euo pipefail

DESCRIPTION="${1:?Usage: create-branch.sh \"short description\"}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SLUG=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)
TIMESTAMP=$(date +%s)
BRANCH="feature/${SLUG}-${TIMESTAMP}"

git fetch origin main
git checkout -b "$BRANCH" origin/main

echo "$BRANCH"
