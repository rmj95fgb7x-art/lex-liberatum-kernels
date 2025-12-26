// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexDrugAdapter.sol";

contract DeployLexDrug is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexDrugAdapter adapter = new LexDrugAdapter();
        vm.stopBroadcast();
        console.log("LexDrug:", address(adapter));
    }
}
