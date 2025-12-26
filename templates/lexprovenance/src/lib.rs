#![no_std]
#![forbid(unsafe_code)]
//! LexProvenance kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x12\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Authenticated,
    Rejected,
}

pub struct ProvenanceCertificate {
    public artifact_id: [u8; 32],    // SHA-256 of internal artifact ID
    public sale_price_usd_cents: u64, // sale price in cents
    public provenance_score: u8,     // 0-100 (provenance confidence)
    public timestamp_nanos: u64,     // certificate time
    public metadata: Vec<u8>,        // UNESCO/CITES meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub artifact_id: [u8; 32],
    pub sale_price_usd_cents: u64,
    pub provenance_score: u8,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.artifact_id);
        hasher.update(self.sale_price_usd_cents.to_be_bytes());
        hasher.update([self.provenance_score]);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &ProvenanceCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.artifact_id);
    hasher.update(cert.sale_price_usd_cents.to_be_bytes());
    hasher.update([cert.provenance_score]);
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy UNESCO/CITES compliance: price ≥ $1 M OR provenance score ≥ 80
    let decision = if cert.sale_price_usd_cents >= 100_000_000 || cert.provenance_score >= 80 {
        Decision::Authenticated
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        artifact_id: cert.artifact_id,
        sale_price_usd_cents: cert.sale_price_usd_cents,
        provenance_score: cert.provenance_score,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
