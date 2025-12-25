// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexColaAdapter.sol";

contract DeployLexCola is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexColaAdapter adapter = new LexColaAdapter();
        vm.stopBroadcast();
        console.log("LexCola:", address(adapter));
    }
}
