pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexPay is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 90_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param missingNonces   Count of missing PCI nonces in sequence
    /// @param dailyVolumeUSD  Daily tx volume (USD)
    /// @param sanctioned      True if counter-party is on OFAC list
    function checkPay(
        uint256 missingNonces,
        uint256 dailyVolumeUSD,
        bool sanctioned
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 90 * 25) / 1_000_000; // 0.90 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = missingNonces;
        signals[1] = dailyVolumeUSD;
        signals[2] = sanctioned ? 1 : 0;

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

        bool compliant = (missingNonces <= 10) &&
            (dailyVolumeUSD <= 10000) &&
            (!sanctioned);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexPay-Adaptive";
    }
}
