pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexColdChain is RoyaltySplitter {
    uint256 public constant MAX_TEMP_DEVIATION_C = 2; // ±2 °C
    uint256 public constant MAX_OUT_TIME_MIN     = 30;
    uint256 public constant GAS_PER_CALL         = 90_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkColdChain(uint256 deviationC, uint256 outMin) external payable {
        uint256 royaltyWei = (90_000 * block.basefee * 90 * 25) / 1_000_000;
        bool ok = (deviationC <= MAX_TEMP_DEVIATION_C) && (outMin <= MAX_OUT_TIME_MIN);
        if (!ok) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexColdChain-Healthcare"; }
}
