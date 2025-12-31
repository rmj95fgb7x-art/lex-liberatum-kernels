pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexWarranty is RoyaltySplitter {
    uint256 public constant MAX_AGE_MONTHS = 36;
    uint256 public constant GAS_PER_CALL   = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkWarranty(uint256 ageMonths) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (ageMonths > MAX_AGE_MONTHS) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexWarranty-Retail"; }
}
