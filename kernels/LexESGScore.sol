pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexESGScore is RoyaltySplitter {
    uint256 public constant MIN_SCORE_PERMILLE = 700; // ≥ 70 % ESG score
    uint256 public constant GAS_PER_CALL       = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkESGScore(uint256 scorePermille) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (scorePermille < MIN_SCORE_PERMILLE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexESGScore-Corporate"; }
}
