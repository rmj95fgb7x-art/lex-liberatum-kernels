// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexAutoAdapter.sol";

contract DeployLexAuto is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexAutoAdapter adapter = new LexAutoAdapter();
        vm.stopBroadcast();
        console.log("LexAuto:", address(adapter));
    }
}
