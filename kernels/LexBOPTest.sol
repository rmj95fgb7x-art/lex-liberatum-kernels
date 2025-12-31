pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexBOPTest is RoyaltySplitter {
    uint256 public constant MIN_HOLD_MIN = 5;
    uint256 public constant GAS_PER_CALL = 105_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkBOPTest(uint256 holdMinutes) external payable {
        uint256 royaltyWei = (105_000 * block.basefee * 105 * 25) / 1_000_000;
        if (holdMinutes < MIN_HOLD_MIN) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexBOPTest-Energy"; }
}
