pragma solidity ^0.8.25;
<<<<<<< HEAD
import "src/RoyaltySplitter.sol";
contract LexBrief is RoyaltySplitter {
=======
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexBrief is RoyaltySplitter, AdaptiveKernelBase {
>>>>>>> main
    uint256 public constant MAX_PAGE_COUNT   = 50;
    uint256 public constant MIN_FONT_SIZE_PT = 12;
    uint256 public constant GAS_PER_CALL     = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
<<<<<<< HEAD
    function checkBrief(uint256 pageCount, uint256 fontSizePt) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        bool ok = pageCount <= MAX_PAGE_COUNT && fontSizePt >= MIN_FONT_SIZE_PT;
        if (!ok) _splitRoyalty(royaltyWei);
=======

    /// @param pageCount   Total PDF page count
    /// @param fontSizePt  Minimum font size used (points)
    function checkBrief(uint256 pageCount, uint256 fontSizePt) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        uint256[] memory signals = new uint256[](2);
        signals[0] = pageCount;
        signals[1] = fontSizePt;

        uint256[] memory distances = new uint256[](2);
        uint256[] memory sorted = new uint256[](2);
        for (uint256 i = 0; i < 2; i++) sorted[i] = signals[i];
        uint256 median = sorted[0] + (sorted[1] - sorted[0]) / 2; // length=2 → median = avg
        for (uint256 i = 0; i < 2; i++) {
            int256 diff = int256(signals[i]) - int256(median);
            distances[i] = diff < 0 ? uint256(-diff) : uint256(diff);
        }

        uint256[] memory weights = adaptiveWeights(distances);
        uint256 sum = 0;
        for (uint256 i = 0; i < 2; i++) {
            sum += signals[i] * weights[i];
        }
        fused = sum / 10000;

        bool compliant = (pageCount <= MAX_PAGE_COUNT) &&
                         (fontSizePt >= MIN_FONT_SIZE_PT);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexBrief-Adaptive";
>>>>>>> main
    }
}
