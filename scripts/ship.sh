#!/usr/bin/env bash
# Commit, push, open PR, and notify Slack. Run after making code changes.
#
# Usage: bash scripts/ship.sh "feat: description"
#
# Does: git add site/ → commit → push → open PR → notify Slack

set -euo pipefail

MESSAGE="${1:?Usage: ship.sh \"feat: description\"}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$REPO_ROOT/scripts"

SLACK_CHANNEL="${SHOP_PAY_GPV_SLACK_CHANNEL:-C0AHPAUT6KH}"

echo "Shipping..."

bash "$SCRIPTS/commit-and-push.sh" "$MESSAGE"

TITLE=$(echo "$MESSAGE" | sed 's/^feat: //' | sed 's/^fix: //')
PR_URL=$(bash "$SCRIPTS/create-pr.sh" "$TITLE" "Automated from dashboard comment")
echo "PR: $PR_URL"

if [ "$SLACK_CHANNEL" != "REPLACE_WITH_CHANNEL_ID" ]; then
    bash "$SCRIPTS/notify-slack.sh" "$PR_URL" 2>/dev/null || true
fi

echo ""
echo "Done. Preview will deploy automatically."
