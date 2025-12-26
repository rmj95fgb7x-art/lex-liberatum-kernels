#![no_std]
#![forbid(unsafe_code)]
//! LexToy kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x09\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Certified,
    Rejected,
}

pub struct ToyCertificate {
    public product_id: [u8; 32],     // SHA-256 of internal SKU
    public test_lab_id: [u8; 16],    // accredited lab ID
    public age_months_max: u8,       // max age in months
    public timestamp_nanos: u64,     // certificate time
    public metadata: Vec<u8>,        // CPSC/EU meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub product_id: [u8; 32],
    pub test_lab_id: [u8; 16],
    pub age_months_max: u8,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.product_id);
        hasher.update(&self.test_lab_id);
        hasher.update([self.age_months_max]);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &ToyCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.product_id);
    hasher.update(&cert.test_lab_id);
    hasher.update([cert.age_months_max]);
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy CPSC/EU compliance: age ≤ 36 months AND accredited lab
    let decision = if cert.age_months_max <= 36 && !cert.test_lab_id.iter().all(|&b| b == 0) {
        Decision::Certified
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        product_id: cert.product_id,
        test_lab_id: cert.test_lab_id,
        age_months_max: cert.age_months_max,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
