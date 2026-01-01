pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexFlareEff is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant MIN_EFF_PERCENT = 98; // ≥ 98 % destruction
    uint256 public constant GAS_PER_CALL    = 100_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param effPercent     Destruction efficiency (%)
    function checkFlareEff(uint256 effPercent) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 100 * 25 / 1_000_000; // 1.00 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = effPercent;

        uint256[] memory distances = new uint256[](1);
        distances[0] = effPercent;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (effPercent < MIN_EFF_PERCENT) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexFlareEff-Adaptive";
    }
}
