// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexDebris is RoyaltySplitter {
    uint256 public constant MAX_PROB_PERMILLE = 1; // ≤ 0.1 % collision probability
    uint256 public constant GAS_PER_CALL      = 110_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkDebris(uint256 probPermille) external payable {
        uint256 royaltyWei = (110_000 * block.basefee * 110 * 25) / 1_000_000;
        if (probPermille > MAX_PROB_PERMILLE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexDebris-Space"; }
}
