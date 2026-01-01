pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexCrypto is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 75_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param priceDeltaPermille  Absolute price delta from oracle (permille)
    /// @param secondsSinceUpdate  Seconds since last oracle update
    /// @param sequencerUptimePermille Sequencer uptime over window (0–1000)
    function checkCrypto(uint256 priceDeltaPermille, uint256 secondsSinceUpdate, uint256 sequencerUptimePermille) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 75 * 25 / 1_000_000; // 0.75 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = priceDeltaPermille;
        signals[1] = secondsSinceUpdate;
        signals[2] = sequencerUptimePermille;

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

        bool compliant = (priceDeltaPermille <= 50) &&
                         (secondsSinceUpdate <= 120) &&
                         (sequencerUptimePermille >= 990);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexCrypto-Adaptive";
    }
}
