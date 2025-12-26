// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexPolicyAdapter.sol";

contract DeployLexPolicy is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexPolicyAdapter adapter = new LexPolicyAdapter();
        vm.stopBroadcast();
        console.log("LexPolicy:", address(adapter));
    }
}
