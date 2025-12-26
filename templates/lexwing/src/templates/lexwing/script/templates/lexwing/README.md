# LexWing – Aircraft Airworthiness Certificate Logger (FAA/EASA)

## What it does
- Accepts tail number + max take-off weight (kg) + passenger capacity + timestamp
- Returns **Certified / Rejected** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexWing.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `certifyAircraft(tailNumber, mtowKg, passengerCap)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
