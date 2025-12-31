// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexCola
/// @notice 25 bp royalty on TTB (Alcohol & Tobacco Tax and Trade Bureau) bottle-label compliance:
///         alcohol content, surgeon-general warning, brand name, label size.
contract LexCola is RoyaltySplitter {
    // TTB thresholds
    uint256 public constant ALCOHOL_MIN_PERCENT = 40;   // 4.0 % ABV
    uint256 public constant ALCOHOL_MAX_PERCENT = 700;  // 70 % ABV
    uint256 public constant LABEL_SIZE_MIN_cm2 = 25;    // 25 cm²
    uint256 public constant GAS_PER_CALL       = 100_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param abvPercent       Alcohol by volume (×100, e.g., 5.0 % → 50)
    /// @param hasWarning       True if Surgeon-General warning present
    /// @param labelSizeCm2     Front-label area (cm²)
    function checkCola(uint256 abvPercent, bool hasWarning, uint256 labelSizeCm2) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 100 * 25 / 1_000_000; // 1.00 multiplier

        bool compliant = (abvPercent >= ALCOHOL_MIN_PERCENT) &&
                         (abvPercent <= ALCOHOL_MAX_PERCENT) &&
                         (hasWarning) &&
                         (labelSizeCm2 >= LABEL_SIZE_MIN_cm2);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexCola-TTB";
    }
}
