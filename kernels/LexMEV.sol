pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexMEV is RoyaltySplitter {
    uint256 public constant MAX_PROFIT_PERMILLE = 5; // 0.5 % block profit
    uint256 public constant GAS_PER_CALL = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkMEV(uint256 profitPermille) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (profitPermille > MAX_PROFIT_PERMILLE) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexMEV-DeFi"; }
}
