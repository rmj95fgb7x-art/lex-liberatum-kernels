pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexElection is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 110_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param custodyGapSec       Seconds between custody hand-offs
    /// @param signatureMatchPermille Signature match score (0–1000)
    /// @param timestampDriftSec   Clock drift from official time
    /// @param precinctMatch       True if ballot precinct == scanning precinct
    function checkElection(
        uint256 custodyGapSec,
        uint256 signatureMatchPermille,
        uint256 timestampDriftSec,
        bool precinctMatch
    ) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 110 * 25) / 1_000_000; // 1.10 multiplier

        uint256[] memory signals = new uint256[](4);
        signals[0] = custodyGapSec;
        signals[1] = signatureMatchPermille;
        signals[2] = timestampDriftSec;
        signals[3] = precinctMatch ? 1 : 0;

        uint256[] memory distances = new uint256[](4);
        uint256[] memory sorted = new uint256[](4);
        for (uint256 i = 0; i < 4; i++) sorted[i] = signals[i];
        // median of 4 → average of middle 2
        uint256 median = (sorted[1] + sorted[2]) / 2;
        for (uint256 i = 0; i < 4; i++) {
            int256 diff = int256(signals[i]) - int256(median);
            distances[i] = diff < 0 ? uint256(-diff) : uint256(diff);
        }

        uint256[] memory weights = adaptiveWeights(distances);
        uint256 sum = 0;
        for (uint256 i = 0; i < 4; i++) {
            sum += signals[i] * weights[i];
        }
        fused = sum / 10000;

        bool compliant = (custodyGapSec <= 300) &&
            (signatureMatchPermille >= 850) &&
            (timestampDriftSec <= 60) &&
            (precinctMatch);
        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexElection-Adaptive";
    }
}
