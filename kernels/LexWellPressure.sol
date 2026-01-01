// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;
import "../src/FlagshipAdaptiveBase.sol";
import "../src/RoyaltySplitter.sol";

contract LexWellPressure is RoyaltySplitter, FlagshipAdaptiveBase {
    uint256 public constant GAS_PER_CALL = 85_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param pressurePsi  Current well pressure (psi)
    function checkWellPressure(uint256 pressurePsi) external payable returns (uint256 fused) {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 85 * 25 / 1_000_000; // 0.85 multiplier

        uint256[] memory signals = new uint256[](1);
        signals[0] = pressurePsi;

        uint256[] memory distances = new uint256[](1);
        distances[0] = pressurePsi; // median = 0 for single value → distance = value

        uint256[] memory weights = adaptiveWeights(distances);
        fused = signals[0] * weights[0] / 10000; // weight will be 1.0 for single signal

        if (pressurePsi > 20000) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexWellPressure-Adaptive";
    }
}
