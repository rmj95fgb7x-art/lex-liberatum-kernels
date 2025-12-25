# LexClaim – Immutable Insurance-Claim Adapter

## What it does
- Accepts policy hash + claim hash + evidence IPFS hashes + claimed USD  
- Returns **Approved / Rejected / Flagged** certificate + Keccak hash  
- 25 bp of gas cost **automatically skimmed** to trust splitter

## Quick start (mobile)
1. Compile kernel: `cargo check --release`  
2. Deploy adapter: `forge script script/DeployLexClaim.sol --rpc-url $BASE_RPC --private-key $PK --broadcast`  
3. Call `fileClaim(...)` – royalty appears instantly.

## Royalty
Same splitter address as repo → royalties aggregate into trust.

## Licence
Lex-Libertatum-1.0 – do not remove splitter or certificate hash check.
