pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexSARTele is RoyaltySplitter {
    uint256 public constant MAX_SAR_W_PER_KG = 2; // ≤ 2 W/kg head SAR
    uint256 public constant GAS_PER_CALL     = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSARTele(uint256 sarHeadWkg) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (sarHeadWkg > MAX_SAR_W_PER_KG) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexSAR-Telecom"; }
}
