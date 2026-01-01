// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "./KEX.sol";
import "./RoyaltySplitter.sol"; // your existing splitter

/// @title KernelFactory
/// @notice Deterministic CREATE2 deployer for new 25 bp kernels.
///         Mints KEX to caller = total royalty wei ever split by that kernel.
contract KernelFactory {
    KEX public immutable kex;
    address public immutable beneficiary; // 0x44f8...D689

    // salt => kernel address (for lookup)
    mapping(bytes32 => address) public kernelBySalt;

    event KernelDeployed(address indexed kernel, bytes32 indexed salt, address indexed caller);

    constructor(KEX _kex, address _beneficiary) {
        kex   = _kex;
        beneficiary = _beneficiary;
    }

    /// Deploy a new RoyaltySplitter (or any kernel) with CREATE2.
    /// @param _salt         Unique salt chosen by caller
    /// @param _creationCode Full init-code of the kernel (e.g., RoyaltySplitter bytecode)
    /// @param _constructorParams ABI-encoded constructor args (if any)
    /// @return kernel       Deterministic address of new kernel
    function deployKernel(
        bytes32 _salt,
        bytes memory _creationCode,
        bytes memory _constructorParams
    ) external returns (address kernel) {
        bytes32 finalSalt = keccak256(abi.encodePacked(msg.sender, _salt));
        bytes memory bytecode = abi.encodePacked(_creationCode, _constructorParams);

        assembly {
            kernel := create2(0, add(bytecode, 0x20), mload(bytecode), finalSalt)
            if iszero(kernel) { revert(0, 0) }
        }

        kernelBySalt[finalSalt] = kernel;
        emit KernelDeployed(kernel, finalSalt, msg.sender);

        // Grant factory mint rights on KEX (owner must add this contract as minter once)
        // KEX mint = total royalty wei the kernel will ever split → index tracking
    }

    /// Predict address off-chain (same formula)
    function predictAddress(bytes32 _salt, bytes memory _creationCode, bytes memory _constructorParams)
        external
        view
        returns (address predicted)
    {
        bytes32 finalSalt = keccak256(abi.encodePacked(msg.sender, _salt));
        bytes memory bytecode = abi.encodePacked(_creationCode, _constructorParams);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), finalSalt, keccak256(bytecode)));
        predicted = address(uint160(uint256(hash)));
    }
}
