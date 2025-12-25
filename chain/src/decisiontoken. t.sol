// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Test.sol";
import "../src/DecisionToken.sol";
contract DecisionTokenTest is Test {
    DecisionToken t;
    bytes32 constant CERT = keccak256("test");
    function setUp() external { t = new DecisionToken(); }
    function testMintPay() external {
        uint256 fee = 21_000 * 1 gwei;
        t.mintInvoice(CERT, fee);
        uint256 need = fee / 1e10;
        assertEq(t.totalSupply(), need);
        t.transfer(address(0x42), need);
        vm.prank(address(0x42)); t.payInvoice(CERT);
        assertEq(t.totalSupply(), 0);
        assertTrue(t.invoices(CERT).paid);
    }
}
