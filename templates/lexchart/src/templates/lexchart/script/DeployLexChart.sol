// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexChartAdapter.sol";

contract DeployLexChart is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexChartAdapter adapter = new LexChartAdapter();
        vm.stopBroadcast();
        console.log("LexChart:", address(adapter));
    }
}
