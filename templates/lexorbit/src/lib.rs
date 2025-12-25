#![no_std]
#![forbid(unsafe_code)]
//! LexOrbit kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x05\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Filed,
    Rejected,
}

pub struct ManeuverLog {
    pub satellite_id: [u8; 32],   // SHA-256 of NORAD ID
    pub burn_duration_ms: u32,    // thruster on-time (ms)
    pub delta_v_mps: u32,         // delta-v (m/s)
    pub timestamp_nanos: u64,     // UTC burn time
    pub metadata: Vec<u8>,        // FCC meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub satellite_id: [u8; 32],
    pub burn_duration_ms: u32,
    pub delta_v_mps: u32,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.satellite_id);
        hasher.update(self.burn_duration_ms.to_be_bytes());
        hasher.update(self.delta_v_mps.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(log: &ManeuverLog) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the log blob
    let mut hasher = Sha3_256::new();
    hasher.update(&log.satellite_id);
    hasher.update(log.burn_duration_ms.to_be_bytes());
    hasher.update(log.delta_v_mps.to_be_bytes());
    let log_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy FCC compliance: burn ≤ 5 min AND delta-v ≤ 50 m/s
    let decision = if log.burn_duration_ms <= 300_000 && log.delta_v_mps <= 50 {
        Decision::Filed
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        satellite_id: log.satellite_id,
        burn_duration_ms: log.burn_duration_ms,
        delta_v_mps: log.delta_v_mps,
        nanos: log.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
