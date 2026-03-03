# Shop Pay GPV

Gross Payment Volume dashboard for Shop Pay, powered by BigQuery and deployed on [Quick](https://quick.shopify.io).

**Live:** https://shop-pay-gpv.quick.shopify.io

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Dashboard (site/)                              │
│  • Chart.js charts, BigQuery data               │
│  • QuickComments for spatial commenting          │
└────────────────┬────────────────────────────────┘
                 │ comments flow to Slack
                 ▼
┌─────────────────────────────────────────────────┐
│  Agent picks up comment                         │
│  • Reads from Quick DB via MCP                   │
│  • Creates branch, applies changes               │
└────────────────┬────────────────────────────────┘
                 │ PR opened
                 ▼
┌─────────────────────────────────────────────────┐
│  CI/CD (.github/workflows/)                     │
│  • PR → preview at shop-pay-gpv-pr-N            │
│  • Merge → auto-deploy to production             │
└─────────────────────────────────────────────────┘
```

## What it shows

- **Shop Pay GPV** — total dollar volume through Shop Pay (7d / 30d / 90d)
- **GPV share** — % of all Shopify Payments volume
- **Average transaction value** — with comparison to non-wallet transactions
- **Daily GPV trend** — Shop Pay vs other wallets over time
- **GPV by wallet** — doughnut chart of dollar-volume split
- **Payment method GPV** — across all gateways
- **GPV by country** — top markets with avg transaction value

Data source: `shopify-dw.money_products.order_transactions_payments_summary`

## Quick Start

```bash
# Local dev
quick serve site shop-pay-gpv

# Deploy manually
quick deploy site shop-pay-gpv
```

## Commenting & Agent Workflow

Dashboard elements have QuickComments enabled. Leave a spatial comment on any chart or table, and an agent can pick it up:

```bash
# 1. See open comments
bash scripts/handle-request.sh

# 2. Create a branch
bash scripts/create-branch.sh "add installments breakdown"

# 3. Make code changes to site/

# 4. Ship it
bash scripts/commit-and-push.sh "feat: add installments breakdown"
bash scripts/create-pr.sh "Add installments breakdown" "Requested via dashboard comment"
```

The PR preview auto-deploys at `shop-pay-gpv-pr-{N}.quick.shopify.io`.

## Project Structure

```
site/               → Dashboard (deployed to Quick)
  index.html        → Main page with all charts and queries
.github/workflows/  → CI/CD
  deploy.yml        → Auto-deploy on push to main
  preview.yml       → PR preview environments
scripts/            → Agent automation
  handle-request.sh → Read comments from Quick DB
  create-branch.sh  → Create feature branch
  commit-and-push.sh→ Stage, commit, push
  create-pr.sh      → Open PR
  notify-slack.sh   → Notify Slack channel
  cleanup-branch.sh → Abandon branch, return to main
```
