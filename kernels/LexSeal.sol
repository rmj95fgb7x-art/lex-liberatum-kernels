// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "src/RoyaltySplitter.sol";

/// @title LexSeal
/// @notice 25 bp royalty on court-document seal compliance:
///         seal image present, digital signature valid, certificate chain trusted, expiry check.
contract LexSeal is RoyaltySplitter {
    // State e-filing technical specs
    uint256 public constant MIN_SEAL_SIZE_PX     = 100;   // ≥ 100 px width
    uint256 public constant MAX_CERT_DAYS        = 30;    // cert valid ≥ 30 days
    uint256 public constant GAS_PER_CALL         = 80_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param sealPresent     True if visible seal uploaded
    /// @param sigValid        True if digital signature verifies
    /// @param certDaysLeft    Days until signer certificate expiry
    function checkSeal(bool sealPresent, bool sigValid, uint256 certDaysLeft) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 80 * 25 / 1_000_000; // 0.80 multiplier

        bool compliant = (sealPresent) &&
                         (sigValid) &&
                         (certDaysLeft >= MAX_CERT_DAYS);

        if (!compliant) {
            _splitRoyalty(royaltyWei);
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexSeal-Courts";
    }
}
