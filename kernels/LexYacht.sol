// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexYacht
/// @notice 25 bp royalty on yacht-charter safety compliance:
///         passenger count, safety drill log, weather forecast, insurance expiry.
contract LexYacht is RoyaltySplitter {
    // IMO/MCA day-charter limits
    uint256 public constant MAX_PASSENGERS      = 12;   // ≤ 12 passengers
    uint256 public constant MIN_DRILL_HOURS     = 24;   // drill within last 24 h
    uint256 public constant MAX_WIND_KNOTS      = 33;   // ≤ 33 knots (Beaufort 7)
    uint256 public constant GAS_PER_CALL        = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param passengerCount  Number of passengers on manifest
    /// @param hoursSinceDrill Hours since last safety drill
    /// @param windForecastKnots Predicted wind speed (knots)
    /// @param insuranceValid  True if P&I insurance still valid
    function checkYacht(
        uint256 passengerCount,
        uint256 hoursSinceDrill,
        uint256 windForecastKnots,
        bool insuranceValid
    ) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        bool compliant = (passengerCount <= MAX_PASSENGERS) &&
                         (hoursSinceDrill <= MIN_DRILL_HOURS) &&
                         (windForecastKnots <= MAX_WIND_KNOTS) &&
                         (insuranceValid);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexYacht-Charter";
    }
}
