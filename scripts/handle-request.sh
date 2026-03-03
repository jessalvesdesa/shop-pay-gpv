#!/usr/bin/env bash
# Read the latest dashboard comment from Quick DB and print it for an agent to act on.
#
# Usage: bash scripts/handle-request.sh
#
# Agent workflow:
#   1. bash scripts/handle-request.sh          # see what was requested
#   2. bash scripts/create-branch.sh "desc"    # create branch
#   3. (make code changes to site/)            # do the work
#   4. bash scripts/commit-and-push.sh "msg"   # commit & push
#   5. bash scripts/create-pr.sh "title" "body" # open PR (auto-deploys preview)

set -euo pipefail

SITE="shop-pay-gpv"

echo "Fetching comments from ${SITE}..."
echo "────────────────────────────────────────────────────────"
echo ""

RESPONSE=$( (
    echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"reader","version":"1.0"}}}'
    sleep 2
    echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"query_collection","arguments":{"collection":"quickcomments","sort":"-created_at"}}}'
    sleep 4
) | quick mcp "$SITE" 2>/dev/null )

echo "$RESPONSE" | grep '"id":1' | python3 -c "
import sys, json
line = sys.stdin.read().strip()
if not line:
    print('No response from MCP')
    sys.exit(1)
resp = json.loads(line)
text = resp.get('result',{}).get('content',[{}])[0].get('text','[]')
comments = json.loads(text)
for c in comments:
    resolved = 'DONE' if c.get('resolved') else 'OPEN'
    anchor = c.get('anchor',{}).get('selector','?')
    author = c.get('author',{}).get('name','Unknown')
    date = c.get('createdAt','')[:16].replace('T',' ')
    text = c.get('text','')
    cid = c.get('id','')
    replies = len(c.get('replies',[]))
    print(f'[{resolved}] [{date}] {author} (on {anchor})')
    print(f'   {text}')
    if replies:
        print(f'   {replies} replies')
    print(f'   id: {cid}')
    print()
"
