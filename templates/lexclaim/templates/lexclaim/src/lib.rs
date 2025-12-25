#![no_std]
#![forbid(unsafe_code)]
//! LexClaim kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Keccak256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x04\x00"; // claims 0,1,2,3 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Rejected,
    Flagged,
}

pub struct Claim {
    pub policy_id: [u8; 32],        // keccak of policy number
    pub claim_hash: [u8; 32],       // keccak of claim JSON blob
    pub evidence_hashes: Vec<[u8; 32]>, // IPFS hashes
    pub claimed_usd: u64,           // cents
    pub submitted_nanos: u64,       // timestamp
}

pub struct Certificate {
    pub decision: Decision,
    pub policy_hash: [u8; 32],
    pub claim_hash: [u8; 32],
    nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Keccak256::new();
        hasher.update(&self.policy_hash);
        hasher.update(&self.claim_hash);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(claim: &Claim) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Basic rules
    let decision = if claim.claimed_usd == 0 {
        Decision::Rejected
    } else if claim.claimed_usd > 50_000_00 { // $50 k cap
        Decision::Flagged
    } else if claim.evidence_hashes.len() < 2 {
        Decision::Flagged
    } else {
        Decision::Approved
    };

    let cert = Certificate {
        decision,
        policy_hash: claim.policy_id,
        claim_hash: claim.claim_hash,
        nanos: claim.submitted_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
