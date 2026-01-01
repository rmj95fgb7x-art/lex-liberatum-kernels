pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexChart is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 120_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param icd10      Patient primary ICD-10 code (3-byte prefix)
    /// @param dosageMg   Daily dosage in milligrams
    /// @param costUSD    Estimated drug cost per month (USD)
    function checkChart(
        bytes3 icd10,
        uint256 dosageMg,
        uint256 costUSD
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 120 * 25) / 1_000_000; // 1.20 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = uint256(icd10);
        signals[1] = dosageMg;
        signals[2] = costUSD;

        uint256[] memory distances = new uint256[](3);
        uint256[] memory sorted = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) sorted[i] = signals[i];
        uint256 median = sorted[1]; // length = 3 → median at index 1
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

        bool requiresAuth = (costUSD > 1000) || _isHighCostICD(icd10);
        if (requiresAuth) {
            _splitRoyalty(royaltyWei);
        }
    }

    function _isHighCostICD(bytes3 icd10) internal pure returns (bool) {
        // example high-cost prefixes
        return
            (icd10 == bytes3("L40")) ||
            (icd10 == bytes3("M05")) ||
            (icd10 == bytes3("K50")) ||
            (icd10 == bytes3("C92"));
    }

    function vertical() external pure returns (string memory) {
        return "LexChart-Adaptive";
    }
}
