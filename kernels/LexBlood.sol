// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexBlood
/// @notice 25 bp royalty on blood-bank cold-chain compliance:
///         temperature excursion, time-out-of-refrigeration, transport integrity.
contract LexBlood is RoyaltySplitter {
    // AABB standards
    uint256 public constant MAX_TEMP_C        = 6;   // ≤ 6 °C
    uint256 public constant MIN_TEMP_C        = 1;   // ≥ 1 °C
    uint256 public constant MAX_OUT_TIME_MIN  = 30;  // ≤ 30 min outside 1-6 °C
    uint256 public constant GAS_PER_CALL      = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param maxTempC        Highest temperature recorded (°C)
    /// @param outOfRangeMin   Minutes outside 1-6 °C range
    /// @param sealIntact      True if transport seal is unbroken
    function checkBlood(uint256 maxTempC, uint256 outOfRangeMin, bool sealIntact) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        bool compliant = (maxTempC <= MAX_TEMP_C) &&
                         (maxTempC >= MIN_TEMP_C) &&
                         (outOfRangeMin <= MAX_OUT_TIME_MIN) &&
                         (sealIntact);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexBlood-ColdChain";
    }
}
