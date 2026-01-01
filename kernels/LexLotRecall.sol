pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexLotRecall is RoyaltySplitter {
    bool    public constant RECALL_ACTIVE = false; // must NOT be under recall
    uint256 public constant MAX_AGE_DAYS  = 30;    // ≤ 30 days to expiry
    uint256 public constant GAS_PER_CALL  = 85_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkLotRecall(bool recalled, uint256 ageDays) external payable {
        uint256 royaltyWei = (85_000 * block.basefee * 85 * 25) / 1_000_000;
        bool ok = (!recalled) && (ageDays <= MAX_AGE_DAYS);
        if (!ok) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexLotRecall-Healthcare"; }
}
