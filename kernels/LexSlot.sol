pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexSlot is RoyaltySplitter {
    uint256 public constant MAX_DRIFT_KM = 0.1; // ≤ 0.1 km longitude drift
    uint256 public constant GAS_PER_CALL = 90_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkSlot(uint256 driftKm) external payable {
        uint256 royaltyWei = (90_000 * block.basefee * 90 * 25) / 1_000_000;
        if (driftKm > MAX_DRIFT_KM) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexSlot-Space"; }
}
