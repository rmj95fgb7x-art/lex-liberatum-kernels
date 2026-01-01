pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexSlippage is RoyaltySplitter {
    uint256 public constant MAX_SLIPPAGE_PERMILLE = 50; // 5 %
    uint256 public constant GAS_PER_CALL = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSlippage(uint256 slippagePermille) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (slippagePermille > MAX_SLIPPAGE_PERMILLE) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexSlippage-DeFi"; }
}
