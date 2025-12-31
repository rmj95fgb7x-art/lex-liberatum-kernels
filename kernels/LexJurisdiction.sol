// SPDX-License-Identifier: Patent-Pending
pragma solidity ^0.8.25;

import "../src/RoyaltySplitter.sol";

/// @title LexJurisdiction
/// @notice 25 bp royalty on court jurisdiction compliance:
///         venue rule match, subject-matter jurisdiction, personal jurisdiction, minimum contacts.
contract LexJurisdiction is RoyaltySplitter {
    // FRCP 12(b)(3) / state long-arm statutes
    uint256 public constant MIN_CONTACTS_COUNT = 1;    // ≥ 1 contact
    uint256 public constant MAX_VENUE_MISMATCH_KM = 50; // ≤ 50 km venue error
    uint256 public constant GAS_PER_CALL        = 75_000;

    constructor(address _beneficiary) RoyaltySplitter(_beneficiary) {}

    /// @param contactsCount     Number of established minimum contacts
    /// @param venueMismatchKm   Kilometres between proper and chosen venue
    /// @param subjectMatterOk   True if court has subject-matter jurisdiction
    function checkJurisdiction(uint256 contactsCount, uint256 venueMismatchKm, bool subjectMatterOk) external payable {
        uint256 gasUsed = GAS_PER_CALL;
        uint256 baseFee = block.basefee;
        uint256 royaltyWei = gasUsed * baseFee * 75 * 25 / 1_000_000; // 0.75 multiplier

        bool compliant = (contactsCount >= MIN_CONTACTS_COUNT) &&
                         (venueMismatchKm <= MAX_VENUE_MISMATCH_KM) &&
                         (subjectMatterOk);

        if (!compliant) {
            _splitRoyalty{value: royaltyWei}();
        }
    }

    function vertical() external pure returns (string memory) {
        return "LexJurisdiction-Courts";
    }
}
