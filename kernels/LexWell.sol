// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexWell
/// @notice 25 bp royalty on well-safety anomalies: BOP pressure, flare efficiency, H₂S levels.
///         Call `checkWell(...)` with encoded safety report; royalty splits if any threshold exceeded.
contract LexWell is RoyaltySplitter {
    // OSHA / API thresholds
    uint256 public constant BOP_PRESSURE_MAX_psi   = 15_000; // 15 ksi
    uint256 public constant FLARE_EFF_MIN_percent  = 98;    // 98 % destruction efficiency
    uint256 public constant H2S_MAX_ppm            = 10;    // 10 ppm TWA
    uint256 public constant GAS_PER_CALL           = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param bopPsi      Current BOP pressure (psi)
    /// @param flareEff    Flare destruction efficiency (%)
    /// @param h2sPpm      H₂S concentration (ppm)
    function checkWell(uint256 bopPsi, uint256 flareEff, uint256 h2sPpm) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 115 * 25 / 1_000_000; // 1.15 multiplier

        bool anomaly = (bopPsi > BOP_PRESSURE_MAX_psi) ||
                       (flareEff < FLARE_EFF_MIN_percent) ||
                       (h2sPpm > H2S_MAX_ppm);

        if (anomaly) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexWell-OilSafety";
    }
}
