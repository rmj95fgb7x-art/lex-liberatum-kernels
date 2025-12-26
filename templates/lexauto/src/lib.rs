#![no_std]
#![forbid(unsafe_code)]
//! LexAuto kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x17\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Certified,
    Rejected,
}

pub struct SafetyReport {
    public vin_hash: [u8; 32],      // SHA-256 of VIN
    public crash_test_rating: u8,   // NCAP 0-5
    public emission_g_km: u16,      // g/km CO2
    public timestamp_nanos: u64,    // report time
    public metadata: Vec<u8>,       // NHTSA/EU meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub vin_hash: [u8; 32],
    pub crash_test_rating: u8,
    pub emission_g_km: u16,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.vin_hash);
        hasher.update([self.crash_test_rating]);
        hasher.update(self.emission_g_km.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(report: &SafetyReport) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // Dummy NHTSA/EU compliance: crash rating ≥ 4 AND emission ≤ 95 g/km
    let decision = if report.crash_test_rating >= 4 && report.emission_g_km <= 95 {
        Decision::Certified
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        vin_hash: report.vin_hash,
        crash_test_rating: report.crash_test_rating,
        emission_g_km: report.emission_g_km,
        nanos: report.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
