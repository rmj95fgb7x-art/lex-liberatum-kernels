// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexSAR
/// @notice 25 bp royalty on satellite SAR (Specific Absorption Rate) limit compliance.
///         Call `checkSAR(...)` with daily mW/kg value; royalty auto-splits if > 1.6 W/kg.
contract LexSAR is RoyaltySplitter {
    // EU/ICNIRP limit: 1.6 W/kg averaged over 1 g tissue
    uint256 public constant SAR_LIMIT_mW_per_kg = 1600; // 1.6 W/kg in mW/kg
    uint256 public constant GAS_PER_CALL = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param measuredSAR_mWkg  Daily peak SAR reading (mW/kg) from satellite payload
    function checkSAR(uint256 measuredSAR_mWkg) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        // royalty = gas * basefee * verticalMultiplier * 0.0025
        uint256 royaltyWei = gasUsed * baseFee * 100 * 25 / 1_000_000; // 1.00 multiplier

        if (measuredSAR_mWkg > SAR_LIMIT_mW_per_kg) {
            // anomaly detected → enforce royalty
            _splitRoyalty{value: royaltyWei}();
        }
    }

    // expose vertical name for factory registry
    function vertical() external pure returns (string memory) {
        return "LexSAR-SatelliteSAR";
    }
}
