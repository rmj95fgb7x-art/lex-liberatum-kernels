// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

/// @title FlagshipAdaptiveBase
/// @notice Shared adaptive-fusion helper for the flagship 25 kernels
contract FlagshipAdaptiveBase {
    uint256 public constant ALPHA = 150;   // α × 100 (1.50)
    uint256 public constant SCALE = 100;   // fixed-point scale

    /// @param distances  Array of L2 distances (scaled ×100)
    /// @return weights   Array of Gaussian weights (scaled ×10000, sum = 10000)
    function adaptiveWeights(uint256[] memory distances) internal pure returns (uint256[] memory) {
        uint256 n = distances.length;
        uint256[] memory weights = new uint256[](n);
        uint256 sum = 0;

        // exp(-d²/(2α²)) linear approx for small x
        for (uint256 i = 0; i < n; i++) {
            uint256 d2 = (distances[i] * distances[i]) / SCALE;
            uint256 exponent = d2 * SCALE / (2 * ALPHA * ALPHA);
            weights[i] = (SCALE * SCALE - exponent * SCALE) / SCALE;
            sum += weights[i];
        }

        if (sum == 0) sum = 1;
        for (uint256 i = 0; i < n; i++) {
            weights[i] = (weights[i] * 10000) / sum;
        }
        return weights;
    }
}
