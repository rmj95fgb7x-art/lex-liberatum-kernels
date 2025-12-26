#![no_std]
#![forbid(unsafe_code)]
//! LexYacht kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x0C\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Certified,
    Rejected,
}

pub struct YachtCertificate {
    public vessel_id: [u8; 32],      // SHA-256 of IMO number
    public tonnage_gt: u32,          // gross tonnage
    public passenger_capacity: u16,  // max passengers
    public timestamp_nanos: u64,     // certificate time
    public metadata: Vec<u8>,        // IMO/USCG meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub vessel_id: [u8; 32],
    pub tonnage_gt: u32,
    pub passenger_capacity: u16,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.vessel_id);
        hasher.update(self.tonnage_gt.to_be_bytes());
        hasher.update(self.passenger_capacity.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &YachtCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.vessel_id);
    hasher.update(cert.tonnage_gt.to_be_bytes());
    hasher.update(cert.passenger_capacity.to_be_bytes());
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy IMO/USCG compliance: tonnage ≥ 500 GT AND passengers ≤ 12 (yacht code)
    let decision = if cert.tonnage_gt >= 500 && cert.passenger_capacity <= 12 {
        Decision::Certified
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        vessel_id: cert.vessel_id,
        tonnage_gt: cert.tonnage_gt,
        passenger_capacity: cert.passenger_capacity,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
