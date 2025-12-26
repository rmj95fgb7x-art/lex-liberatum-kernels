#![no_std]
#![forbid(unsafe_code)]
//! LexPolicy kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x10\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Filed,
    Rejected,
}

pub struct PolicyFiling {
    public policy_id: [u8; 32],      // SHA-256 of policy number
    public premium_usd_cents: u64,   // annual premium in cents
    public risk_score: u8,           // actuarial risk 0-255
    public timestamp_nanos: u64,     // filing time
    public metadata: Vec<u8>,        // NAIC/Solvency II meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub policy_id: [u8; 32],
    pub premium_usd_cents: u64,
    pub risk_score: u8,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.policy_id);
        hasher.update(self.premium_usd_cents.to_be_bytes());
        hasher.update([self.risk_score]);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(filing: &PolicyFiling) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the filing blob
    let mut hasher = Sha3_256::new();
    hasher.update(&filing.policy_id);
    hasher.update(filing.premium_usd_cents.to_be_bytes());
    hasher.update([filing.risk_score]);
    let filing_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy NAIC/Solvency II compliance: premium ≥ $1 M OR risk score ≤ 200
    let decision = if filing.premium_usd_cents >= 100_000_000 || filing.risk_score <= 200 {
        Decision::Filed
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        policy_id: filing.policy_id,
        premium_usd_cents: filing.premium_usd_cents,
        risk_score: filing.risk_score,
        nanos: filing.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
