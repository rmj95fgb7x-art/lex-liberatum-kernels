pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexICD10 is RoyaltySplitter {
    uint256 public constant VALID_LENGTH = 3;
    uint256 public constant GAS_PER_CALL = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkICD10(bytes3 code) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        bool ok = code.length == VALID_LENGTH;
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexICD10-Healthcare"; }
}
