// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title KEX - Kernel Index Token
/// @notice Each KEX = 1 wei of aggregate 25 bp royalties ever split.
contract KEX is ERC20("Kernel Index", "KEX"), Ownable {
    /// Minter is the RoyaltySplitter factory; can mint only when royalties accrue.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
