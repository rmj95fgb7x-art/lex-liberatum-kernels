pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexESG is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 105_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ageYears  Years since carbon-credit vintage
    function checkESG(uint256 ageYears) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 130 * 25 / 1_000_000; // 1.30 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = ageYears;

        uint256[] memory distances = new uint256[](1);
        distances[0] = ageYears;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (ageYears > 5) { // 5-year vintage limit
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexESG-Adaptive";
    }
}
