pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexPortTel is RoyaltySplitter {
    uint256 public constant MAX_PORT_HOURS = 24; // ≤ 24 h port-out
    uint256 public constant GAS_PER_CALL   = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkPortTel(uint256 portHours) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (portHours > MAX_PORT_HOURS) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexPortTel-Telecom"; }
}
