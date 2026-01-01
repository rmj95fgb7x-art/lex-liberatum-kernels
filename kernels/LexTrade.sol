pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexTrade is RoyaltySplitter {
    uint256 public constant MAX_QUOTA_PERCENT = 100; // ≤ 100 % quota used
    uint256 public constant GAS_PER_CALL      = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkTrade(uint256 quotaPercent) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (quotaPercent > MAX_QUOTA_PERCENT) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexTrade-Trade"; }
}
