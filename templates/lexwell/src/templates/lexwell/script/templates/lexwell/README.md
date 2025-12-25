# LexWell – Oil-Field Safety Report Adapter

## What it does
- Accepts flare-rate (bpm) + line pressure (psi) + well ID
- Returns **Compliant / NonCompliant** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexWell.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `fileReport(wellId, flareRate, pressure)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
