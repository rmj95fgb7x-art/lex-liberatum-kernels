pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexMedical is RoyaltySplitter {
    uint256 public constant VALID_UDI_LENGTH = 14; // 14-character UDI
    uint256 public constant GAS_PER_CALL     = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkMedical(bytes14 udi) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        bool ok = udi.length == VALID_UDI_LENGTH;
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexMedical-Health"; }
}
