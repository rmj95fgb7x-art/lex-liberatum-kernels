// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexDerm
/// @notice 25 bp royalty on FDA cosmetic ingredient compliance:
///         banned substances, label claims, allergen declarations.
contract LexDerm is RoyaltySplitter {
    // FDA banned / restricted cosmetic ingredients (example INCI hashes)
    bytes32 public constant BANNED_1 = keccak256("Hydroquinone");
    bytes32 public constant BANNED_2 = keccak256("Mercury");
    uint256 public constant CLAIM_MAX_LENGTH = 200;        // max claim chars
    uint256 public constant GAS_PER_CALL     = 95_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ingredientHash  Keccak-256 of primary INCI name
    /// @param claimLength     Length of cosmetic claim text
    /// @param hasAllergens    True if contains known allergens
    function checkDerm(bytes32 ingredientHash, uint256 claimLength, bool hasAllergens) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 95 * 25 / 1_000_000; // 0.95 multiplier

        bool compliant = (ingredientHash != BANNED_1) &&
                         (ingredientHash != BANNED_2) &&
                         (claimLength <= CLAIM_MAX_LENGTH) &&
                         (hasAllergens == true); // must declare allergens

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexDerm-Cosmetics";
    }
}
