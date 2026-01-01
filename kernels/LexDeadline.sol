// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexDeadline is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MAX_DAYS_BEFORE_DEADLINE = 1;   // must file ≥ 1 day before
    uint256 public constant MAX_EXTENSION_DAYS        = 30; // ≤ 30 day extension
    uint256 public constant GAS_PER_CALL              = 70_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param daysUntilDeadline  Days until hard filing deadline
    /// @param extensionDays      Granted extension (0 if none)
    /// @param proofOfService     True if service certificate uploaded
    function checkDeadline(uint256 daysUntilDeadline, uint256 extensionDays, bool proofOfService) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 70 * 25 / 1_000_000; // 0.70 multiplier

        // Build signal vector: [daysUntilDeadline, extensionDays, proofOfService?1:0]
        uint256[] memory signals = new uint256[](3);
        signals[0] = daysUntilDeadline;
        signals[1] = extensionDays;
        signals[2] = proofOfService ? 1 : 0;

        // Adaptive fusion
        uint256[] memory distances = new uint256[](3);
        uint256[] memory sorted = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) sorted[i] = signals[i];
        uint256 median = sorted[1]; // length = 3 → median at index 1
        for (uint256 i = 0; i < 3; i++) {
            int256 diff = int256(signals[i]) - int256(median);
            distances[i] = diff < 0 ? uint256(-diff) : uint256(diff);
        }

        uint256[] memory weights = adaptiveWeights(distances);
        uint256 sum = 0;
        for (uint256 i = 0; i < 3; i++) {
            sum += signals[i] * weights[i];
        }
        fused = sum / 10000; // scale back

        if (fused > 1500) { // 15-day threshold (scaled)
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexDeadline-Adaptive";
    }
}
