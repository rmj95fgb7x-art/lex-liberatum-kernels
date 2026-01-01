pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexConsent is RoyaltySplitter {
    uint256 public constant MIN_SIG_VERSION = 2024;
    uint256 public constant GAS_PER_CALL    = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkConsent(uint256 sigVersion) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (sigVersion < MIN_SIG_VERSION) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexConsent-Healthcare"; }
}
