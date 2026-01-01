pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexDrug is RoyaltySplitter {
    uint256 public constant MAX_AD CLAIM_LEN = 150; // ≤ 150 chars
    uint256 public constant GAS_PER_CALL     = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkDrug(uint256 adLen) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (adLen > MAX_AD_CLAIM_LEN) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexDrug-Health"; }
}
