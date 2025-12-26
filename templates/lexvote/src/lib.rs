#![no_std]
#![forbid(unsafe_code)]
//! LexVote kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x14\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Certified,
    Rejected,
}

pub struct BallotCertificate {
    public ballot_id: [u8; 32],      // SHA-256 of ballot ID
    public precinct_hash: [u8; 32],  // SHA-256 of precinct
    public timestamp_nanos: u64,     // scan time
    public metadata: Vec<u8>,        // county/meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub ballot_id: [u8; 32],
    pub precinct_hash: [u8; 32],
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.ballot_id);
        hasher.update(&self.precinct_hash);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &BallotCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // Dummy election compliance: precinct hash must be non-zero
    let decision = if !cert.precinct_hash.iter().all(|&b| b == 0) {
        Decision::Certified
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        ballot_id: cert.ballot_id,
        precinct_hash: cert.precinct_hash,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
