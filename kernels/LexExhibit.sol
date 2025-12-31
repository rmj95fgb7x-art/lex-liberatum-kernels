pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexExhibit is RoyaltySplitter {
    uint256 public constant MAX_EXHIBITS = 99;
    bool    public constant STAMP_REQUIRED = true;
    uint256 public constant GAS_PER_CALL  = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkExhibit(uint256 exhibitCount, bool stampPresent) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        bool ok = exhibitCount <= MAX_EXHIBITS && stampPresent == STAMP_REQUIRED;
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexExhibit-Courts"; }
}
