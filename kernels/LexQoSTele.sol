pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexQoSTele is RoyaltySplitter {
    uint256 public constant MIN_SCORE_PERMILLE = 950; // ≥ 95 % QoS score
    uint256 public constant GAS_PER_CALL       = 85_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkQoSTele(uint256 scorePermille) external payable {
        uint256 royaltyWei = (85_000 * block.basefee * 85 * 25) / 1_000_000;
        if (scorePermille < MIN_SCORE_PERMILLE) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexQoSTele-Telecom"; }
}
