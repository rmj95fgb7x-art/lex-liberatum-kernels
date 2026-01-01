// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexShip
/// @notice 25 bp royalty on ballast-water D-2 standard violations.
///         Call `checkBallast(...)` with organism count/m³; royalty splits if > 10 organisms ≥ 50 µm.
contract LexShip is RoyaltySplitter {
    uint256 public constant ORG_LIMIT_per_m3 = 10; // IMO D-2 limit for ≥50 µm organisms
    uint256 public constant GAS_PER_CALL = 90_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param organismsPerCubicM  Organism count per m³ from ballast sensor
    function checkBallast(uint256 organismsPerCubicM) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 115 * 25) / 1_000_000; // 1.15 multiplier

        if (organismsPerCubicM > ORG_LIMIT_per_m3) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexShip-Ballast";
    }
}
