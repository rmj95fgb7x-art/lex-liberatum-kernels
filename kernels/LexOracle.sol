pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexOracle is RoyaltySplitter {
    uint256 public constant MAX_DEVIATION_PERMILLE = 10; // 1 %
    uint256 public constant GAS_PER_CALL = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkOracle(uint256 deviationPermille) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (deviationPermille > MAX_DEVIATION_PERMILLE) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexOracle-DeFi"; }
}
