pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexInsurance is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant MAX_PREMIUM_DAYS_LATE = 30; // ≤ 30 days overdue
    uint256 public constant GAS_PER_CALL          = 75_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param daysLate  Days since premium due date
    function checkInsurance(uint256 daysLate) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 75 * 25 / 1_000_000; // 0.75 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = daysLate;

        uint256[] memory distances = new uint256[](1);
        distances[0] = daysLate;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (daysLate > MAX_PREMIUM_DAYS_LATE) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexInsurance-Adaptive";
    }
}
