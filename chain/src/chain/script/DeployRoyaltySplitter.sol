// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/RoyaltySplitter.sol";

contract DeployRoyaltySplitter is Script {
    // Same salt on every chain → identical address
    bytes32 public constant SALT = keccak256("Lex-Libertatum-RoyaltySplitter-2025");

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deterministic CREATE2 deploy
        bytes memory bytecode = abi.encodePacked(
            type(RoyaltySplitter).creationCode,
            abi.encode(address(0x9f3D7662f0D76fcF86fF3Ef42bF6c0E25742A38B) // beneficiary = trust treasury
        );

        address splitter;
        assembly {
            splitter := create2(0, add(bytecode, 32), mload(bytecode), SALT)
        }
        require(splitter != address(0), "CREATE2 failed");

        vm.stopBroadcast();
        console.log("RoyaltySplitter (CREATE2):", splitter);
    }
}
