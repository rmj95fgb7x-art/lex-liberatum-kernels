pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexSanction is RoyaltySplitter {
    bool    public constant HIT_ALLOWED = false; // zero tolerance
    uint256 public constant GAS_PER_CALL= 85_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSanction(bool hitDetected) external payable {
        uint256 royaltyWei = (85_000 * block.basefee * 85 * 25) / 1_000_000;
        if (hitDetected == HIT_ALLOWED) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexSanction-Trade"; }
}
