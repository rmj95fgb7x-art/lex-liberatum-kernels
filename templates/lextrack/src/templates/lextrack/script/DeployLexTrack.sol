// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexTrackAdapter.sol";

contract DeployLexTrack is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexTrackAdapter adapter = new LexTrackAdapter();
        vm.stopBroadcast();
        console.log("LexTrack:", address(adapter));
    }
}
