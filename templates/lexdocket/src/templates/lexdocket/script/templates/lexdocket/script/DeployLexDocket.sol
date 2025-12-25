// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "../src/LexDocketAdapter.sol";

contract DeployLexDocket is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexDocketAdapter adapter = new LexDocketAdapter();
        vm.stopBroadcast();
        console.log("LexDocket:", address(adapter));
    }
}
