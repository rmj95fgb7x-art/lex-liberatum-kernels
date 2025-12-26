#![no_std]
#![forbid(unsafe_code)]
//! LexCarbon kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x13\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Retired,
    Rejected,
}

pub struct CarbonRetirement {
    public credit_id: [u8; 32],      // SHA-256 of credit serial
    public tonnes_retired: u32,      // tonnes of CO2e
    public vintage_year: u16,        // vintage year
    public timestamp_nanos: u64,     // retirement time
    public metadata: Vec<u8>,        // Verra/Gold-Standard meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub credit_id: [u8; 32],
    pub tonnes_retired: u32,
    pub vintage_year: u16,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.credit_id);
        hasher.update(self.tonnes_retired.to_be_bytes());
        hasher.update(self.vintage_year.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &CarbonRetirement) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.credit_id);
    hasher.update(cert.tonnes_retired.to_be_bytes());
    hasher.update(cert.vintage_year.to_be_bytes());
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy Verra/EU ETS compliance: tonnes ≥ 1 000 OR vintage ≥ 2020
    let decision = if cert.tonnes_retired >= 1_000 || cert.vintage_year >= 2020 {
        Decision::Retired
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        credit_id: cert.credit_id,
        tonnes_retired: cert.tonnes_retired,
        vintage_year: cert.vintage_year,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
