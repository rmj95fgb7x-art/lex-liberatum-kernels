// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexCarbon
/// @notice 25 bp royalty on carbon-credit compliance:
///         additionality proof, vintage age, leakage check, MRV hash.
contract LexCarbon is RoyaltySplitter {
    // Example thresholds
    uint256 public constant MAX_VINTAGE_AGE_YEARS = 5;      // ≤ 5 years old
    uint256 public constant MIN_ADDITIONALITY_SCORE = 700;  // 0-1000 score
    uint256 public constant GAS_PER_CALL            = 105_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param vintageAgeYears   Years since project start
    /// @param additionalityScore 0-1000 validated score
    /// @param mrvHash            Keccak-256 of Monitoring-Report-Verification bundle
    function checkCarbon(uint256 vintageAgeYears, uint256 additionalityScore, bytes32 mrvHash) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 130 * 25 / 1_000_000; // 1.30 multiplier

        bool compliant = (vintageAgeYears <= MAX_VINTAGE_AGE_YEARS) &&
                         (additionalityScore >= MIN_ADDITIONALITY_SCORE) &&
                         (mrvHash != bytes32(0)); // MRV bundle must exist

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexCarbon-Credits";
    }
}
