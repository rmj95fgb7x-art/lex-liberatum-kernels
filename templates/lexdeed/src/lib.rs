#![no_std]
#![forbid(unsafe_code)]
//! LexDeed kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x11\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Recorded,
    Rejected,
}

pub struct DeedCertificate {
    public parcel_id: [u8; 32],      // SHA-256 of county parcel number
    public sale_price_usd_cents: u64, // sale price in cents
    public square_feet: u32,         // property size
    public timestamp_nanos: u64,     // recording time
    public metadata: Vec<u8>,        // county/FIRPTA meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub parcel_id: [u8; 32],
    pub sale_price_usd_cents: u64,
    pub square_feet: u32,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.parcel_id);
        hasher.update(self.sale_price_usd_cents.to_be_bytes());
        hasher.update(self.square_feet.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &DeedCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.parcel_id);
    hasher.update(cert.sale_price_usd_cents.to_be_bytes());
    hasher.update(cert.square_feet.to_be_bytes());
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy county/FIRPTA compliance: price ≥ $500 k OR sq-ft ≥ 2 000
    let decision = if cert.sale_price_usd_cents >= 50_000_000 || cert.square_feet >= 2_000 {
        Decision::Recorded
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        parcel_id: cert.parcel_id,
        sale_price_usd_cents: cert.sale_price_usd_cents,
        square_feet: cert.square_feet,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
