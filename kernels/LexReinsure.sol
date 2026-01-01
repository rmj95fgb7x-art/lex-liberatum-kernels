pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexReinsure is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant MAX_COVER_PERCENT = 100; // ≤ 100 % of sum insured
    uint256 public constant GAS_PER_CALL      = 75_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param coverPercent  Reinsurance cover as % of sum insured
    function checkReinsure(uint256 coverPercent) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 75 * 25 / 1_000_000; // 0.75 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = coverPercent;

        uint256[] memory distances = new uint256[](1);
        distances[0] = coverPercent;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (coverPercent > MAX_COVER_PERCENT) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexReinsure-Adaptive";
    }
}
