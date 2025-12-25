// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecisionToken is ERC20, Ownable {
    address public constant SPLITTER = 0x9f3D7662f0D76fcF86fF3Ef42bF6c0E25742A38B;
    uint256 public constant ROYALTY_BP = 25;
    struct Invoice { bytes32 certHash; uint64 anchorSeq; uint256 amountWei; bool paid; }
    mapping(bytes32 => Invoice) public invoices;
    uint256 public constant DCSN_PER_WEI = 1e10;

    event InvoiceMinted(bytes32 indexed certHash, uint256 amountWei, uint256 dcsnAmount);
    event InvoicePaid(bytes32 indexed certHash, uint256 dcsnBurnt);
    event RoyaltySkimmed(address indexed from, uint256 amount);

    constructor() ERC20("DECISION", "DCSN") Ownable(msg.sender) {}

    function mintInvoice(bytes32 certHash, uint256 amountWei) external {
        require(!invoices[certHash].paid, "already minted");
        uint256 dcsnAmount = amountWei / DCSN_PER_WEI;
        require(dcsnAmount > 0, "fee too small");
        _mint(address(this), dcsnAmount);
        invoices[certHash] = Invoice({ certHash: certHash, anchorSeq: uint64(block.timestamp), amountWei: amountWei, paid: false });
        emit InvoiceMinted(certHash, amountWei, dcsnAmount);
    }

    function payInvoice(bytes32 certHash) external {
        Invoice storage inv = invoices[certHash];
        require(!inv.paid, "already paid");
        uint256 dcsnNeeded = inv.amountWei / DCSN_PER_WEI;
        _burn(msg.sender, dcsnNeeded);
        inv.paid = true;
        emit InvoicePaid(certHash, dcsnNeeded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 royalty = (amount * ROYALTY_BP) / 10000;
        super._transfer(from, SPLITTER, royalty);
        super._transfer(from, to, amount - royalty);
        emit RoyaltySkimmed(from, royalty);
    }

    function decimals() public pure override returns (uint8) { return 8; }
}
