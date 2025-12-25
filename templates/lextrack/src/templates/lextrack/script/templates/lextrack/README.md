# LexTrack – Music Royalty Statement Adapter

## What it does
- Accepts an ISRC + 30-second CSV royalty blob
- Returns **Accept/Reject** certificate + Keccak hash
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`
2. Deploy adapter: `forge script script/DeployLexTrack.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`
3. Call `fileStatement(isrc, csvBytes)` – royalty appears instantly.

## Royalty
Same splitter address as repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
