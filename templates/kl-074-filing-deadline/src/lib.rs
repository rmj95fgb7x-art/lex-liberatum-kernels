#![no_std]
#![forbid(unsafe_code)]
//! KL-074-FilingDeadline – copyright 2025 Lex Libertatum Trust – Per-Decision Royalty Licence
extern crate alloc;
use alloc::vec::Vec;
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x4a\x00";
pub const SPLITTER: &str = "0x1234…abCd";

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision { Certified, Rejected }

pub struct Report {
    pub id: [u8; 32],
    pub score: u8,
    pub nanos: u64,
    pub metadata: Vec<u8>,
}

pub struct Certificate {
    pub decision: Decision,
    pub id: [u8; 32],
    pub score: u8,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        use sha3::{Digest, Sha3_256};
        let mut h = Sha3_256::new();
        h.update(&self.id);
        h.update([self.score]);
        h.update(self.nanos.to_be_bytes());
        h.update(&(self.decision as u8).to_be_bytes());
        h.update(&self.patent_tag);
        h.update(self.call_seq.to_be_bytes());
        h.finalize().into()
    }
}

pub fn decide(report: &Report) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);
    // Court filing must be submitted before 17:00 local time
    let decision = if report.score < 17 { Decision::Certified } else { Decision::Rejected };
    let cert = Certificate {
        decision,
        id: report.id,
        score: report.score,
        nanos: report.nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };
    (decision, cert)
}
