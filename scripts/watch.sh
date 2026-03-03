#!/usr/bin/env bash
# Watch for new QuickComments and post them to Slack.
# Usage: bash scripts/watch.sh
#
# Polls the Quick DB every 30 seconds for unresolved comments.
# When a new comment appears, posts it to the configured Slack channel.
# Keeps track of seen comment IDs so it only notifies once per comment.
#
# The agent workflow is:
#   1. Leave this running in a terminal
#   2. Someone comments on the dashboard
#   3. This script posts the comment to Slack
#   4. An agent (Cursor, Codex, etc.) picks it up and runs:
#      bash scripts/implement.sh "comment text here"

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SITE="shop-pay-gpv"
SEEN_FILE="/tmp/shop-pay-gpv-seen-comments.txt"
POLL_INTERVAL="${1:-30}"

# TODO: Create a Slack channel and put its ID here
SLACK_CHANNEL="${SHOP_PAY_GPV_SLACK_CHANNEL:-REPLACE_WITH_CHANNEL_ID}"

if [ "$SLACK_CHANNEL" = "REPLACE_WITH_CHANNEL_ID" ]; then
    echo "Set SHOP_PAY_GPV_SLACK_CHANNEL or edit this script with your channel ID."
    echo ""
    echo "To create a channel:"
    echo "  1. Go to Slack → Create channel → #shop-pay-gpv-agent"
    echo "  2. Right-click channel name → View channel details → copy the Channel ID"
    echo "  3. Run: SHOP_PAY_GPV_SLACK_CHANNEL=C0XXXXX bash scripts/watch.sh"
    exit 1
fi

touch "$SEEN_FILE"

echo "Watching $SITE for new comments (every ${POLL_INTERVAL}s)..."
echo "Slack channel: $SLACK_CHANNEL"
echo "Press Ctrl+C to stop."
echo "────────────────────────────────────────────────────────"

while true; do
    RESPONSE=$( (
        echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"watcher","version":"1.0"}}}'
        sleep 2
        echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"query_collection","arguments":{"collection":"quickcomments","sort":"-created_at"}}}'
        sleep 4
    ) | quick mcp "$SITE" 2>/dev/null || echo "" )

    if [ -z "$RESPONSE" ]; then
        sleep "$POLL_INTERVAL"
        continue
    fi

    PARSED=$(echo "$RESPONSE" | grep '"id":1' | python3 -c "
import sys, json
line = sys.stdin.read().strip()
if not line:
    sys.exit(0)
try:
    resp = json.loads(line)
    text = resp.get('result',{}).get('content',[{}])[0].get('text','[]')
    comments = json.loads(text)
    for c in comments:
        if c.get('resolved'):
            continue
        cid = c.get('id','')
        anchor = c.get('anchor',{}).get('selector','?')
        author = c.get('author',{}).get('name','Unknown')
        body = c.get('text','')
        print(f'{cid}|{author}|{anchor}|{body}')
except:
    pass
" 2>/dev/null || echo "")

    if [ -n "$PARSED" ]; then
        while IFS= read -r line; do
            CID=$(echo "$line" | cut -d'|' -f1)
            AUTHOR=$(echo "$line" | cut -d'|' -f2)
            ANCHOR=$(echo "$line" | cut -d'|' -f3)
            BODY=$(echo "$line" | cut -d'|' -f4-)

            if grep -qF "$CID" "$SEEN_FILE" 2>/dev/null; then
                continue
            fi

            echo "$CID" >> "$SEEN_FILE"

            TIMESTAMP=$(date '+%H:%M:%S')
            echo "[$TIMESTAMP] New comment from $AUTHOR on [$ANCHOR]: $BODY"

            MSG="New dashboard comment on *shop-pay-gpv*\n\n*From:* ${AUTHOR}\n*Element:* \`${ANCHOR}\`\n*Comment:* ${BODY}\n\nTo implement: clone the repo and run \`bash scripts/implement.sh \"${BODY}\"\`"

            npx -y @shopify-internal/slack-mcp@latest send-message \
                --target "$SLACK_CHANNEL" \
                --text "$MSG" 2>/dev/null || echo "  (Slack send failed)"

        done <<< "$PARSED"
    fi

    sleep "$POLL_INTERVAL"
done
