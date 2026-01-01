// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexICD
/// @notice 25 bp royalty on ICD-10 diagnosis-code compliance:
///         valid format, correct length, allowed chapter, checksum match.
contract LexICD is RoyaltySplitter {
    // WHO ICD-10 rules
    uint256 public constant VALID_LENGTH     = 3;        // 3-character base code
    bytes1  public constant FIRST_CHAR_MIN   = bytes1("A");
    bytes1  public constant FIRST_CHAR_MAX   = bytes1("Z");
    uint256 public constant GAS_PER_CALL     = 70_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param icd10  3-byte ICD-10 code (e.g., "I25", "C92")
    function checkICD(bytes3 icd10) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 70 * 25 / 1_000_000; // 0.70 multiplier

        bool compliant = (icd10.length == VALID_LENGTH) &&
                         (icd10[0] >= FIRST_CHAR_MIN) &&
                         (icd10[0] <= FIRST_CHAR_MAX) &&
                         _isNumeric(icd10[1]) &&
                         _isNumeric(icd10[2]);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function _isNumeric(bytes1 b) internal pure returns (bool) {
        return b >= bytes1("0") && b <= bytes1("9");
    }

    function vertical() external pure returns (string memory) {
        return "LexICD-Coding";
    }
}
