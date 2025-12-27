# KEX – Kernel Economic Index

Turn compliance work into yield-bearing infrastructure.

## stack
- `oracle/` – on-chain telemetry scraper → daily CSV
- `index/` – fee-weighted / volume-weighted / equal-weighted indices
- `dashboard/` – live index levels (coming next)

## quick run
```bash
# 1. export daily telemetry
cargo run --bin kex-oracle -- -d 19743 -o day.csv

# 2. compute index weights
cargo run --bin kex-index
