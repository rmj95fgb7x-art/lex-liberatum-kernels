#![no_std]
#![forbid(unsafe_code)]
//! LexBlood kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x0E\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Rejected,
}

pub struct DonationCertificate {
    public donation_id: [u8; 32],    // SHA-256 of donation ID
    public blood_type: u8,           // ABO/RH encoded 0-31
    public volume_ml: u32,           // volume in millilitres
    public timestamp_nanos: u64,     // collection time
    public metadata: Vec<u8>,        // FDA/AABB meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub donation_id: [u8; 32],
    pub blood_type: u8,
    pub volume_ml: u32,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.donation_id);
        hasher.update([self.blood_type]);
        hasher.update(self.volume_ml.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &DonationCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.donation_id);
        hasher.update([cert.blood_type]);
        hasher.update(cert.volume_ml.to_be_bytes());
        let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy FDA/AABB compliance: volume ≤ 500 mL AND blood type encoded 0-31
    let decision = if cert.volume_ml <= 500 && cert.blood_type <= 31 {
        Decision::Approved
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        donation_id: cert.donation_id,
        blood_type: cert.blood_type,
        volume_ml: cert.volume_ml,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
