// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexBloodAdapter.sol";

contract DeployLexBlood is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexBloodAdapter adapter = new LexBloodAdapter();
        vm.stopBroadcast();
        console.log("LexBlood:", address(adapter));
    }
}
