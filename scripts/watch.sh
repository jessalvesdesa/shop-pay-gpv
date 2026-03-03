#!/usr/bin/env bash
# Watch for new QuickComments via the Quick app Slack DM and forward to team channel.
#
# Usage: bash scripts/watch.sh
#
# Polls the Quick app DM (where QuickComments posts notifications) every 20 seconds.
# When a new comment about shop-pay-gpv appears, re-posts it to the team channel.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

QUICK_DM="D0AJ2M0L3AS"
TEAM_CHANNEL="${SHOP_PAY_GPV_SLACK_CHANNEL:-C0AHPAUT6KH}"
SITE_HOST="shop-pay-gpv.quick.shopify.io"
POLL_INTERVAL="${1:-20}"
SEEN_FILE="/tmp/shop-pay-gpv-seen-ts.txt"

touch "$SEEN_FILE"

echo "Watching Quick app DM for comments on $SITE_HOST..."
echo "Forwarding to channel: $TEAM_CHANNEL"
echo "Polling every ${POLL_INTERVAL}s. Ctrl+C to stop."
echo "────────────────────────────────────────────────────────"

while true; do
    MESSAGES=$(npx -y @shopify-internal/slack-mcp@latest get-messages \
        --action channel \
        --channel "$QUICK_DM" \
        --count 10 \
        --output_format json 2>/dev/null || echo "[]")

    echo "$MESSAGES" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
except:
    sys.exit(0)

messages = data if isinstance(data, list) else data.get('messages', [])
site = '$SITE_HOST'
seen_file = '$SEEN_FILE'

with open(seen_file) as f:
    seen = set(f.read().strip().split('\n'))

for msg in messages:
    ts = msg.get('ts', '')
    text = msg.get('text', '')
    if ts in seen or site not in text:
        continue
    # Extract the comment text (after 'commented:' or '>')
    lines = text.split('\n')
    comment = ''
    author = ''
    for line in lines:
        if 'commented' in line.lower():
            author = line.split('*')[1] if '*' in line else ''
        if line.strip().startswith('>'):
            comment = line.strip().lstrip('> ').strip()
    if comment:
        print(f'{ts}|{author}|{comment}')
        with open(seen_file, 'a') as f:
            f.write(ts + '\n')
" 2>/dev/null | while IFS='|' read -r TS AUTHOR COMMENT; do
        NOW=$(date '+%H:%M:%S')
        echo "[$NOW] $AUTHOR: $COMMENT"

        MSG="New comment on *shop-pay-gpv* dashboard\n\n*From:* ${AUTHOR}\n*Comment:* ${COMMENT}\n\nTo implement, open the repo in Cursor and say:\n\`bash scripts/implement.sh \"${COMMENT}\"\`"

        npx -y @shopify-internal/slack-mcp@latest send-message \
            --target "$TEAM_CHANNEL" \
            --text "$MSG" 2>/dev/null && echo "  → Posted to Slack" || echo "  → Slack send failed"
    done

    sleep "$POLL_INTERVAL"
done
