// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexDeedAdapter.sol";

contract DeployLexDeed is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexDeedAdapter adapter = new LexDeedAdapter();
        vm.stopBroadcast();
        console.log("LexDeed:", address(adapter));
    }
}
