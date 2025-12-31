// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/KernelFactory.sol";
import "../kernels/LexOrbit.sol";
import "../kernels/LexNFT.sol";
import "../kernels/LexGrid.sol";
import "../kernels/LexESG.sol";
import "../kernels/LexShip.sol";
import "../kernels/LexWell.sol";
import "../kernels/LexChart.sol";
import "../kernels/LexDocket.sol";

contract DeployWorkingKernels is Script {
    address constant BENEFICIARY = 0x44f8219cBABad92E6bf245D8c767179629D8C689;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        KernelFactory factory = KernelFactory(vm.envAddress("FACTORY_ADDRESS"));

        // --- 8 working kernels ---
        address[8] memory addrs;
        string[8]  memory names;
        bytes32[8] memory salts;

        // 1. LexOrbit
        addrs[0] = factory.deployKernel(
            keccak256("LexOrbit-v1.0.1"),
            type(LexOrbit).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[0] = "LexOrbit-ITU";

        // 2. LexNFT
        addrs[1] = factory.deployKernel(
            keccak256("LexNFT-v1.0.1"),
            type(LexNFT).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[1] = "LexNFT-GenerativeArt";

        // 3. LexGrid
        addrs[2] = factory.deployKernel(
            keccak256("LexGrid-v1.0.1"),
            type(LexGrid).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[2] = "LexGrid-Frequency";

        // 4. LexESG
        addrs[3] = factory.deployKernel(
            keccak256("LexESG-v1.0.1"),
            type(LexESG).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[3] = "LexESG-Carbon";

        // 5. LexShip
        addrs[4] = factory.deployKernel(
            keccak256("LexShip-v1.0.1"),
            type(LexShip).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[4] = "LexShip-Ballast";

        // 6. LexWell
        addrs[5] = factory.deployKernel(
            keccak256("LexWell-v1.0.1"),
            type(LexWell).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[5] = "LexWell-OilSafety";

        // 7. LexChart
        addrs[6] = factory.deployKernel(
            keccak256("LexChart-v1.0.1"),
            type(LexChart).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[6] = "LexChart-Pharma";

        // 8. LexDocket
        addrs[7] = factory.deployKernel(
            keccak256("LexDocket-v1.0.1"),
            type(LexDocket).creationCode,
            abi.encode(BENEFICIARY)
        );
        names[7] = "LexDocket-Courts";

        vm.stopBroadcast();

        for (uint i = 0; i < 8; ++i) {
            console.log(names[i], "deployed at:", addrs[i]);
        }
    }
}
