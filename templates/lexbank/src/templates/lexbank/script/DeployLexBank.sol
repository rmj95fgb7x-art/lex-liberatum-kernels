// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexBankAdapter.sol";

contract DeployLexBank is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexBankAdapter adapter = new LexBankAdapter();
        vm.stopBroadcast();
        console.log("LexBank:", address(adapter));
    }
}
