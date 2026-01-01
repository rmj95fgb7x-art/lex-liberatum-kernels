pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexBlood is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param maxTempC        Highest temperature recorded (°C)
    /// @param outOfRangeMin   Minutes outside 1-6 °C range
    /// @param sealIntact      True if transport seal is unbroken
    function checkBlood(uint256 maxTempC, uint256 outOfRangeMin, bool sealIntact) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = maxTempC;
        signals[1] = outOfRangeMin;
        signals[2] = sealIntact ? 1 : 0;

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

        bool compliant = (maxTempC <= 6) &&
                         (maxTempC >= 1) &&
                         (outOfRangeMin <= 30) &&
                         (sealIntact);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexBlood-Adaptive";
    }
}
