pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexCosmetic is RoyaltySplitter {
    bytes32 public constant BANNED = keccak256("Hydroquinone");
    uint256 public constant GAS_PER_CALL = 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkCosmetic(bytes32 ingredient) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        if (ingredient == BANNED) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexCosmetic-Health"; }
}
