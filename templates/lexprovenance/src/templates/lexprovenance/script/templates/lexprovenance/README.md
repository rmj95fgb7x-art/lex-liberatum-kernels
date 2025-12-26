# LexProvenance – Art & Antiques Provenance Certificate Logger (UNESCO/CITES)

## What it does
- Accepts artifact ID + sale price (cents) + provenance score + timestamp
- Returns **Authenticated / Rejected** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexProvenance.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `authenticateArtifact(artifactId, priceCents, score)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
