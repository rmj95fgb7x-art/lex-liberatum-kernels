// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexQoS
/// @notice 25 bp royalty on telecom QoS compliance:
///         packet-loss, jitter, latency, uptime SLA.
contract LexQoS is RoyaltySplitter {
    // ITU-T G.826 / E.855 example thresholds
    uint256 public constant MAX_PACKET_LOSS_permille = 10;   // ≤ 1.0 %
    uint256 public constant MAX_JITTER_MS            = 50;   // ≤ 50 ms
    uint256 public constant MAX_LATENCY_MS           = 150;  // ≤ 150 ms one-way
    uint256 public constant MIN_UPTIME_permille      = 995;  // ≥ 99.5 % monthly
    uint256 public constant GAS_PER_CALL             = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param packetLossPermille Packet loss (0–1000)
    /// @param jitterMs           Jitter (ms)
    /// @param latencyMs          One-way latency (ms)
    /// @param uptimePermille     Monthly uptime (0–1000)
    function checkQoS(uint256 packetLossPermille, uint256 jitterMs, uint256 latencyMs, uint256 uptimePermille) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        bool compliant = (packetLossPermille <= MAX_PACKET_LOSS_permille) &&
                         (jitterMs <= MAX_JITTER_MS) &&
                         (latencyMs <= MAX_LATENCY_MS) &&
                         (uptimePermille >= MIN_UPTIME_permille);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexQoS-Telecom";
    }
}
