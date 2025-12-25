// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;

interface ISplitter {
    function drip() external payable;
}

contract LexTrackAdapter {
    ISplitter public constant SPLITTER =
        ISplitter(0x4C6f786C6962657274756D5472757374); // same trust splitter

    event Tracked(
        bytes12 indexed isrc,
        bytes32 indexed csvHash,
        bool accepted,
        bytes32 certHash
    );

    uint256 private constant ROYALTY_BPS = 25;

    function fileStatement(bytes12 isrc, bytes calldata csvBlob)
        external
        payable
        returns (bool accepted, bytes32 certHash)
    {
        uint256 royalty = (msg.value * ROYALTY_BPS) / 10_000;
        if (royalty > 0) SPLITTER.drip{value: royalty}();

        bytes32 csvHash = keccak256(csvBlob);
        accepted = bytes4(csvBlob) == "ISRC" && csvBlob.length < 4096;
        certHash = keccak256(
            abi.encodePacked(isrc, csvHash, block.timestamp, accepted)
        );

        emit Tracked(isrc, csvHash, accepted, certHash);
    }
}
