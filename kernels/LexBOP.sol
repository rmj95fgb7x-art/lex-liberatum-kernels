// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexBOP
/// @notice 25 bp royalty on oil-field BOP (Blowout Preventer) pressure-test compliance:
///         test pressure, hold time, temperature range, seal integrity hash.
contract LexBOP is RoyaltySplitter {
    // API RP 53 / 16Q example thresholds
    uint256 public constant MIN_TEST_PSI      = 15_000; // ≥ 15 ksi
    uint256 public constant MIN_HOLD_MIN      = 5;      // ≥ 5 min hold
    uint256 public constant MAX_TEMP_DEV_C    = 10;     // ±10 °C from spec
    uint256 public constant GAS_PER_CALL      = 105_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param testPsi        Actual test pressure (psi)
    /// @param holdMinutes    Hold time at test pressure (minutes)
    /// @param tempDevC       Absolute temperature deviation from spec (°C)
    /// @param sealHash       Keccak-256 of seal-test log (must be non-zero)
    function checkBOP(uint256 testPsi, uint256 holdMinutes, uint256 tempDevC, bytes32 sealHash) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 105 * 25 / 1_000_000; // 1.05 multiplier

        bool compliant = (testPsi >= MIN_TEST_PSI) &&
                         (holdMinutes >= MIN_HOLD_MIN) &&
                         (tempDevC <= MAX_TEMP_DEV_C) &&
                         (sealHash != bytes32(0));

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexBOP-OilGas";
    }
}
