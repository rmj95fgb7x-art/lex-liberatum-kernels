pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexFlareEff is RoyaltySplitter {
    uint256 public constant MIN_EFF_PERCENT = 98;
    uint256 public constant GAS_PER_CALL    = 100_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkFlareEff(uint256 effPercent) external payable {
        uint256 royaltyWei = (100_000 * block.basefee * 100 * 25) / 1_000_000;
        if (effPercent < MIN_EFF_PERCENT) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexFlareEff-Energy"; }
}
