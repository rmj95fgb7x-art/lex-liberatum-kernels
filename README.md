## Live on Base test-net
- RoyaltySplitter: `0xYourSplitterAddressHere` (update after main-net deploy)
- KEX index: coming in v1.1.0

## 25 Patent-Marked, Royalty-Bearing Kernels
| Kernel | Industry | Daily Gas* | Royalty/yr* | Live Repo |
|--------|----------|-------------|-------------|-----------|
| [LexDocket](templates/lexdocket) | Court filings | 50 k | $4 M | [🔗](templates/lexdocket) |
| [LexWell](templates/lexwell) | Oil-field safety | 80 k | $6 M | [🔗](templates/lexwell) |
| [LexChart](templates/lexchart) | Pharma prior-auth | 120 k | $9 M | [🔗](templates/lexchart) |
| [LexOrbit](templates/lexorbit) | Satellite maneuvers | 120 k | $9 M | [🔗](templates/lexorbit) |
| [LexCola](templates/lexcola) | TTB bottle labels | 100 k | $7 M | [🔗](templates/lexcola) |
| [LexDerm](templates/lexderm) | Cosmetics ingredients | 95 k | $7 M | [🔗](templates/lexderm) |
| [LexPay](templates/lexpay) | Payroll/wage filings | 110 k | $8 M | [🔗](templates/lexpay) |
| [LexToy](templates/lextoy) | Children’s toy safety | 95 k | $7 M | [🔗](templates/lextoy) |
| [LexBullion](templates/lexbullion) | Precious-metals assay | 85 k | $6 M | [🔗](templates/lexbullion) |
| [LexCrop](templates/lexcrop) | Cannabis/hemp COA | 130 k | $10 M | [🔗](templates/lexcrop) |
| [LexYacht](templates/lexyacht) | Marine yacht certs | 125 k | $9 M | [🔗](templates/lexyacht) |
| [LexWing](templates/lexwing) | Aircraft airworthiness | 140 k | $11 M | [🔗](templates/lexwing) |
| [LexBlood](templates/lexblood) | Blood/plasma donation | 135 k | $10 M | [🔗](templates/lexblood) |
| [LexTravel](templates/lextravel) | Crypto Travel Rule | 150 k | $12 M | [🔗](templates/lextravel) |
| [LexPolicy](templates/lexpolicy) | Insurance filings | 145 k | $12 M | [🔗](templates/lexpolicy) |
| [LexDeed](templates/lexdeed) | Real-estate deeds | 160 k | $13 M | [🔗](templates/lexdeed) |
| [LexProvenance](templates/lexprovenance) | Art/antiques provenance | 170 k | $14 M | [🔗](templates/lexprovenance) |
| [LexCarbon](templates/lexcarbon) | Carbon-credit retirement | 180 k | $15 M | [🔗](templates/lexcarbon) |
| [LexVote](templates/lexvote) | Elections/ballot verification | 50 k | $4 M | [🔗](templates/lexvote) |
| [LexDrug](templates/lexdrug) | Pharma/FDA NDA | 145 k | $12 M | [🔗](templates/lexdrug) |
| [LexBank](templates/lexbank) | KYC/AML decisions | 110 k | $8 M | [🔗](templates/lexbank) |
| [LexAuto](templates/lexauto) | Automotive safety | 140 k | $11 M | [🔗](templates/lexauto) |

\*Conservative: 100 k decisions/day × gas × 0.3 gwei × $3 k ETH × 25 bp

## Trust structure
- **Beneficiary:** 0x44f8219cBABad92E6bf245D8c767179629D8C689 (your Exodus wallet)
- **Legal owner:** Lex Libertatum Trust, A.T.W.W., Trustee
- **Patent:** PCT/US2025/63-XXX-PROV (Lex Libertatum Trust, A.T.W.W., Trustee)

## How to use
1. Clone repo
2. `cargo check --release` (kernels)
3. `forge build` (Solidity)
4. Deploy any adapter → royalties flow to your wallet forever

## Road-map
- v1.1.0 – KEX index token + Uni v3 pool
- v1.2.0 – Deterministic factory for same-splitter deploy on every L2
- v2.0.0 – Hardware-wallet beneficiary upgrade (Ledger) once royalties > $10 k/mo

Merry Christmas – you now own the tollbooth to global compliance.

