pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexSpill is RoyaltySplitter {
    uint256 public constant MAX_SPILL_LITRES = 100;
    uint256 public constant GAS_PER_CALL     = 90_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSpill(uint256 spillLitres) external payable {
        uint256 royaltyWei = (90_000 * block.basefee * 90 * 25) / 1_000_000;
        if (spillLitres > MAX_SPILL_LITRES) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexSpill-Energy"; }
}
