# Changelog

All notable changes to the Lex Liberatum Kernels project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-12-30
### Fixed
- **Economic Model Correction**: Removed incorrect gas-based royalty calculations  
  - Previous: Incorrectly calculated royalties based on gas costs ($4M-$9M/year per vertical)  
  - Current: Correct application-fee-based model ($6k-$60k/year per vertical)  
  - Root cause: Confusion between gas price (gwei) and USD pricing  
  - Impact: Projections were inflated by ~10,000×  
- Removed hard-coded pricing constants from kernel implementations  
  - `LexOrbit.sol`, `LexChart.sol`, `LexDocket.sol` now return only `Decision` types  
  - Pricing logic moved to smart-contract and API layers  
- Updated all economic projections to realistic ranges  
  - Single vertical: $3k-$60k/year (depending on volume and adoption)  
  - 5 verticals: ~$88k/year  
  - 10 verticals: $200k-$600k/year (moderate to high adoption)  

### Changed
- README.md completely rewritten with accurate economics  
- Kernel architecture improved: clean separation between compliance logic and pricing  
- Multi-vertical projection table updated with realistic adoption scenarios  
- Removed misleading “Daily Gas” calculations from documentation  
- Updated all examples to reflect fee-based revenue model  

### Added
- CHANGELOG.md to track version history  
- Clear explanation of revenue model (application fees vs gas costs)  
- Detailed scaling formulas with worked examples  
- Active bounty section ($1,500 for Base Sepolia deployment)  

### Technical Details
- All `.sol` kernel files refactored to remove `const DECISION_FEE` and similar  
- Smart contract `RoyaltySplitter.sol` unchanged (25 bp calculation remains correct)  
- Tests updated to match new kernel function signatures  

## [1.0.0] - 2025-12-28
### Added
- Initial release with 3 working kernels  
- 130+ parameterized kernel templates in `kernels-133.zip`  
- `RoyaltySplitter.sol` smart contract with 25 bp royalty routing  
- Rust workspace with `no_std` support for embedded deployments  
- Solidity deployment scripts via Foundry  
- Trust structure documentation  
- `quickstart.sh` for automated setup  

### Known Issues
- Economic model documentation contained significant errors (fixed in v1.0.1)  
- RoyaltySplitter not yet deployed to Base Sepolia (bounty active)  
- No external security audit completed  

## [Unreleased]
### Planned
- KEX governance token launch  
- CREATE2 deterministic factory for multi-chain deployment  
- Oracle integration for off-chain compute verification  
- External security audit (Trail of Bits or OpenZeppelin)  
- Mainnet deployment across Arbitrum, Optimism, Base, Polygon  
- $500k+ annual royalty target  
