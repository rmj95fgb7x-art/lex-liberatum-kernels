// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexRedact
/// @notice 25 bp royalty on automatic PII redaction compliance:
///         SSN count, DOB count, address count, redaction coverage %.
contract LexRedact is RoyaltySplitter {
    // FRCP 5.2 / state e-filing rules
    uint256 public constant MAX_SSN_COUNT     = 0;   // zero SSNs visible
    uint256 public constant MAX_DOB_COUNT     = 0;   // zero DOBs visible
    uint256 public constant MIN_REDACT_PERCENT = 95; // ≥ 95 % coverage
    uint256 public constant GAS_PER_CALL      = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ssnCount        Number of visible SSNs
    /// @param dobCount        Number of visible dates of birth
    /// @param redactPercent   Automated redaction coverage (0-100)
    function checkRedact(uint256 ssnCount, uint256 dobCount, uint256 redactPercent) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        bool compliant = (ssnCount <= MAX_SSN_COUNT) &&
                         (dobCount <= MAX_DOB_COUNT) &&
                         (redactPercent >= MIN_REDACT_PERCENT);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexRedact-Courts";
    }
}
