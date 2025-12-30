// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexOrbit
/// @notice $1/decision application fee; 25 bp royalty on FFT anomaly.
///         Call `checkOrbit(...)` with anomaly score (0-1000); royalty splits if > 3σ.
contract LexOrbit is RoyaltySplitter {
    uint256 public constant USD_FEE_PER_DECISION = 1_000_000; // 1 USD = 1e6 µUSD
    uint256 public constant ANOMALY_THRESHOLD_PERMILLE = 3000; // 3.0 σ
    uint256 public constant MICROUSD_PER_ETH = 2_000_000_000_000; // 1 ETH = 2 000 µUSD (at $2 k/ETH)
    uint256 public constant GAS_BUFFER = 70_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param anomalyPermille  FFT-derived z-score × 1000 (3000 = 3.0 σ)
    /// @param decisions        Number of ITU filings being processed this call
    function checkOrbit(uint256 anomalyPermille, uint256 decisions) external payable {
        uint256 totalMicroUSD = decisions * USD_FEE_PER_DECISION;
        uint256 feeWei = (totalMicroUSD * 1e18) / MICROUSD_PER_ETH; // USD → wei
        require(msg.value >= feeWei, "LexOrbit: insufficient application fee");

        uint256 royaltyWei = (feeWei * 25) / 10_000; // 25 bp slice

        if (anomalyPermille > ANOMALY_THRESHOLD_PERMILLE) {
            _splitRoyalty{value: royaltyWei}();
        }

        // refund surplus (if any)
        uint256 surplus = msg.value - feeWei;
        if (surplus > 0) payable(msg.sender).transfer(surplus);
    }

    function vertical() external pure returns (string memory) {
        return "LexOrbit-ITU-FFT";
    }
}
