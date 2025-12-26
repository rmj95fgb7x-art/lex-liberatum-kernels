// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexVoteAdapter.sol";

contract DeployLexVote is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexVoteAdapter adapter = new LexVoteAdapter();
        vm.stopBroadcast();
        console.log("LexVote:", address(adapter));
    }
}
