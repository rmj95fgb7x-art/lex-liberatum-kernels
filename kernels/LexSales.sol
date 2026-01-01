// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexSales is RoyaltySplitter {
    uint256 public constant MAX_NEXUS_THRESHOLD_USD = 100_000;
    uint256 public constant GAS_PER_CALL            = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSales(uint256 nexusUSD) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (nexusUSD > MAX_NEXUS_THRESHOLD_USD) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexSales-Retail"; }
}
