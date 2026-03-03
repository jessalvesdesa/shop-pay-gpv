# Shop Pay GPV

**Live:** https://shop-pay-gpv.quick.shopify.io

Shop Pay Gross Payment Volume dashboard. BigQuery data, auto-updating via comments.

## How to request a change

1. Go to https://shop-pay-gpv.quick.shopify.io
2. Click the QuickComments icon on any chart, table, or metric card
3. Leave a comment describing what you want changed (e.g. "break this out by installments vs non-installments" or "add a week-over-week delta")
4. A GitHub issue is automatically created and assigned to Copilot
5. Copilot implements the change and opens a PR with a preview
6. Review the preview, merge when it looks right — production auto-deploys

No code, no repo, no terminal needed.

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

## How the automation works

```
QuickComment on dashboard
  → Dashboard JS detects new comment (Quick DB subscription)
  → Creates GitHub issue (labeled "agent", assigned to @copilot)
  → Copilot coding agent implements the change
  → Opens PR → preview deploys at shop-pay-gpv-pr-N.quick.shopify.io
  → Human reviews and merges
  → deploy.yml ships to production
```

First-time users will see a GitHub OAuth popup to authorize issue creation.

## For developers

```bash
quick serve site shop-pay-gpv   # local dev
quick deploy site shop-pay-gpv  # manual deploy
```

Repo: https://github.com/jessalvesdesa/shop-pay-gpv
