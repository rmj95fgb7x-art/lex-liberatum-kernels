// SPDX-License-Identifier: Lex-Libertatum-1.0
pragma solidity ^0.8.23;
interface IERC20 { function transfer(address,uint256) external; function balanceOf(address) external view returns (uint256); }
contract RoyaltySplitter {
    address public constant TRUST = 0x000000000000000000000000000000000000dEaD; // test-net burn
    function skim(address token) external {
        uint256 bal = IERC20(token).balanceOf(address(this));
        if (bal > 0) IERC20(token).transfer(TRUST, bal);
    }
}
