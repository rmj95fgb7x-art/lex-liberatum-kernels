// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexESG
/// @notice 25 bp royalty on CO₂ emissions exceeding site licence.
///         Call `checkCO2(...)` with hourly tonne reading; royalty splits if > 1 000 t.
contract LexESG is RoyaltySplitter {
    uint256 public constant CO2_LIMIT_TONNES = 1000; // hourly limit
    uint256 public constant GAS_PER_CALL = 105_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param tonnesCO2  Hourly CO₂ tonnes measured by stack sensor
    function checkCO2(uint256 tonnesCO2) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 130 * 25 / 1_000_000; // 1.30 multiplier

        if (tonnesCO2 > CO2_LIMIT_TONNES) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexESG-Carbon";
    }
}
