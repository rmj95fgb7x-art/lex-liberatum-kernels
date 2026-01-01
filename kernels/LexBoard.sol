pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexBoard is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MAX_DAYS_SINCE_MINUTES = 60; // ≤ 60 days to approve minutes
    uint256 public constant GAS_PER_CALL           = 65_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param daysSinceMinutes  Days since board minutes issued
    function checkBoard(uint256 daysSinceMinutes) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 65 * 25 / 1_000_000; // 0.65 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = daysSinceMinutes;

        uint256[] memory distances = new uint256[](1);
        distances[0] = daysSinceMinutes;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (daysSinceMinutes > MAX_DAYS_SINCE_MINUTES) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexBoard-Adaptive";
    }
}
