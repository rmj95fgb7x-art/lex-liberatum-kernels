pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexDiscount is RoyaltySplitter {
    uint256 public constant MAX_USE_COUNT = 1;
    uint256 public constant GAS_PER_CALL  = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkDiscount(uint256 useCount) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (useCount > MAX_USE_COUNT) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexDiscount-Retail"; }
}
