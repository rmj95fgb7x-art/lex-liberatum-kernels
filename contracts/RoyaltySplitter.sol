// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoyaltySplitter {
    address public artist;
    address public owner;
    uint256 public royaltyFee;

    constructor(address _artist, address _owner, uint256 _royaltyFee) {
        artist = _artist;
        owner = _owner;
        royaltyFee = _royaltyFee;
    }

    function splitRoyalties(uint256 amount) public payable {
        require(msg.value == amount, "Incorrect payment amount");
        uint256 artistShare = (amount * royaltyFee) / 100;
        uint256 ownerShare = amount - artistShare;
        payable(artist).transfer(artistShare);
        payable(owner).transfer(ownerShare);
    }

    function updateRoyaltyFee(uint256 _royaltyFee) public {
        require(msg.sender == owner, "Only the owner can update the royalty fee");
        royaltyFee = _royaltyFee;
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
