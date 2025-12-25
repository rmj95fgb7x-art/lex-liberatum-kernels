// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexDermAdapter.sol";

contract DeployLexDerm is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexDermAdapter adapter = new LexDermAdapter();
        vm.stopBroadcast();
        console.log("LexDerm:", address(adapter));
    }
}
