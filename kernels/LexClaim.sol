pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexClaim is RoyaltySplitter {
    uint256 public constant MAX_FRAUD_PROB_PERMILLE = 100; // ≤ 10 % fraud probability
    uint256 public constant GAS_PER_CALL            = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkClaim(uint256 fraudProbPermille) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (fraudProbPermille > MAX_FRAUD_PROB_PERMILLE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexClaim-Insurance"; }
}
