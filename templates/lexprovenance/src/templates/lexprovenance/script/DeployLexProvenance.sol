// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexProvenanceAdapter.sol";

contract DeployLexProvenance is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexProvenanceAdapter adapter = new LexProvenanceAdapter();
        vm.stopBroadcast();
        console.log("LexProvenance:", address(adapter));
    }
}
