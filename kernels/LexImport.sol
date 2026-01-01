// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexImport is RoyaltySplitter {
    uint256 public constant MAX_TARIFF_RATE_PERMILLE = 250; // ≤ 25 %
    uint256 public constant GAS_PER_CALL             = 80_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkImport(uint256 ratePermille) external payable {
        uint256 royaltyWei = (80_000 * block.basefee * 80 * 25) / 1_000_000;
        if (ratePermille > MAX_TARIFF_RATE_PERMILLE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexImport-Trade"; }
}
