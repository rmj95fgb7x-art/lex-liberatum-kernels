pragma solidity ^0.8.25;
import "../src/RoyaltySplitter.sol";
contract LexCrewRad is RoyaltySplitter {
    uint256 public constant MAX_DOSE_mSv = 50; // 50 mSv annual
    uint256 public constant GAS_PER_CALL = 100_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkCrewRad(uint256 doseMSv) external payable {
        uint256 royaltyWei = (100_000 * block.basefee * 100 * 25) / 1_000_000;
        if (doseMSv > MAX_DOSE_mSv) _splitRoyalty{value: royaltyWei}();
    }
    function vertical() external pure returns (string memory) { return "LexCrewRad-Space"; }
}
