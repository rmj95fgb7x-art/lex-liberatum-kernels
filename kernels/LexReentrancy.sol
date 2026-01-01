pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexReentrancy is RoyaltySplitter {
    bool public constant REENTRANCY_ALLOWED = false;
    uint256 public constant GAS_PER_CALL = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkReentrancy(bool reentrancyDetected) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (reentrancyDetected == REENTRANCY_ALLOWED) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexReentrancy-DeFi"; }
}
