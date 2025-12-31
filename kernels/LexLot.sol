// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexLot
/// @notice 25 bp royalty on pharma lot-recall compliance:
///         recall status, expiry date, chain-of-custody hash, temperature excursion.
contract LexLot is RoyaltySplitter {
    // FDA 21 CFR 211.150 example thresholds
    uint256 public constant MAX_EXPIRY_DAYS       = 30;   // ≤ 30 days to expiry
    uint256 public constant MAX_EXCURSION_HOURS   = 12;   // ≤ 12 h outside 2-8 °C
    uint256 public constant GAS_PER_CALL          = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param daysToExpiry    Days until lot expiry
    /// @param excursionHours  Hours outside cold-chain range
    /// @param custodyHash     Keccak-256 of custody chain (must be non-zero)
    /// @param recalled        True if lot is under active recall
    function checkLot(uint256 daysToExpiry, uint256 excursionHours, bytes32 custodyHash, bool recalled) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        bool compliant = (daysToExpiry >= MAX_EXPIRY_DAYS) &&  // not too close to expiry
                         (excursionHours <= MAX_EXCURSION_HOURS) &&
                         (custodyHash != bytes32(0)) &&
                         (!recalled);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexLot-Recall";
    }
}
