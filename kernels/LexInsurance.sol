// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexInsurance is RoyaltySplitter {
    uint256 public constant MAX_PREMIUM_DAYS_LATE = 30; // ≤ 30 days overdue
    uint256 public constant GAS_PER_CALL          = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkInsurance(uint256 daysLate) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (daysLate > MAX_PREMIUM_DAYS_LATE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexInsurance-Insurance"; }
}
