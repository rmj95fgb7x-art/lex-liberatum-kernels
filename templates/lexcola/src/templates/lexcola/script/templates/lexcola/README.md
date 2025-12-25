# LexCola – TTB Bottle Label (COLA) Approval Logger

## What it does
- Accepts COLA application ID + ABV (%) + bottle volume (mL) + timestamp
- Returns **Approved / Rejected** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexCola.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `submitCola(colaId, abv, volumeMl)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
