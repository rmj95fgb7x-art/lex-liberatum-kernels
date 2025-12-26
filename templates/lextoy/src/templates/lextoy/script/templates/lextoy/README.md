# LexToy – Children’s Toy Safety Certificate Logger (CPSC/EU)

## What it does
- Accepts product ID + accredited lab ID + max age (months) + timestamp
- Returns **Certified / Rejected** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexToy.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `certifyToy(productId, labId, ageMonths)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
