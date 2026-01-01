pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexActuary is RoyaltySplitter {
    uint256 public constant MAX_TABLE_AGE_YEARS = 5; // ≤ 5 years old
    uint256 public constant GAS_PER_CALL        = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkActuary(uint256 ageYears) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (ageYears > MAX_TABLE_AGE_YEARS) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexActuary-Insurance"; }
}
