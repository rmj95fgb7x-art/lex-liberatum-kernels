// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/KernelFactory.sol";
import "../kernels/LexSAR.sol";
import "../kernels/LexNFT.sol";
import "../kernels/LexGrid.sol";
import "../kernels/LexESG.sol";
import "../kernels/LexShip.sol";

contract DeployLexBatch is Script {
    address constant BENEFICIARY = 0x44f8219cBABad92E6bf245D8c767179629D8C689;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. Deploy each kernel via factory (CREATE2 salts for determinism)
        KernelFactory factory = KernelFactory(vm.envAddress("FACTORY_ADDRESS"));

        bytes memory bytecode;
        bytes memory args;

        // LexSAR
        bytecode = type(LexSAR).creationCode;
        args   = abi.encode(BENEFICIARY);
        address lexSAR = factory.deployKernel(keccak256("LexSAR-v1"), bytecode, args);
        console.log("LexSAR   deployed at:", lexSAR);

        // LexNFT
        bytecode = type(LexNFT).creationCode;
        args   = abi.encode(BENEFICIARY);
        address lexNFT = factory.deployKernel(keccak256("LexNFT-v1"), bytecode, args);
        console.log("LexNFT   deployed at:", lexNFT);

        // LexGrid
        bytecode = type(LexGrid).creationCode;
        args   = abi.encode(BENEFICIARY);
        address lexGrid = factory.deployKernel(keccak256("LexGrid-v1"), bytecode, args);
        console.log("LexGrid  deployed at:", lexGrid);

        // LexESG
        bytecode = type(LexESG).creationCode;
        args   = abi.encode(BENEFICIARY);
        address lexESG = factory.deployKernel(keccak256("LexESG-v1"), bytecode, args);
        console.log("LexESG   deployed at:", lexESG);

        // LexShip
        bytecode = type(LexShip).creationCode;
        args   = abi.encode(BENEFICIARY);
        address lexShip = factory.deployKernel(keccak256("LexShip-v1"), bytecode, args);
        console.log("LexShip  deployed at:", lexShip);

        vm.stopBroadcast();
    }
}
