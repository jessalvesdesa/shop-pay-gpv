#!/usr/bin/env bash
# Full agent loop: create branch, apply changes (via Cursor/agent), commit, PR, notify.
#
# Usage: bash scripts/implement.sh "description of the change"
#
# This script handles the git plumbing. The actual code changes are made
# by an AI agent (Cursor, Codex, etc.) between the branch creation and commit.
#
# For fully automated use, pipe this into your agent:
#   1. Agent reads the comment (via watch.sh or handle-request.sh)
#   2. Agent calls: bash scripts/implement.sh "add installments breakdown"
#   3. Agent modifies site/index.html
#   4. Agent calls: bash scripts/ship.sh "feat: add installments breakdown"

set -euo pipefail

DESCRIPTION="${1:?Usage: implement.sh \"description of the change\"}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$REPO_ROOT/scripts"

echo "Starting: $DESCRIPTION"
echo "────────────────────────────────────────────────────────"

# Create branch
echo "Creating branch..."
BRANCH=$(bash "$SCRIPTS/create-branch.sh" "$DESCRIPTION")
echo "Branch: $BRANCH"
echo ""
echo "Make your changes to site/index.html now."
echo "When done, run:"
echo ""
echo "  bash scripts/ship.sh \"feat: ${DESCRIPTION}\""
