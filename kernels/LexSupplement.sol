pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexSupplement is RoyaltySplitter {
    uint256 public constant MAX_HEALTH_CLAIM_LEN = 200; // ≤ 200 chars
    uint256 public constant GAS_PER_CALL        = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSupplement(uint256 claimLen) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (claimLen > MAX_HEALTH_CLAIM_LEN) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexSupplement-Health"; }
}
