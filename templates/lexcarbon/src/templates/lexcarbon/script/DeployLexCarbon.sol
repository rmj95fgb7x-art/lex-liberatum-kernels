// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexCarbonAdapter.sol";

contract DeployLexCarbon is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexCarbonAdapter adapter = new LexCarbonAdapter();
        vm.stopBroadcast();
        console.log("LexCarbon:", address(adapter));
    }
}
