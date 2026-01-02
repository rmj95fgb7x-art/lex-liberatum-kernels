pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexSeal is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant MIN_SEAL_SIZE_PX     = 100;   // ≥ 100 px width
    uint256 public constant MAX_CERT_DAYS        = 30;    // cert valid ≥ 30 days
    uint256 public constant GAS_PER_CALL         = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param sealPresent     True if visible seal uploaded
    /// @param sigValid        True if digital signature verifies
    /// @param certDaysLeft    Days until signer certificate expiry
    function checkSeal(bool sealPresent, bool sigValid, uint256 certDaysLeft) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = sealPresent ? 1 : 0;
        signals[1] = sigValid ? 1 : 0;
        signals[2] = certDaysLeft;

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

        bool compliant = (sealPresent) &&
                         (sigValid) &&
                         (certDaysLeft >= MAX_CERT_DAYS);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexSeal-Adaptive";
    }
}
