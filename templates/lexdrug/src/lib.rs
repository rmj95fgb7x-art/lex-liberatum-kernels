#![no_std]
#![forbid(unsafe_code)]
//! LexDrug kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x15\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Rejected,
}

pub struct DrugApplication {
    public nda_number: [u8; 32],     // SHA-256 of NDA/BLA number
    public phase: u8,                // clinical phase 1-3
    public ingredient_count: u8,     // number of active ingredients
    public timestamp_nanos: u64,     // submission time
    public metadata: Vec<u8>,        // FDA meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub nda_number: [u8; 32],
    pub phase: u8,
    pub ingredient_count: u8,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.nda_number);
        hasher.update([self.phase]);
        hasher.update([self.ingredient_count]);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(app: &DrugApplication) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // Dummy FDA compliance: phase ≤ 3 AND ingredient count ≤ 10
    let decision = if app.phase <= 3 && app.ingredient_count <= 10 {
        Decision::Approved
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        nda_number: app.nda_number,
        phase: app.phase,
        ingredient_count: app.ingredient_count,
        nanos: app.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
