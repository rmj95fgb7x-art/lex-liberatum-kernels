pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexExport is RoyaltySplitter {
    uint256 public constant MAX_EXPIRY_DAYS = 30; // ≤ 30 days to licence expiry
    uint256 public constant GAS_PER_CALL    = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkExport(uint256 expiryDays) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (expiryDays > MAX_EXPIRY_DAYS) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexExport-Trade"; }
}
