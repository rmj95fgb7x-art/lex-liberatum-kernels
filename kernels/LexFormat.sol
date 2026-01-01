pragma solidity ^0.8.25;
import "src/RoyaltySplitter.sol";
contract LexFormat is RoyaltySplitter {
    bytes3  public constant PDF_SUBTYPE = "A-3";
    uint256 public constant MIN_FONT_PT = 14;
    uint256 public constant GAS_PER_CALL= 70_000;
    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}
    function checkFormat(bytes3 pdfSubtype, uint256 fontPt) external payable {
        uint256 royaltyWei = (70_000 * block.basefee * 70 * 25) / 1_000_000;
        bool ok = (pdfSubtype == PDF_SUBTYPE) && (fontPt >= MIN_FONT_PT);
        if (!ok) _splitRoyalty(royaltyWei);
    }
    function vertical() external pure returns (string memory) { return "LexFormat-Courts"; }
}
