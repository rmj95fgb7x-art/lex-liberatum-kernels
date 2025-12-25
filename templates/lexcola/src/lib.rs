#![no_std]
#![forbid(unsafe_code)]
//! LexCola kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x06\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Approved,
    Rejected,
}

pub struct ColaApplication {
    public cola_id: [u8; 32],        // SHA-256 of TTB application ID
    public alcohol_percent: u8,      // ABV integer (0-100)
    public volume_ml: u32,           // bottle volume (mL)
    public timestamp_nanos: u64,     // submission time
    public metadata: Vec<u8>,        // TTB meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub cola_id: [u8; 32],
    pub alcohol_percent: u8,
    pub volume_ml: u32,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.cola_id);
        hasher.update([self.alcohol_percent]);
        hasher.update(self.volume_ml.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(app: &ColaApplication) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the application blob
    let mut hasher = Sha3_256::new();
    hasher.update(&app.cola_id);
    hasher.update([app.alcohol_percent]);
    hasher.update(app.volume_ml.to_be_bytes());
    let app_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy TTB compliance: ABV ≤ 70 % AND volume ≤ 3 L
    let decision = if app.alcohol_percent <= 70 && app.volume_ml <= 3_000 {
        Decision::Approved
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        cola_id: app.cola_id,
        alcohol_percent: app.alcohol_percent,
        volume_ml: app.volume_ml,
        nanos: app.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
