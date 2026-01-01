pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexReturn is RoyaltySplitter {
    uint256 public constant MAX_RETURN_DAYS = 30;
    uint256 public constant GAS_PER_CALL    = 65_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkReturn(uint256 daysSincePurchase) external payable {
        uint256 royaltyWei = (65_000 * block.basefee * 65 * 25) / 1_000_000;
        if (daysSincePurchase > MAX_RETURN_DAYS) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexReturn-Retail"; }
}
