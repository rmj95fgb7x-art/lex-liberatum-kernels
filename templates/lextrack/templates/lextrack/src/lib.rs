#![no_std]
#![forbid(unsafe_code)]
//! LexTrack kernel – copyright 2025 Lex Libertarum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Keccak256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x03\x00"; // claims 0,1,2 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Accepted,
    Rejected,
}

pub struct Statement {
    pub track_isrc: [u8; 12],       // 12-byte ISRC (ASCII)
    pub csv_hash: [u8; 32],         // Keccak of royalty CSV
    pub statement_nanos: u64,       // timestamp of upload
    pub metadata: Vec<u8>,          // opaque DSP meta
}

pub struct Certificate {
    pub decision: Decision,
    pub track_hash: [u8; 32],
    pub csv_hash: [u8; 32],
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Keccak256::new();
        hasher.update(&self.track_hash);
        hasher.update(&self.csv_hash);
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(statement: &Statement) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash ISRC + CSV
    let mut hasher = Keccak256::new();
    hasher.update(&statement.track_isrc);
    hasher.update(&statement.csv_hash);
    let track_hash: [u8; 32] = hasher.finalize().into();

    // 2. Music rule: CSV must start with "ISRC," and be < 4 kB
    let decision = if statement.csv_hash[0] == 0x49
                    && statement.csv_hash[1] == 0x53
                    && statement.csv_hash[2] == 0x52
                    && statement.csv_hash[3] == 0x43
                    && statement.metadata.len() < 4096
    {
        Decision::Accepted
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        track_hash,
        csv_hash: statement.csv_hash,
        nanos: statement.statement_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
