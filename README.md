# Shop Pay GPV

**Live:** https://shop-pay-gpv.quick.shopify.io

Shop Pay Gross Payment Volume dashboard. BigQuery data, auto-updating via comments.

## How to request a change

1. Go to https://shop-pay-gpv.quick.shopify.io
2. Click the QuickComments icon on any chart, table, or metric card
3. Leave a comment describing what you want changed (e.g. "break this out by installments vs non-installments" or "add a week-over-week delta")
4. An agent picks up your comment, makes the change, and opens a PR with a preview link
5. Review the preview, leave follow-up comments if needed, merge when it looks right

That's it. You don't need to touch code, clone the repo, or run anything locally.

## What's on the dashboard

| Section | What it shows |
|---|---|
| **Shop Pay GPV** | Total $ through Shop Pay (7d / 30d / 90d toggle) |
| **Avg Transaction Value** | With +/- % vs non-wallet transactions |
| **Daily GPV Trend** | Shop Pay vs Apple Pay, Google Pay, direct card |
| **GPV by Wallet** | Doughnut — dollar share across wallets |
| **Payment Method GPV** | Bar — top payment types by $ across all gateways |
| **GPV by Country** | Table — top markets, avg txn value, shop count |

Data source: `shopify-dw.money_products.order_transactions_payments_summary` (`amount_presentment`)

## Setup (one-time)

1. Create a Slack channel called `#shop-pay-gpv-agent`
2. Copy the channel ID (right-click channel name → View channel details)
3. Start the watcher:

```bash
SHOP_PAY_GPV_SLACK_CHANNEL=C0XXXXX bash scripts/watch.sh
```

New comments will appear in Slack. An agent (Cursor, Codex, etc.) picks them up and runs:

```bash
bash scripts/implement.sh "the requested change"
# make code changes to site/index.html
bash scripts/ship.sh "feat: the requested change"
```

PR preview auto-deploys at `shop-pay-gpv-pr-{N}.quick.shopify.io`. Merge to ship.

## For developers

```bash
quick serve site shop-pay-gpv   # local dev
quick deploy site shop-pay-gpv  # manual deploy
```

Repo: https://github.com/jessalvesdesa/shop-pay-gpv
