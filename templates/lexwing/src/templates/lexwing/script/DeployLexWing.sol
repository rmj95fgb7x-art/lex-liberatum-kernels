// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexWingAdapter.sol";

contract DeployLexWing is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexWingAdapter adapter = new LexWingAdapter();
        vm.stopBroadcast();
        console.log("LexWing:", address(adapter));
    }
}
