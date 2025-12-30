// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/KEX.sol";
import "../src/KernelFactory.sol";

contract DeployFactoryAndKEX is Script {
    address constant BENEFICIARY = 0x44f8219cBABad92E6bf245D8c767179629D8C689;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. Deploy KEX (owner = factory, set below)
        KEX kex = new KEX();

        // 2. Deploy factory
        KernelFactory factory = new KernelFactory(kex, BENEFICIARY);

        // 3. Transfer KEX ownership to factory so it can mint
        kex.transferOwnership(address(factory));

        vm.stopBroadcast();

        console.log("KEX  deployed at:", address(kex));
        console.log("Factory deployed at:", address(factory));
    }
}
