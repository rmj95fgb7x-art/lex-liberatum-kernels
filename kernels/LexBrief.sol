// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexBrief is RoyaltySplitter {
    uint256 public constant MAX_PAGE_COUNT   = 50;
    uint256 public constant MIN_FONT_SIZE_PT = 12;
    uint256 public constant GAS_PER_CALL     = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkBrief(uint256 pageCount, uint256 fontSizePt) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        bool ok = pageCount <= MAX_PAGE_COUNT && fontSizePt >= MIN_FONT_SIZE_PT;
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexBrief-Courts"; }
}
