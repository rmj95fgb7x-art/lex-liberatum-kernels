pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexNFT is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant GAS_PER_CALL = 95_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    function checkNFT(uint256[] memory hashDiffs) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 95 * 25 / 1_000_000; // 0.95 multiplier

        uint256[] memory distances = new uint256[](hashDiffs.length);
        uint256[] memory sorted = new uint256[](hashDiffs.length);
        for (uint256 i = 0; i < hashDiffs.length; i++) sorted[i] = hashDiffs[i];
        uint256 median = sorted[sorted.length / 2];
        for (uint256 i = 0; i < hashDiffs.length; i++) {
            int256 diff = int256(hashDiffs[i]) - int256(median);
            distances[i] = diff < 0 ? uint256(-diff) : uint256(diff);
        }

        uint256[] memory weights = adaptiveWeights(distances);
        uint256 sum = 0;
        for (uint256 i = 0; i < hashDiffs.length; i++) {
            sum += hashDiffs[i] * weights[i];
        }
        fused = sum / 10000;

        if (fused > 5000) { // 50 % similarity threshold
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexNFT-Adaptive";
    }
}
