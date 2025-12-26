#![no_std]
#![forbid(unsafe_code)]
//! LexTravel kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x0F\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Filed,
    Rejected,
}

pub struct TravelRuleFiling {
    public transfer_id: [u8; 32],    // SHA-256 of internal transfer ID
    public amount_usd_cents: u64,    // USD value in cents
    public originator_hash: [u8; 32], // SHA-256 of originator wallet
    public timestamp_nanos: u64,     // transfer time
    public metadata: Vec<u8>,        // FinCEN meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub transfer_id: [u8; 32],
    pub amount_usd_cents: u64,
    pub originator_hash: [u8; 32],
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.transfer_id);
        hasher.update(self.amount_usd_cents.to_be_bytes());
        hasher.update(&self.originator_hash);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(filing: &TravelRuleFiling) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the filing blob
    let mut hasher = Sha3_256::new();
    hasher.update(&filing.transfer_id);
    hasher.update(filing.amount_usd_cents.to_be_bytes());
    hasher.update(&filing.originator_hash);
    let filing_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy FinCEN compliance: amount ≥ $3 000 (Travel Rule threshold)
    let decision = if filing.amount_usd_cents >= 300_000 {
        Decision::Filed
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        transfer_id: filing.transfer_id,
        amount_usd_cents: filing.amount_usd_cents,
        originator_hash: filing.originator_hash,
        nanos: filing.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
