#![no_std]
#![forbid(unsafe_code)]
//! LexWing kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x0D\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Certified,
    Rejected,
}

pub struct AircraftCertificate {
    public tail_number: [u8; 32],    // SHA-256 of N-number or serial
    public max_takeoff_kg: u32,      // MTOW in kilograms
    public passenger_capacity: u16,  // max passengers
    public timestamp_nanos: u64,     // certificate time
    public metadata: Vec<u8>,        // FAA/EASA meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub tail_number: [u8; 32],
    pub max_takeoff_kg: u32,
    pub passenger_capacity: u16,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.tail_number);
        hasher.update(self.max_takeoff_kg.to_be_bytes());
        hasher.update(self.passenger_capacity.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &AircraftCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.tail_number);
    hasher.update(cert.max_takeoff_kg.to_be_bytes());
    hasher.update(cert.passenger_capacity.to_be_bytes());
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy FAA/EASA compliance: MTOW ≥ 5 700 kg (regional jet) AND passengers ≤ 200
    let decision = if cert.max_takeoff_kg >= 5_700 && cert.passenger_capacity <= 200 {
        Decision::Certified
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        tail_number: cert.tail_number,
        max_takeoff_kg: cert.max_takeoff_kg,
        passenger_capacity: cert.passenger_capacity,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
