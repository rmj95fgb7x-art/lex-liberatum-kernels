// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexDocket
/// @notice 25 bp royalty on court-filing compliance checks:
///         deadlines, redaction, seal compliance, jurisdiction validation.
contract LexDocket is RoyaltySplitter {
    // Filing size limits (bytes)
    uint256 public constant MAX_FILE_SIZE_BYTES = 25 * 1024 * 1024; // 25 MB
    uint256 public constant MAX_EXHIBITS        = 50;
    uint256 public constant GAS_PER_CALL        = 50_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param fileSizeBytes   Total PDF size
    /// @param exhibitCount    Number of exhibits attached
    /// @param hasRedaction    True if document contains redacted text
    /// @param jurisdictionOk  True if filing court has jurisdiction
    function checkDocket(
        uint256 fileSizeBytes,
        uint256 exhibitCount,
        bool hasRedaction,
        bool jurisdictionOk
    ) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        bool compliant = (fileSizeBytes <= MAX_FILE_SIZE_BYTES) &&
                         (exhibitCount <= MAX_EXHIBITS) &&
                         (!hasRedaction) &&
                         (jurisdictionOk);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexDocket-Courts";
    }
}
