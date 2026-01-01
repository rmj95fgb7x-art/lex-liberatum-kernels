pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexEmbargo is RoyaltySplitter {
    uint256 public constant MAX_EMBARGO_DAYS = 0; // zero days allowed
    uint256 public constant GAS_PER_CALL     = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkEmbargo(uint256 embargoDays) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (embargoDays > MAX_EMBARGO_DAYS) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexEmbargo-Trade"; }
}
