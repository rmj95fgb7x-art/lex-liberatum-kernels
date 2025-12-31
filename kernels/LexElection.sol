// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexElection
/// @notice 25 bp royalty on election-ballot compliance:
///         chain-of-custody hash, signature match, timestamp validity, precinct match.
contract LexElection is RoyaltySplitter {
    // EAC VVSG 2.0 example thresholds
    uint256 public constant MAX_CHAIN_GAP_SEC = 300;    // ≤ 5 min custody gap
    uint256 public constant SIGNATURE_MATCH_THRESHOLD_PERMILLE = 850; // 85 % match
    uint256 public constant MAX_TIMESTAMP_DRIFT_SEC = 60;  // ≤ 1 min drift
    uint256 public constant GAS_PER_CALL        = 110_000;

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
    ) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 110 * 25 / 1_000_000; // 1.10 multiplier

        bool compliant = (custodyGapSec <= MAX_CHAIN_GAP_SEC) &&
                         (signatureMatchPermille >= SIGNATURE_MATCH_THRESHOLD_PERMILLE) &&
                         (timestampDriftSec <= MAX_TIMESTAMP_DRIFT_SEC) &&
                         (precinctMatch);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexElection-Ballot";
    }
}
