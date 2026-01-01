// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../contracts/KernelFactory.sol";

// Import all 25 working kernels
import "../kernels/LexOrbit.sol";
import "../kernels/LexNFT.sol";
import "../kernels/LexGrid.sol";
import "../kernels/LexESG.sol";
import "../kernels/LexShip.sol";
import "../kernels/LexWell.sol";
import "../kernels/LexChart.sol";
import "../kernels/LexDocket.sol";
import "../kernels/LexSAR.sol";
import "../kernels/LexQoS.sol";
import "../kernels/LexPort.sol";
import "../kernels/LexCold.sol";
import "../kernels/LexICD.sol";
import "../kernels/LexLot.sol";
import "../kernels/LexH2S.sol";
import "../kernels/LexFlare.sol";
import "../kernels/LexBOP.sol";
import "../kernels/LexCola.sol";
import "../kernels/LexDerm.sol";
import "../kernels/LexPay.sol";
import "../kernels/LexCarbon.sol";
import "../kernels/LexBlood.sol";
import "../kernels/LexYacht.sol";
import "../kernels/LexElection.sol";
import "../kernels/LexCrypto.sol";

contract DeployBatch25 is Script {
    address constant BENEFICIARY = 0x44f8219cBABad92E6bf245D8c767179629D8C689;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        KernelFactory factory = KernelFactory(vm.envAddress("FACTORY_ADDRESS"));

        string[25] memory names = [
            "LexOrbit-ITU",
            "LexNFT-GenerativeArt",
            "LexGrid-Frequency",
            "LexESG-Carbon",
            "LexShip-Ballast",
            "LexWell-OilSafety",
            "LexChart-Pharma",
            "LexDocket-Courts",
            "LexSAR-Satellite",
            "LexQoS-Telecom",
            "LexPort-Number",
            "LexCold-Pharma",
            "LexICD-Coding",
            "LexLot-Recall",
            "LexH2S-OilGas",
            "LexFlare-OilGas",
            "LexBOP-OilGas",
            "LexCola-TTB",
            "LexDerm-Cosmetics",
            "LexPay-PCI-AML",
            "LexCarbon-Credits",
            "LexBlood-ColdChain",
            "LexYacht-Charter",
            "LexElection-Ballot",
            "LexCrypto-Oracle"
        ];

        for (uint i = 0; i < 25; ++i) {
            address kernel;
            bytes32 salt = keccak256(abi.encodePacked(names[i], "-v1.0.1"));

            if (i == 0) kernel = address(new LexOrbit(BENEFICIARY));
            if (i == 1) kernel = address(new LexNFT(BENEFICIARY));
            if (i == 2) kernel = address(new LexGrid(BENEFICIARY));
            if (i == 3) kernel = address(new LexESG(BENEFICIARY));
            if (i == 4) kernel = address(new LexShip(BENEFICIARY));
            if (i == 5) kernel = address(new LexWell(BENEFICIARY));
            if (i == 6) kernel = address(new LexChart(BENEFICIARY));
            if (i == 7) kernel = address(new LexDocket(BENEFICIARY));
            if (i == 8) kernel = address(new LexSAR(BENEFICIARY));
            if (i == 9) kernel = address(new LexQoS(BENEFICIARY));
            if (i == 10) kernel = address(new LexPort(BENEFICIARY));
            if (i == 11) kernel = address(new LexCold(BENEFICIARY));
            if (i == 12) kernel = address(new LexICD(BENEFICIARY));
            if (i == 13) kernel = address(new LexLot(BENEFICIARY));
            if (i == 14) kernel = address(new LexH2S(BENEFICIARY));
            if (i == 15) kernel = address(new LexFlare(BENEFICIARY));
            if (i == 16) kernel = address(new LexBOP(BENEFICIARY));
            if (i == 17) kernel = address(new LexCola(BENEFICIARY));
            if (i == 18) kernel = address(new LexDerm(BENEFICIARY));
            if (i == 19) kernel = address(new LexPay(BENEFICIARY));
            if (i == 20) kernel = address(new LexCarbon(BENEFICIARY));
            if (i == 21) kernel = address(new LexBlood(BENEFICIARY));
            if (i == 22) kernel = address(new LexYacht(BENEFICIARY));
            if (i == 23) kernel = address(new LexElection(BENEFICIARY));
            if (i == 24) kernel = address(new LexCrypto(BENEFICIARY));

            console.log(names[i], "deployed at:", kernel);
        }

        vm.stopBroadcast();
    }
}
