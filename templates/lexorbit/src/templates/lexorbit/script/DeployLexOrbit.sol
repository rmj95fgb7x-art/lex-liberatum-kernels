// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexOrbitAdapter.sol";

contract DeployLexOrbit is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexOrbitAdapter adapter = new LexOrbitAdapter();
        vm.stopBroadcast();
        console.log("LexOrbit:", address(adapter));
    }
}
