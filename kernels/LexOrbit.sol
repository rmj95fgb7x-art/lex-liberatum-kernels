// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexOrbit
/// @notice Pure compliance kernel: returns FFT anomaly permille.
///         Pricing lives in RoyaltySplitter.
contract LexOrbit is RoyaltySplitter {
    uint256 public constant ANOMALY_THRESHOLD_PERMILLE = 3000; // 3.0 σ

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param anomalyPermille  FFT-derived z-score × 1000 (3000 = 3.0 σ)
    /// @return anom  Anomaly flag (true if > threshold)
    function checkOrbit(uint256 anomalyPermille) external view returns (bool anom) {
        anom = anomalyPermille > ANOMALY_THRESHOLD_PERMILLE;
    }

    function vertical() external pure returns (string memory) {
        return "LexOrbit-ITU";
    }
}
