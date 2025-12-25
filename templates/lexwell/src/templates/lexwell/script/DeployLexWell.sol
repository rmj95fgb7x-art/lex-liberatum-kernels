// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexWellAdapter.sol";

contract DeployLexWell is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexWellAdapter adapter = new LexWellAdapter();
        vm.stopBroadcast();
        console.log("LexWell:", address(adapter));
    }
}
