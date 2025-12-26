#![no_std]
#![forbid(unsafe_code)]
//! LexCrop kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x0B\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Rejected,
}

pub struct CoaCertificate {
    public batch_id: [u8; 32],       // SHA-256 of harvest batch ID
    public thc_percent: u8,          // THC % × 100 (e.g., 27 = 27 %)
    public cbd_percent: u8,          // CBD % × 100
    public timestamp_nanos: u64,     // lab test time
    public metadata: Vec<u8>,        // USDA/state meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub batch_id: [u8; 32],
    pub thc_percent: u8,
    pub cbd_percent: u8,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.batch_id);
        hasher.update([self.thc_percent]);
        hasher.update([self.cbd_percent]);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(coa: &CoaCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the COA blob
    let mut hasher = Sha3_256::new();
    hasher.update(&coa.batch_id);
    hasher.update([coa.thc_percent]);
    hasher.update([coa.cbd_percent]);
    let coa_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy USDA/state compliance: THC ≤ 0.3 % (hemp) OR THC ≤ 30 % (cannabis)
    let decision = if coa.thc_percent <= 30 {
        Decision::Approved
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        batch_id: coa.batch_id,
        thc_percent: coa.thc_percent,
        cbd_percent: coa.cbd_percent,
        nanos: coa.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
