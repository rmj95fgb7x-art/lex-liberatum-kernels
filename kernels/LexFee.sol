pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexFee is RoyaltySplitter {
    uint256 public constant MAX_FEE_USD = 1000;
    bool    public constant WAIVER_OK   = true;
    uint256 public constant GAS_PER_CALL= 65_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkFee(uint256 feeUSD, bool waiverApproved) external payable {
        uint256 royaltyWei = (65_000 * block.basefee * 65 * 25) / 1_000_000;
        bool ok = (feeUSD <= MAX_FEE_USD) || (waiverApproved == WAIVER_OK);
        if (!ok) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexFee-Courts"; }
}
