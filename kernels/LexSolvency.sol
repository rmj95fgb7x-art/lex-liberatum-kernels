pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexSolvency is RoyaltySplitter {
    uint256 public constant MIN_SOLVENCY_RATIO_PERMILLE = 150; // ≥ 150 % assets / liabilities
    uint256 public constant GAS_PER_CALL                = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSolvency(uint256 ratioPermille) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (ratioPermille < MIN_SOLVENCY_RATIO_PERMILLE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexSolvency-Insurance"; }
}
