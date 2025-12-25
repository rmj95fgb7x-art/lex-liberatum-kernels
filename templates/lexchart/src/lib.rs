#![no_std]
#![forbid(unsafe_code)]
//! LexChart kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x04\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Denied,
}

pub struct PriorAuth {
    pub patient_hash: [u8; 32],   // SHA-256 of patient ID
    pub drug_code: [u8; 16],      // NDC-11 (padded)
    pub days_supply: u16,         // requested days
    pub timestamp_nanos: u64,     // submission time
    pub metadata: Vec<u8>,        // opaque payer meta
}

pub struct Certificate {
    pub decision: Decision,
    pub patient_hash: [u8; 32],
    pub drug_code: [u8; 16],
    pub days_supply: u16,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.patient_hash);
        hasher.update(&self.drug_code);
        hasher.update(self.days_supply.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub decide(auth: &PriorAuth) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the request blob
    let mut hasher = Sha3_256::new();
    hasher.update(&auth.patient_hash);
    hasher.update(&auth.drug_code);
    hasher.update(auth.days_supply.to_be_bytes());
    let request_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy compliance: days ≤ 30 (step-therapy guard)
    let decision = if auth.days_supply <= 30 {
        Decision::Approved
    } else {
        Decision::Denied
    };

    let cert = Certificate {
        decision,
        patient_hash: auth.patient_hash,
        drug_code: auth.drug_code,
        days_supply: auth.days_supply,
        nanos: auth.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
