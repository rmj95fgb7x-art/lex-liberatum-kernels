// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexChart
/// @notice 25 bp royalty on pharma prior-authorisation decisions.
///         Call `checkChart(...)` with ICD-10 & dosage; royalty splits if prior-auth required.
contract LexChart is RoyaltySplitter {
    // Common high-cost biologics requiring prior-auth (example ICD-10 prefixes)
    bytes3[] public PRIOR_AUTH_ICD10 = [bytes3("L40"), bytes3("M05"), bytes3("K50"), bytes3("C92")];
    uint256  public constant GAS_PER_CALL = 120_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param icd10      Patient primary ICD-10 code (3-byte prefix)
    /// @param dosageMg   Daily dosage in milligrams
    /// @param costUSD    Estimated drug cost per month (USD)
    function checkChart(bytes3 icd10, uint256 dosageMg, uint256 costUSD) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 120 * 25 / 1_000_000; // 1.20 multiplier

        bool requiresAuth = requiresPriorAuth(icd10, dosageMg, costUSD);

        if (requiresAuth) {
            _splitRoyalty(royaltyWei);
        }
    }

    function requiresPriorAuth(bytes3 icd10, uint256 dosageMg, uint256 costUSD)
        internal
        view
        returns (bool)
    {
        if (costUSD > 1000) return true;                       // high-cost trigger
        for (uint i = 0; i < PRIOR_AUTH_ICD10.length; i++) {
            if (icd10 == PRIOR_AUTH_ICD10[i]) return true;     // ICD-10 trigger
        }
        return false;
    }

    function vertical() external pure returns (string memory) {
        return "LexChart-Pharma";
    }
}
