// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
import "forge-std/Script.sol";
import "../src/RoyaltySplitter.sol";

contract DeployRoyaltySplitter is Script {
    // Same salt on every chain → identical address
    bytes32 public constant SALT = keccak256("Lex-Libertatum-RoyaltySplitter-2025");

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deterministic CREATE2 deploy → YOUR Exodus wallet
        bytes memory bytecode = abi.encodePacked(
            type(RoyaltySplitter).creationCode,
            abi.encode(address(0x44f8219cBABad92E6bf245D8c767179629D8C689)
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
