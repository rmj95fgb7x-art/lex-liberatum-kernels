// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexNonce is RoyaltySplitter {
    uint256 public constant MAX_GAP = 1;
    uint256 public constant GAS_PER_CALL = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkNonce(uint256 gap) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (gap > MAX_GAP) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexNonce-DeFi"; }
}
