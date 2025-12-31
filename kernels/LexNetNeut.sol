pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexNetNeut is RoyaltySplitter {
    uint256 public constant MAX_ZERO_RATING_GB = 0; // zero-rating not allowed
    uint256 public constant MIN_SPEED_MBPS     = 25; // ≥ 25 Mbps
    uint256 public constant GAS_PER_CALL       = 85_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkNetNeut(uint256 zeroRatingGB, uint256 speedMbps) external payable {
        uint256 royaltyWei = (85_000 * block.basefee * 85 * 25) / 1_000_000;
        bool ok = (zeroRatingGB <= MAX_ZERO_RATING_GB) && (speedMbps >= MIN_SPEED_MBPS);
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexNetNeut-Telecom"; }
}
