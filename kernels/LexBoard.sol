pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexBoard is RoyaltySplitter {
    uint256 public constant MAX_DAYS_SINCE_MINUTES = 60; // ≤ 60 days to approve minutes
    uint256 public constant GAS_PER_CALL           = 65_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkBoard(uint256 daysSinceMinutes) external payable {
        uint256 royaltyWei = (65_000 * block.basefee * 65 * 25) / 1_000_000;
        if (daysSinceMinutes > MAX_DAYS_SINCE_MINUTES) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexBoard-Corporate"; }
}
