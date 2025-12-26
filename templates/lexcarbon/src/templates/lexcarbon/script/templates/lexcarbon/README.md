# LexCarbon – Carbon-Credit Retirement Logger (Verra/EU ETS)

## What it does
- Accepts credit ID + tonnes retired + vintage year + timestamp
- Returns **Retired / Rejected** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexCarbon.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `retireCredit(creditId, tonnes, vintageYear)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
