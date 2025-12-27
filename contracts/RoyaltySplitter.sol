// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title RoyaltySplitter
 * @dev Receives 25 bp per kernel decision and keeps a public counter.
 *      Test-net ready – no production funds at risk.
 */
contract RoyaltySplitter {
    address public constant TRUSTEE = 0x1234567890123456789012345678901234567890; // change to real trustee later
    uint256 public totalDecisions;
    uint256 public totalRoyaltyWei;

    event DecisionPaid(bytes32 indexed kernelId, uint256 feeWei);

    receive() external payable {
        // any kernel can send value; we just count it
        totalRoyaltyWei += msg.value;
    }

    function recordDecision(bytes32 _kernelId) external payable {
        require(msg.value > 0, "Royalty required");
        totalDecisions += 1;
        emit DecisionPaid(_kernelId, msg.value);
    }

    function decisionsToday() external view returns (uint256) {
        return totalDecisions;
    }
}
