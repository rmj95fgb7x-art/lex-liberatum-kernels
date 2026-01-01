pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexActuary is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant MAX_TABLE_AGE_YEARS = 5; // ≤ 5 years old
    uint256 public constant GAS_PER_CALL        = 70_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ageYears  Years since actuarial table publication
    function checkActuary(uint256 ageYears) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 70 * 25 / 1_000_000; // 0.70 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = ageYears;

        uint256[] memory distances = new uint256[](1);
        distances[0] = ageYears;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (ageYears > MAX_TABLE_AGE_YEARS) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexActuary-Adaptive";
    }
}
