pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexDerm is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 95_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param ingredientHash  Keccak-256 of primary INCI name
    /// @param claimLength     Length of cosmetic claim text
    /// @param hasAllergens    True if contains known allergens
    function checkDerm(bytes32 ingredientHash, uint256 claimLength, bool hasAllergens) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 95 * 25 / 1_000_000; // 0.95 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = uint256(ingredientHash);
        signals[1] = claimLength;
        signals[2] = hasAllergens ? 1 : 0;

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

        bool compliant = (ingredientHash != keccak256("Hydroquinone")) &&
                         (ingredientHash != keccak256("Mercury")) &&
                         (claimLength <= 200) &&
                         (hasAllergens == true); // must declare allergens
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexDerm-Adaptive";
    }
}
