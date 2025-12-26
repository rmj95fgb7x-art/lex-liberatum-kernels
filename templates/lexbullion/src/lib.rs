#![no_std]
#![forbid(unsafe_code)]
//! LexBullion kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x0A\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Certified,
    Rejected,
}

pub struct AssayCertificate {
    public bar_id: [u8; 32],         // SHA-256 of serial number
    public purity_ppm: u32,          // purity in parts-per-million (e.g., 999 000 for 99.9 %)
    public weight_g: u32,            // weight in grams
    public timestamp_nanos: u64,     // assay time
    public metadata: Vec<u8>,        // LBMA/FTC meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub bar_id: [u8; 32],
    pub purity_ppm: u32,
    pub weight_g: u32,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.bar_id);
        hasher.update(self.purity_ppm.to_be_bytes());
        hasher.update(self.weight_g.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(cert: &AssayCertificate) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the certificate blob
    let mut hasher = Sha3_256::new();
    hasher.update(&cert.bar_id);
    hasher.update(cert.purity_ppm.to_be_bytes());
    hasher.update(cert.weight_g.to_be_bytes());
    let cert_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy LBMA/FTC compliance: purity ≥ 995 000 ppm AND weight ≥ 350 g (Good Delivery bar)
    let decision = if cert.purity_ppm >= 995_000 && cert.weight_g >= 350 {
        Decision::Certified
    } else {
        Decision::Rejected
    };

    let new_cert = Certificate {
        decision,
        bar_id: cert.bar_id,
        purity_ppm: cert.purity_ppm,
        weight_g: cert.weight_g,
        nanos: cert.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, new_cert)
}
