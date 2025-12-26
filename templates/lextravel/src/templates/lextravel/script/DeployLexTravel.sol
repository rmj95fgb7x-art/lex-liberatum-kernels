// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexTravelAdapter.sol";

contract DeployLexTravel is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexTravelAdapter adapter = new LexTravelAdapter();
        vm.stopBroadcast();
        console.log("LexTravel:", address(adapter));
    }
}
