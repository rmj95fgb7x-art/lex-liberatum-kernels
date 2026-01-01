pragma solidity ^0.8.25;
import "../src/AdaptiveKernelBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexJurisdiction is RoyaltySplitter, AdaptiveKernelBase {
    uint256 public constant MIN_CONTACTS_COUNT = 1;    // ≥ 1 contact
    uint256 public constant MAX_VENUE_MISMATCH_KM = 50; // ≤ 50 km venue error
    uint256 public constant GAS_PER_CALL        = 75_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param contactsCount     Number of established minimum contacts
    /// @param venueMismatchKm   Kilometres between proper and chosen venue
    /// @param subjectMatterOk   True if court has subject-matter jurisdiction
    function checkJurisdiction(uint256 contactsCount, uint256 venueMismatchKm, bool subjectMatterOk) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 75 * 25 / 1_000_000; // 0.75 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = contactsCount;
        signals[1] = venueMismatchKm;
        signals[2] = subjectMatterOk ? 1 : 0;

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

        bool compliant = (contactsCount >= MIN_CONTACTS_COUNT) &&
                         (venueMismatchKm <= MAX_VENUE_MISMATCH_KM) &&
                         (subjectMatterOk);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexJurisdiction-Adaptive";
    }
}
