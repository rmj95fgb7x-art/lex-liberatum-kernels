// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexCold
/// @notice 25 bp royalty on pharma cold-chain compliance:
///         2-8 °C storage, temperature logger intact, max excursion time.
contract LexCold is RoyaltySplitter {
    // FDA 21 CFR 211.142 + EU GDP Annex 15
    uint256 public constant MIN_TEMP_C        = 2;   // ≥ 2 °C
    uint256 public constant MAX_TEMP_C        = 8;   // ≤ 8 °C
    uint256 public constant MAX_EXCURSION_MIN = 30;  // ≤ 30 min outside 2-8 °C
    uint256 public constant GAS_PER_CALL      = 90_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param tempC              Current temperature (°C)
    /// @param excursionMin       Minutes outside 2-8 °C
    /// @param loggerIntact       True if data-logger seal unbroken
    function checkCold(uint256 tempC, uint256 excursionMin, bool loggerIntact) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 90 * 25 / 1_000_000; // 0.90 multiplier

        bool compliant = (tempC >= MIN_TEMP_C) &&
                         (tempC <= MAX_TEMP_C) &&
                         (excursionMin <= MAX_EXCURSION_MIN) &&
                         (loggerIntact);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexCold-Pharma";
    }
}
