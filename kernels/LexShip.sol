pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexShip is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 90_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param organismsPerCubicM  Organism count per m³ from ballast sensor
    function checkBallast(
        uint256 organismsPerCubicM
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 90 * 25) / 1_000_000; // 0.90 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = organismsPerCubicM;

        uint256[] memory distances = new uint256[](1);
        distances[0] = organismsPerCubicM;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = (signals[0] * weights[0]) / 10000;

        if (organismsPerCubicM > 10) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexShip-Adaptive";
    }
}
