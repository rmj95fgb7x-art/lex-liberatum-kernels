// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexFlare
/// @notice 25 bp royalty on oil-field flare-efficiency compliance:
///         destruction efficiency, combustion temperature, exit velocity, smoke opacity.
contract LexFlare is RoyaltySplitter {
    // EPA 40 CFR 60.18 & API RP 537
    uint256 public constant MIN_EFF_percent   = 98;   // ≥ 98 % destruction
    uint256 public constant MIN_TEMP_C        = 650;  // ≥ 650 °C
    uint256 public constant MAX_EXIT_VEL_mps  = 18;   // ≤ 18 m/s
    uint256 public constant MAX_OPACITY_permille = 100; // ≤ 10 % opacity
    uint256 public constant GAS_PER_CALL      = 100_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param effPercent     Destruction efficiency (%)
    /// @param tempC          Combustion temperature (°C)
    /// @param exitVelMps     Exit velocity (m/s)
    /// @param opacityPermille Smoke opacity (0–1000)
    function checkFlare(uint256 effPercent, uint256 tempC, uint256 exitVelMps, uint256 opacityPermille) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 100 * 25 / 1_000_000; // 1.00 multiplier

        bool compliant = (effPercent >= MIN_EFF_percent) &&
                         (tempC >= MIN_TEMP_C) &&
                         (exitVelMps <= MAX_EXIT_VEL_mps) &&
                         (opacityPermille <= MAX_OPACITY_permille);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexFlare-OilGas";
    }
}
