// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexClaimAdapter.sol";

contract DeployLexClaim is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexClaimAdapter adapter = new LexClaimAdapter();
        vm.stopBroadcast();
        console.log("LexClaim:", address(adapter));
    }
}
