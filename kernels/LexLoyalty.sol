pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexLoyalty is RoyaltySplitter {
    uint256 public constant MAX_EXPIRY_DAYS = 365;
    uint256 public constant GAS_PER_CALL    = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkLoyalty(uint256 expiryDays) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (expiryDays > MAX_EXPIRY_DAYS) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexLoyalty-Retail"; }
}
