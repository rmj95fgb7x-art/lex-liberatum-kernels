// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/RoyaltySplitter.sol";
import "../src/DecisionToken.sol";
contract Deploy is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address split = address(new RoyaltySplitter());
        address token = address(new DecisionToken());
        vm.stopBroadcast();
        console.log("Splitter:", split);
        console.log("Token:  ", token);
    }
}
