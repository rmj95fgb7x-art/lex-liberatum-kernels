pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexCola is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 100_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param abvPercent       Alcohol by volume (×100, e.g., 5.0 % → 50)
    /// @param hasWarning       True if Surgeon-General warning present
    /// @param labelSizeCm2     Front-label area (cm²)
    function checkCola(
        uint256 abvPercent,
        bool hasWarning,
        uint256 labelSizeCm2
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 100 * 25) / 1_000_000; // 1.00 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = abvPercent;
        signals[1] = hasWarning ? 1 : 0;
        signals[2] = labelSizeCm2;

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
        fused = sum / 10000;

        bool compliant = (abvPercent >= 40) &&
            (abvPercent <= 700) &&
            (hasWarning) &&
            (labelSizeCm2 >= 25);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexCola-Adaptive";
    }
}
