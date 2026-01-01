pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexCarbonVintage is RoyaltySplitter {
    uint256 public constant MAX_VINTAGE_AGE_YEARS = 5; // ≤ 5 years old
    uint256 public constant GAS_PER_CALL          = 75_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkCarbonVintage(uint256 ageYears) external payable {
        uint256 royaltyWei = (75_000 * block.basefee * 75 * 25) / 1_000_000;
        if (ageYears > MAX_VINTAGE_AGE_YEARS) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexCarbonVintage-Corporate"; }
}
