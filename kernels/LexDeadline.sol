// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexDeadline
/// @notice 25 bp royalty on court e-filing deadline compliance:
///         filing deadline proximity, holiday calendar, extension grants, service proof.
contract LexDeadline is RoyaltySplitter {
    // FRCP / state rules example
    uint256 public constant MAX_DAYS_BEFORE_DEADLINE = 1;   // must file ≥ 1 day before
    uint256 public constant MAX_EXTENSION_DAYS        = 30; // ≤ 30 day extension
    uint256 public constant GAS_PER_CALL              = 70_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param daysUntilDeadline  Days until hard filing deadline
    /// @param extensionDays      Granted extension (0 if none)
    /// @param proofOfService     True if service certificate uploaded
    function checkDeadline(uint256 daysUntilDeadline, uint256 extensionDays, bool proofOfService) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 70 * 25 / 1_000_000; // 0.70 multiplier

        bool compliant = (daysUntilDeadline >= MAX_DAYS_BEFORE_DEADLINE) &&
                         (extensionDays <= MAX_EXTENSION_DAYS) &&
                         (proofOfService);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexDeadline-Courts";
    }
}
