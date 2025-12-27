// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IRoyaltySplitter {
    function recordDecision(bytes32 kernelId) external payable;
}

contract LexWingTest {
    IRoyaltySplitter public constant SPLITTER =
        IRoyaltySplitter(0x0000000000000000000000000000000000000000); // fill after step-3 deploy

    event DecideCalled(
        bytes32 indexed id,
        uint8 score,
        uint64 nanos,
        Decision decision,
        uint64 seq
    );

    enum Decision { Certified, Rejected }

    uint64 private _seq;

    function decide(
        bytes32 id,
        uint8 score,
        uint64 nanos
    ) external payable returns (Decision decision_, uint64 seq_) {
        // 25 bp royalty in wei: decision value * 25 / 10_000
        uint256 fee = (msg.value * 25) / 10_000;
        require(fee > 0, "Fee required");

        decision_ = score >= 80 ? Decision.Certified : Decision.Rejected;
        seq_ = ++_seq;

        SPLITTER.recordDecision{value: fee}(id);

        emit DecideCalled(id, score, nanos, decision_, seq_);
    }
}
