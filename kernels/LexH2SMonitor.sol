pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexH2SMonitor is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MAX_H2S_PPM = 10; // ≤ 10 ppm TWA
    uint256 public constant GAS_PER_CALL= 95_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param h2sPpm  Current H₂S reading (ppm)
    function checkH2SMonitor(uint256 h2sPpm) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 95 * 25 / 1_000_000; // 0.95 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = h2sPpm;

        uint256[] memory distances = new uint256[](1);
        distances[0] = h2sPpm;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (h2sPpm > MAX_H2S_PPM) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexH2SMonitor-Adaptive";
    }
}
