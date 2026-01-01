pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexSpill is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MAX_SPILL_LITRES = 100; // ≤ 100 L
    uint256 public constant GAS_PER_CALL     = 90_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param spillLitres  Spill volume (litres)
    function checkSpill(uint256 spillLitres) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 90 * 25 / 1_000_000; // 0.90 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = spillLitres;

        uint256[] memory distances = new uint256[](1);
        distances[0] = spillLitres;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (spillLitres > MAX_SPILL_LITRES) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexSpill-Adaptive";
    }
}
