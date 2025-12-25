#![no_std]
#![forbid(unsafe_code)]
//! LexWell kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x03\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Compliant,
    NonCompliant,
}

pub struct SafetyReport {
    pub well_id: [u8; 32],        // SHA-256 of API number
    pub flare_rate_bpm: u32,      // barrels per minute flared
    pub pressure_psi: u32,        // line pressure
    pub timestamp_nanos: u64,     // report time
    pub metadata: Vec<u8>,        // opaque operator data
}

pub struct Certificate {
    pub decision: Decision,
    pub well_hash: [u8; 32],
    pub flare_rate: u32,
    pub pressure: u32,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.well_hash);
        hasher.update(self.flare_rate.to_be_bytes());
        hasher.update(self.pressure.to_be_bytes());
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

    // 1. Hash the report blob
    let mut hasher = Sha3_256::new();
    hasher.update(&report.well_id);
    hasher.update(report.flare_rate_bpm.to_be_bytes());
    hasher.update(report.pressure_psi.to_be_bytes());
    let report_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy compliance: flare ≤ 100 bpm AND pressure ≤ 1 440 psi (EPA-ish)
    let decision = if report.flare_rate_bpm <= 100 && report.pressure_psi <= 1440 {
        Decision::Compliant
    } else {
        Decision::NonCompliant
    };

    let cert = Certificate {
        decision,
        well_hash: report.well_id,
        flare_rate: report.flare_rate_bpm,
        pressure: report.pressure_psi,
        nanos: report.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
