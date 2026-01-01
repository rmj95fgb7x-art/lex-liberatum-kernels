// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexAudit is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MAX_OPINION_AGE_MONTHS = 12; // ≤ 12 months old
    uint256 public constant GAS_PER_CALL           = 70_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ageMonths  Months since audit opinion issued
    function checkAudit(uint256 ageMonths) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 70 * 25 / 1_000_000; // 0.70 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = ageMonths;

        uint256[] memory distances = new uint256[](1);
        distances[0] = ageMonths;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (ageMonths > MAX_OPINION_AGE_MONTHS) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexAudit-Adaptive";
    }
}
