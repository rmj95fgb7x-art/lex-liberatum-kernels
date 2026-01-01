pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexReinsure is RoyaltySplitter {
    uint256 public constant MAX_COVER_PERCENT = 100; // ≤ 100 % of sum insured
    uint256 public constant GAS_PER_CALL      = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkReinsure(uint256 coverPercent) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (coverPercent > MAX_COVER_PERCENT) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexReinsure-Insurance"; }
}
