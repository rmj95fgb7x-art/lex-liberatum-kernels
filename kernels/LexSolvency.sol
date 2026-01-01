pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexSolvency is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MIN_SOLVENCY_RATIO_PERMILLE = 150; // ≥ 150 % assets / liabilities
    uint256 public constant GAS_PER_CALL                = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ratioPermille  Solvency ratio (permille)
    function checkSolvency(uint256 ratioPermille) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = ratioPermille;

        uint256[] memory distances = new uint256[](1);
        distances[0] = ratioPermille;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (ratioPermille < MIN_SOLVENCY_RATIO_PERMILLE) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexSolvency-Adaptive";
    }
}
