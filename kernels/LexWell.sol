pragma solidity ^0.8.25;
<<<<<<< HEAD

import "src/RoyaltySplitter.sol";
=======
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";
>>>>>>> main

contract LexWell is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param pressurePsi  Current well pressure (psi)
    /// @param h2sPpm       H₂S concentration (ppm)
    /// @param flareEff     Flare destruction efficiency (%)
    function checkWell(uint256 pressurePsi, uint256 h2sPpm, uint256 flareEff) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 115 * 25 / 1_000_000; // 1.15 multiplier

        uint256[] memory signals = new uint256[](3);
        signals[0] = pressurePsi;
        signals[1] = h2sPpm;
        signals[2] = flareEff;

<<<<<<< HEAD
        if (anomaly) {
            _splitRoyalty(royaltyWei);
=======
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

        bool compliant = (pressurePsi <= 15000) &&
                         (h2sPpm <= 10) &&
                         (flareEff >= 98);
        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
>>>>>>> main
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexWell-Adaptive";
    }
}
