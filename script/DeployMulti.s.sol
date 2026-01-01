// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../contracts/RoyaltySplitter.sol";
import "../kernels/LexBOP.sol";
import "../kernels/LexPay.sol";
import "../kernels/LexBlood.sol";
import "../kernels/LexOrbit.sol";
import "../kernels/LexESG.sol";
import "../kernels/LexWell.sol";
import "../kernels/LexYacht.sol";
import "../kernels/LexPort.sol";
import "../kernels/LexSeal.sol";
import "../kernels/LexCarbon.sol";

contract DeployMulti is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address beneficiary = 0x44f8219cBABad92E6bf245D8c767179629D8C689;

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy RoyaltySplitter
        RoyaltySplitter splitter = new RoyaltySplitter(beneficiary);
        console.log("RoyaltySplitter deployed at:", address(splitter));

        // 2. Deploy Kernels
        LexBOP bop = new LexBOP(beneficiary);
        LexPay pay = new LexPay(beneficiary);
        LexBlood blood = new LexBlood(beneficiary);
        LexOrbit orbit = new LexOrbit(beneficiary);
        LexESG esg = new LexESG(beneficiary);
        LexWell well = new LexWell(beneficiary);
        LexYacht yacht = new LexYacht(beneficiary);
        LexPort port = new LexPort(beneficiary);
        LexSeal seal = new LexSeal(beneficiary);
        LexCarbon carbon = new LexCarbon(beneficiary);

        console.log("LexBOP:", address(bop));
        console.log("LexPay:", address(pay));
        console.log("LexBlood:", address(blood));
        console.log("LexOrbit:", address(orbit));
        console.log("LexESG:", address(esg));
        console.log("LexWell:", address(well));
        console.log("LexYacht:", address(yacht));
        console.log("LexPort:", address(port));
        console.log("LexSeal:", address(seal));
        console.log("LexCarbon:", address(carbon));

        // 3. Register Fees in Splitter
        splitter.setKernelFee("LexBOP-OilGas", 0.0003 ether);
        splitter.setKernelFee("LexPay-PCI-AML", 0.0002 ether);
        splitter.setKernelFee("LexBlood-ColdChain", 0.0004 ether);
        splitter.setKernelFee("LexOrbit-ITU", 0.0003 ether);
        splitter.setKernelFee("LexESG-Carbon", 0.0006 ether);
        splitter.setKernelFee("LexWell-OilGas", 0.0005 ether);
        splitter.setKernelFee("LexYacht-Safety", 0.0004 ether);
        splitter.setKernelFee("LexPort-Customs", 0.0003 ether);
        splitter.setKernelFee("LexSeal-Courts", 0.0002 ether);
        splitter.setKernelFee("LexCarbon-Monitor", 0.0006 ether);

        console.log("Fees registered in Splitter.");

        vm.stopBroadcast();

        // Final Summary
        console.log("=== Deployment Complete ===");
        console.log("Beneficiary: 0x44f8219cBABad92E6bf245D8c767179629D8C689");
        console.log("Splitter:", address(splitter));
    }
}
