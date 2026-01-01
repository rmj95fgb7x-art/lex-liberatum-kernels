pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexReEntry is RoyaltySplitter {
    uint256 public constant MAX_APOGEE_KM = 400; // ≤ 400 km apogee
    uint256 public constant GAS_PER_CALL  = 95_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkReEntry(uint256 apogeeKm) external payable {
        uint256 royaltyWei = (95_000 * block.basefee * 95 * 25) / 1_000_000;
        if (apogeeKm > MAX_APOGEE_KM) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexReEntry-Space"; }
}
