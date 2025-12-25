#![no_std]
#![forbid(unsafe_code)]
//! LexDocket kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x02\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Accepted,
    Rejected,
}

pub struct Filing {
    pub case_number: [u8; 32],      // SHA-256 of case ID
    pub pdf_hash: [u8; 32],         // SHA-256 of PDF blob
    pub filing_nanos: u64,          // e-filing timestamp
    pub metadata: Vec<u8>,          // opaque court meta
}

pub struct Certificate {
    pub decision: Decision,
    pub case_hash: [u8; 32],
    pub pdf_hash: [u8; 32],
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.case_hash);
        hasher.update(&self.pdf_hash);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(filing: &Filing) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash PDF + case number
    let mut hasher = Sha3_256::new();
    hasher.update(&filing.pdf_hash);
    hasher.update(&filing.case_number);
    let pdf_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy compliance: PDF must start with 0x25504446 (PDF magic)
    let decision = if filing.pdf_hash[0] == 0x25 && filing.pdf_hash[1] == 0x50 && filing.pdf_hash[2] == 0x44 && filing.pdf_hash[3] == 0x46 {
        Decision::Accepted
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        case_hash: filing.case_number,
        pdf_hash,
        nanos: filing.filing_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
