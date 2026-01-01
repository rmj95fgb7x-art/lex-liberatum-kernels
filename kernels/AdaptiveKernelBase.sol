// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

/// @title AdaptiveKernelBase
/// @notice Shared adaptive-fusion helper: computes Gaussian weights from distances
contract AdaptiveKernelBase {
    uint256 public constant ALPHA = 150; // α × 100 (1.50)
    uint256 public constant SCALE = 100; // fixed-point scale

    /// @param distances  Array of L2 distances (scaled ×100)
    /// @return weights   Array of Gaussian weights (scaled ×10000, sum = 10000)
    function adaptiveWeights(uint256[] memory distances) internal pure returns (uint256[] memory) {
        uint256 n = distances.length;
        uint256[] memory weights = new uint256[](n);
        uint256 sum = 0;

        // compute exp(-d²/(2α²)) for each distance
        for (uint256 i = 0; i < n; i++) {
            uint256 d2 = (distances[i] * distances[i]) / SCALE; // d²
            uint256 exponent = d2 * SCALE / (2 * ALPHA * ALPHA); // d²/(2α²)
            // exp(-x) ≈ (10000 * (SCALE - exponent)) / SCALE  (linear approx for small x)
            weights[i] = (SCALE * SCALE - exponent * SCALE) / SCALE;
            sum += weights[i];
        }

        // normalize to 10000
        if (sum == 0) sum = 1; // avoid div/0
        for (uint256 i = 0; i < n; i++) {
            weights[i] = (weights[i] * 10000) / sum;
        }
        return weights;
    }
}
