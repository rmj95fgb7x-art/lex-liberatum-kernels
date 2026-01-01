pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexOrbit is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 120_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param signals  Array of telemetry signals (length 512, scaled ×100)
    function checkOrbit(
        uint256[] memory signals
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 120 * 25) / 1_000_000; // 1.20 multiplier

        // signals length must be 512 (power-of-two for FFT)
        require(signals.length == 512, "LexOrbit: signals length != 512");

        // Step 1: compute L2 distances from median (scaled ×100)
        uint256[] memory distances = new uint256[](512);
        uint256[] memory sorted = new uint256[](512);
        for (uint256 i = 0; i < 512; i++) sorted[i] = signals[i];
        // median of 512 → element 255
        uint256 median = sorted[255];
        for (uint256 i = 0; i < 512; i++) {
            int256 diff = int256(signals[i]) - int256(median);
            distances[i] = diff < 0 ? uint256(-diff) : uint256(diff);
        }

        // Step 2: adaptive Gaussian weights
        uint256[] memory weights = adaptiveWeights(distances);

        // Step 3: spectral fusion (weighted average in time domain)
        uint256 sum = 0;
        for (uint256 i = 0; i < 512; i++) {
            sum += signals[i] * weights[i];
        }
        fused = sum / 10000; // scale back

        // Step 4: royalty split if anomaly detected (threshold 3000 permille)
        if (fused > 3000) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexOrbit-Adaptive";
    }
}
