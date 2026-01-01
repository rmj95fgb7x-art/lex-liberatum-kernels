pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexESGScore is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MIN_SCORE_PERMILLE = 700; // ≥ 70 % ESG score
    uint256 public constant GAS_PER_CALL       = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param scorePermille  ESG score (0–1000)
    function checkESGScore(uint256 scorePermille) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = scorePermille;

        uint256[] memory distances = new uint256[](1);
        distances[0] = scorePermille;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (scorePermille < MIN_SCORE_PERMILLE) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexESGScore-Adaptive";
    }
}

