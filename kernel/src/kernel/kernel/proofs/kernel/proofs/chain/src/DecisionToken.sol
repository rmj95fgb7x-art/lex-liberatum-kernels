// SPDX-License-Identifier: Lex-Libertatum-1.0
// Legal owner: Lex Libertatum Trust, A.T.W.W., Trustee
// Patent: PCT/US2025/63-XXX-PROV (Lex Libertatum Trust, A.T.W.W., Trustee)

pragma solidity ^0.8.23;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecisionToken is ERC20, Ownable {
    /* ---------- royalty constants ---------- */
    address public constant ROYALTY_SPLITTER =
        0x9f3D7662f0D76fcF86fF3Ef42bF6c0E25742A38B; // <-- trust-held splitter
    uint256 public constant ROYALTY_BP = 25;

    /* ---------- invoice structs unchanged ---------- */
    struct Invoice {
        bytes32 certHash;
        uint64 anchorSeq;
        uint256 amountWei;
        bool paid;
}
    mapping(bytes32 => Invoice) public invoices;
    mapping(bytes32 => uint256) public partnerBp;

    uint256 public constant DCSN_PER_WEI = 1e10;        // 1 DCSN = 1e-8 ETH
    uint256 public constant BP_DENOM     = 10_000;

    /* ---------- events ---------- */
    event InvoiceMinted(
        bytes32 indexed certHash,
        uint256 amountWei,
        uint256 dcsnAmount,
        uint256 bpPartner
    );
    event InvoicePaid(bytes256 certHash, uint256 dcsnBurnt);


    constructor() ERC20("DECISION", "DCSN") Ownable(msg.sender) {}

    /* ---------- mint / pay logic ---------- */
    function mintInvoice(
        bytes32 certHash,
        uint256 amountWei,
        uint256 bpPartner
    ) external {
        require(!invoices[certHash].paid, "already minted");
        require(bpPartner <= BP_DENOM, "bp overflow");
        uint256 dcsnAmount = amountWei / DCSN_PER_WEI;
        require(dcsnAmount > 0, "fee too small");
        _mint(address(this), dcsnAmount);
        invoices[certHash] = Invoice({
            certHash: certHash,
            anchorSeq: uint64(block.timestamp),
            amountWei: amountWei,
            paid: false
        });
        partnerBp[certHash] = bpPartner;
        emit InvoiceMinted(certHash, amountWei, dcsnAmount, bpPartner);
    }

    function payInvoice(bytes32 certHash) external {
        uint256 dcsnNeeded = invoices[certHash].amountWei / DCSN_PER_WEI;
        require(dcsnNeeded > 0, "fee too small");
        _burn(msg.sender, dcsnNeeded);
        invoices[certHash].paid = true;
        emit InvoicePaid(certHash, dcsnNeeded);
    }

    /* ---------- royalty-enforcing transfer ---------- */
    function _transfer(address from, address to, uint256 amount) internal override {
        uint256 royalty = (amount * ROYALTY_BP) / BP_DENOM;
        super._transfer(from, ROYALTY_SPLITTER, royalty);
        super._transfer(from, to, amount - royalty);
        emit RoyaltySkimmed(from, royalty);
    }

    function decimals() public pure override returns (uint8) { return 8; }
}
