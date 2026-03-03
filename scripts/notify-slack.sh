#!/usr/bin/env bash
# Notify Slack about a PR. Update the channel ID to your team's channel.
# Usage: bash scripts/notify-slack.sh "PR_URL" [thread_ts]

set -euo pipefail

PR_URL="${1:?Usage: notify-slack.sh \"PR_URL\" [thread_ts]}"
THREAD_TS="${2:-""}"
# TODO: Update this to your team's Slack channel ID
CHANNEL="REPLACE_WITH_CHANNEL_ID"

PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$' || echo "")
PREVIEW_URL=""
if [ -n "$PR_NUM" ]; then
    PREVIEW_URL="https://shop-pay-gpv-pr-${PR_NUM}.quick.shopify.io"
fi

MESSAGE="PR created: ${PR_URL}"
if [ -n "$PREVIEW_URL" ]; then
    MESSAGE="${MESSAGE}\nPreview: ${PREVIEW_URL}"
fi

if [ -n "$THREAD_TS" ]; then
    npx -y @shopify-internal/slack-mcp@latest send-message \
        --target "$CHANNEL" \
        --text "$MESSAGE" \
        --thread_ts "$THREAD_TS"
else
    npx -y @shopify-internal/slack-mcp@latest send-message \
        --target "$CHANNEL" \
        --text "$MESSAGE"
fi

echo "Slack notified"
