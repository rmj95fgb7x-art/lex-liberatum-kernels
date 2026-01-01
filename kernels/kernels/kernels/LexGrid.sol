pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexGrid is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param freqmHz  Real-time frequency in milli-Hertz (e.g., 60000 = 60 Hz)
    function checkGrid(uint256 freqmHz) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = freqmHz;

        uint256[] memory distances = new uint256[](1);
        distances[0] = freqmHz;

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000;

        if (freqmHz > 60060 || freqmHz < 59940) { // ±100 mHz
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexGrid-Adaptive";
    }
}
