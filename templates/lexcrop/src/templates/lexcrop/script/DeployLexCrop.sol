// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/LexCropAdapter.sol";

contract DeployLexCrop is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        LexCropAdapter adapter = new LexCropAdapter();
        vm.stopBroadcast();
        console.log("LexCrop:", address(adapter));
    }
}
