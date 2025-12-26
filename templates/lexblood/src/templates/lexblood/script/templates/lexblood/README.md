# LexBlood – Blood/Plasma Donation Certificate Logger (FDA/AABB)

## What it does
- Accepts donation ID + blood type + volume (mL) + timestamp
- Returns **Approved / Rejected** certificate + SHA-3 hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexBlood.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `submitDonation(donationId, bloodType, volumeMl)` – royalty appears instantly.

## Royalty
Same splitter address as main repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
