// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexFood is RoyaltySplitter {
    uint256 public constant MIN_FONT_PT = 8;
    uint256 public constant GAS_PER_CALL= 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkFood(uint256 fontPt) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (fontPt < MIN_FONT_PT) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexFood-Health"; }
}
