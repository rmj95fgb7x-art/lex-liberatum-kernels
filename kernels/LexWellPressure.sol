// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexWellPressure is RoyaltySplitter {
    uint256 public constant MAX_PRESSURE_PSI = 20000;
    uint256 public constant GAS_PER_CALL     = 85_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkWellPressure(uint256 pressurePsi) external payable {
        uint256 royaltyWei = (85_000 * block.basefee * 85 * 25) / 1_000_000;
        if (pressurePsi > MAX_PRESSURE_PSI) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexWellPressure-Energy"; }
}
