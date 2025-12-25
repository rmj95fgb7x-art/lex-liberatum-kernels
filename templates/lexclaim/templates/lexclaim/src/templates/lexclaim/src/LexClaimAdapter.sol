// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;

interface ISplitter {
    function drip() external payable;
}

contract LexClaimAdapter {
    ISplitter public constant SPLITTER =
        ISplitter(0x4C6f786C6962657274756D5472757374); // same trust splitter

    event Claimed(
        bytes32 indexed policyHash,
        bytes32 indexed claimHash,
        uint8 decision, // 0=Approved,1=Rejected,2=Flagged
        bytes32 certHash
    );

    uint256 private constant ROYALTY_BPS = 25;

    function fileClaim(
        bytes32 policyHash,
        bytes32 claimHash,
        bytes32[] calldata evidenceHashes,
        uint64 claimedUsd
    ) external payable returns (uint8 decision, bytes32 certHash) {
        uint256 royalty = (msg.value * ROYALTY_BPS) / 10_000;
        if (royalty > 0) SPLITTER.drip{value: royalty}();

        // inline kernel rules
        if (claimedUsd == 0) decision = 1;
        else if (claimedUsd > 50_000_00) decision = 2;
        else if (evidenceHashes.length < 2) decision = 2;
        else decision = 0;

        certHash = keccak256(
            abi.encodePacked(policyHash, claimHash, block.timestamp, uint8(decision))
        );

        emit Claimed(policyHash, claimHash, uint8(decision), certHash);
    }
}
