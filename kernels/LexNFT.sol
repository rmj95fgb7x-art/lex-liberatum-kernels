// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexNFT
/// @notice 25 bp royalty on pixel-diff similarity of generative-art mints.
///         Call `checkRemix(...)` with Hamming-distance ratio; royalty splits if > 5 % match.
contract LexNFT is RoyaltySplitter {
    uint256 public constant MATCH_THRESHOLD_PER_MILLE = 50; // 5 %
    uint256 public constant GAS_PER_CALL = 95_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param hashNew   Keccak-256 of new artwork pixels
    /// @param hashOld   Keccak-256 of prior artwork being compared
    /// @param matchPermille  Pre-computed similarity 0–1000 (‰)
    function checkRemix(
        bytes32 hashNew,
        bytes32 hashOld,
        uint256 matchPermille
    ) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 120 * 25) / 1_000_000; // 1.20 multiplier

        if (matchPermille > MATCH_THRESHOLD_PER_MILLE) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexNFT-GenerativeArt";
    }
}
