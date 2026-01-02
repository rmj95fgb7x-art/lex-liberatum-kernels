// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoyaltySplitter {
    address[] public recipients;
    uint256[] public shares;

    event RoyaltiesSet(address[] recipients, uint256[] shares);

    constructor(address[] memory _recipients, uint256[] memory _shares) {
        require(_recipients.length == _shares.length, "Recipients and shares must have the same length");
        require(_recipients.length > 0, "At least one recipient is required");
        for (uint256 i = 0; i < _shares.length; i++) {
            require(_shares[i] > 0, "Shares must be greater than zero");
        }

        recipients = _recipients;
        shares = _shares;

        emit RoyaltiesSet(recipients, shares);
    }

    function distributeRoyalty(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");

        uint256 totalShares = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            totalShares += shares[i];
        }

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 shareAmount = (amount * shares[i]) / totalShares;
            payable(recipients[i]).transfer(shareAmount);
        }
    }
}// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

/// @title RoyaltySplitter
/// @notice Accepts ETH fees per kernel, splits 25 bp to beneficiary, refunds surplus.
contract RoyaltySplitter {
    address public immutable beneficiary; // 0x44f8...D689
    mapping(string => uint256) public kernelFee; // kernel vertical => required ETH

    event RoyaltySplit(string indexed vertical, uint256 fee, uint256 royalty);

    constructor(address _beneficiary) {
        beneficiary = _beneficiary;
        // ---- pricing map (editable by owner) ----
        kernelFee["LexOrbit-ITU"]     = 0.0003 ether; // ~$1  (@ $3 k/ETH)
        kernelFee["LexNFT-GenerativeArt"] = 0.0005 ether;
        kernelFee["LexGrid-Frequency"]    = 0.0002 ether;
        kernelFee["LexESG-Carbon"]        = 0.0006 ether;
        kernelFee["LexShip-Ballast"]      = 0.0004 ether;
    }

    /// @param vertical  Kernel vertical string (must be pre-registered)
    /// @param data      Encoded call (passed to kernel for view-call)
    function processDecision(string calldata vertical, bytes calldata data)
        external
        payable
    {
        uint256 requiredFee = kernelFee[vertical];
        require(requiredFee > 0, "Splitter: unknown kernel");
        require(msg.value >= requiredFee, "Splitter: insufficient fee");

        uint256 royalty = (requiredFee * 25) / 10_000; // 25 bp slice
        (bool ok,) = beneficiary.call{value: royalty}("");
        require(ok, "Splitter: transfer failed");

        // refund surplus (if any)
        uint256 surplus = msg.value - requiredFee;
        if (surplus > 0) {
            (bool ok2,) = payable(msg.sender).call{value: surplus}("");
            require(ok2, "Splitter: surplus refund failed");
        }

        emit RoyaltySplit(vertical, requiredFee, royalty);
    }

    // Owner can adjust prices without recompiling kernels
    function setKernelFee(string calldata vertical, uint256 feeWei) external {
        require(msg.sender == beneficiary, "Splitter: only beneficiary");
        kernelFee[vertical] = feeWei;
    }
}
