// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexPayAdapter.sol";

contract DeployLexPay is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexPayAdapter adapter = new LexPayAdapter();
        vm.stopBroadcast();
        console.log("LexPay:", address(adapter));
    }
}
