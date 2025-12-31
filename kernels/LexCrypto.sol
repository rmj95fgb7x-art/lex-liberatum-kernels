// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexCrypto
/// @notice 25 bp royalty on DeFi oracle-deviation compliance:
///         price feed delta, heartbeat staleness, sequencer uptime.
contract LexCrypto is RoyaltySplitter {
    // Example thresholds (Chainlink-like)
    uint256 public constant MAX_DEVIATION_PERMILLE = 50;   // 5 % price drift
    uint256 public constant MAX_STALENESS_SEC        = 120; // 2 min heartbeat
    uint256 public constant MIN_UPTIME_PERCENT       = 990; // 99 % sequencer uptime
    uint256 public constant GAS_PER_CALL             = 75_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param priceDeltaPermille  Absolute price delta from oracle (permille)
    /// @param secondsSinceUpdate  Seconds since last oracle update
    /// @param sequencerUptimePermille Sequencer uptime over window (0–1000)
    function checkCrypto(
        uint256 priceDeltaPermille,
        uint256 secondsSinceUpdate,
        uint256 sequencerUptimePermille
    ) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 75 * 25 / 1_000_000; // 0.75 multiplier

        bool compliant = (priceDeltaPermille <= MAX_DEVIATION_PERMILLE) &&
                         (secondsSinceUpdate <= MAX_STALENESS_SEC) &&
                         (sequencerUptimePermille >= MIN_UPTIME_PERCENT);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexCrypto-Oracle";
    }
}
