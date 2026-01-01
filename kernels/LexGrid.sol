// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexGrid
/// @notice 25 bp royalty on grid-frequency deviation from 60 Hz.
///         Call `checkFrequency(...)` with mHz reading; royalty splits if deviation > 100 mHz.
contract LexGrid is RoyaltySplitter {
    uint256 public constant NOMINAL_HZ = 60;
    uint256 public constant DEV_THRESHOLD_MHZ = 100; // ±100 mHz
    uint256 public constant GAS_PER_CALL = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param freqmHz  Real-time frequency in milli-Hertz (e.g., 60000 = 60 Hz)
    function checkFrequency(uint256 freqmHz) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = (gasUsed * baseFee * 110 * 25) / 1_000_000; // 1.10 multiplier

        uint256 deviation = freqmHz > NOMINAL_HZ * 1000
            ? freqmHz - NOMINAL_HZ * 1000
            : NOMINAL_HZ * 1000 - freqmHz;

        if (deviation > DEV_THRESHOLD_MHZ) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexGrid-Frequency";
    }
}
