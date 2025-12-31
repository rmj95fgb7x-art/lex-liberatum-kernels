pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexService is RoyaltySplitter {
    uint256 public constant MAX_AGE_HOURS = 24;
    bool    public constant CERT_REQUIRED = true;
    uint256 public constant GAS_PER_CALL  = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkService(uint256 ageHours, bool certPresent) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        bool ok = ageHours <= MAX_AGE_HOURS && certPresent == CERT_REQUIRED;
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexService-Courts"; }
}
