pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexBOPTest is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MIN_HOLD_MIN = 5; // ≥ 5 min hold
    uint256 public constant GAS_PER_CALL = 105_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param holdMinutes    Hold time at test pressure (minutes)
    function checkBOPTest(uint256 holdMinutes) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 105 * 25 / 1_000_000; // 1.05 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = holdMinutes;

        uint256[] memory distances = new uint256[](1);
        distances[0] = holdMinutes;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (holdMinutes < MIN_HOLD_MIN) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexBOPTest-Adaptive";
    }
}
