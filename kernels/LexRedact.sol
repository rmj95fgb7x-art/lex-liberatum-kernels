pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexRedact is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MAX_SSN_COUNT = 0; // zero SSNs visible
    uint256 public constant MAX_DOB_COUNT = 0; // zero DOBs visible
    uint256 public constant MIN_REDACT_PERCENT = 95; // ≥ 95 % coverage
    uint256 public constant GAS_PER_CALL = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ssnCount        Number of visible SSNs
    /// @param dobCount        Number of visible dates of birth
    /// @param redactPercent   Automated redaction coverage (0-100)
    function checkRedact(
        uint256 ssnCount,
        uint256 dobCount,
        uint256 redactPercent
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 85 * 25) / 1_000_000; // 0.85 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = ssnCount;
        signals[1] = dobCount;
        signals[2] = redactPercent;

        uint256[] memory distances = new uint256[](3);
        uint256[] memory sorted = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) sorted[i] = signals[i];
        uint256 median = sorted[1];
        for (uint256 i = 0; i < 3; i++) {
            int256 diff = int256(signals[i]) - int256(median);
            distances[i] = diff < 0 ? uint256(-diff) : uint256(diff);
        }

        uint256[] memory weights = adaptiveWeights(distances);
        uint256 sum = 0;
        for (uint256 i = 0; i < 3; i++) {
            sum += signals[i] * weights[i];
        }
        fused = sum / 10000;

        bool compliant = (ssnCount <= MAX_SSN_COUNT) &&
            (dobCount <= MAX_DOB_COUNT) &&
            (redactPercent >= MIN_REDACT_PERCENT);
        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexRedact-Adaptive";
    }
}
