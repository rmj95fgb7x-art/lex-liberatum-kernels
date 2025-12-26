// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexYachtAdapter.sol";

contract DeployLexYacht is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexYachtAdapter adapter = new LexYachtAdapter();
        vm.stopBroadcast();
        console.log("LexYacht:", address(adapter));
    }
}
