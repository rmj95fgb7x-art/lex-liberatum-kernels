#![no_std]
#![forbid(unsafe_code)]
//! Meta-Lex kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x00\x07"; // claims 0-7 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Allow,
    Deny,
}

pub struct Action {
    pub nanos: u64,
    pub rule_hash: [u8; 32], // DAG block hash active at that nanosecond
    pub payload: Vec<u8>,    // opaque business payload
}

pub struct Certificate {
    pub decision: Decision,
    pub rule_hash: [u8; 32],
    pub payload_hash: [u8; 32],
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    /// 256-bit hash of the certificate (what gets anchored)
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.rule_hash);
        hasher.update(&self.payload_hash);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(action: &Action) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the payload with the active rule block
    let mut hasher = Sha3_256::new();
    hasher.update(&action.payload);
    hasher.update(&action.rule_hash);
    let payload_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy compliance check (replace with real rule)
    let decision = if action.payload.len() >= 4 && &action.payload[..4] == b"\xDE\xAD\xBE\xEF" {
        Decision::Allow
    } else {
        Decision::Deny
    };

    let cert = Certificate {
        decision,
        rule_hash: action.rule_hash,
        payload_hash,
        nanos: action.nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
