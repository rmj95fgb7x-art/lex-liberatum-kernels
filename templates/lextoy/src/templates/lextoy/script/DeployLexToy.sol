// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexToyAdapter.sol";

contract DeployLexToy is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexToyAdapter adapter = new LexToyAdapter();
        vm.stopBroadcast();
        console.log("LexToy:", address(adapter));
    }
}
