// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexH2S
/// @notice 25 bp royalty on oil-field H₂S (hydrogen sulfide) exposure compliance:
///         ppm reading, exposure duration, detector calibration, evacuation drill.
contract LexH2S is RoyaltySplitter {
    // OSHA 29 CFR 1910.1000 & API RP 49
    uint256 public constant MAX_H2S_PPM          = 10;   // 10 ppm TWA 8-h
    uint256 public constant MAX_EXPOSURE_MIN     = 480;  // 8-h equivalent
    uint256 public constant MAX_CAL_DAYS         = 30;   // ≤ 30 days since cal
    uint256 public constant GAS_PER_CALL         = 95_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param h2sPpm          Current H₂S reading (ppm)
    /// @param exposureMin     Minutes exposed this shift
    /// @param daysSinceCal    Days since last detector calibration
    /// @param drillCompleted  True if evacuation drill done this month
    function checkH2S(uint256 h2sPpm, uint256 exposureMin, uint256 daysSinceCal, bool drillCompleted) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 95 * 25 / 1_000_000; // 0.95 multiplier

        bool compliant = (h2sPpm <= MAX_H2S_PPM) &&
                         (exposureMin <= MAX_EXPOSURE_MIN) &&
                         (daysSinceCal <= MAX_CAL_DAYS) &&
                         (drillCompleted);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexH2S-OilGas";
    }
}
