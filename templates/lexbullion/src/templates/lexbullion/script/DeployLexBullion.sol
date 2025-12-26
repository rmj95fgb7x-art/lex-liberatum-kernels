// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexBullionAdapter.sol";

contract DeployLexBullion is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexBullionAdapter adapter = new LexBullionAdapter();
        vm.stopBroadcast();
        console.log("LexBullion:", address(adapter));
    }
}
