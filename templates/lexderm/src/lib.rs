#![no_std]
#![forbid(unsafe_code)]
//! LexDerm kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x07\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Rejected,
}

pub struct CosmeticNotice {
    public product_id: [u8; 32],     // SHA-256 of internal SKU
    public ingredient_count: u8,     // number of INCI ingredients
    public contains_fragrance: bool, // fragrance flag
    public timestamp_nanos: u64,     // submission time
    public metadata: Vec<u8>,        // FDA/EU meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub product_id: [u8; 32],
    pub ingredient_count: u8,
    pub contains_fragrance: bool,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.product_id);
        hasher.update([self.ingredient_count]);
        hasher.update([self.contains_fragrance as u8]);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(notice: &CosmeticNotice) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the notice blob
    let mut hasher = Sha3_256::new();
    hasher.update(&notice.product_id);
    hasher.update([notice.ingredient_count]);
    hasher.update([notice.contains_fragrance as u8]);
    let notice_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy FDA/EU compliance: ≤ 30 ingredients AND fragrance flagged
    let decision = if notice.ingredient_count <= 30 && notice.contains_fragrance {
        Decision::Approved
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        product_id: notice.product_id,
        ingredient_count: notice.ingredient_count,
        contains_fragrance: notice.contains_fragrance,
        nanos: notice.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
