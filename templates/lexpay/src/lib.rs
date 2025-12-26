#![no_std]
#![forbid(unsafe_code)]
//! LexPay kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x08\x00"; // claims 0,1 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Filed,
    Rejected,
}

pub struct PaySlip {
    public employee_hash: [u8; 32],   // SHA-256 of employee ID
    public gross_usd_cents: u64,      // gross pay in cents
    public tax_usd_cents: u64,        // tax withheld in cents
    public timestamp_nanos: u64,      // pay-period end
    public metadata: Vec<u8>,         // IRS/HMRC meta blob
}

pub struct Certificate {
    pub decision: Decision,
    pub employee_hash: [u8; 32],
    pub gross_usd_cents: u64,
    pub tax_usd_cents: u64,
    pub nanos: u64,
    pub patent_tag: [u8; 6],
    pub call_seq: u64,
}

impl Certificate {
    pub fn hash(&self) -> [u8; 32] {
        let mut hasher = Sha3_256::new();
        hasher.update(&self.employee_hash);
        hasher.update(self.gross_usd_cents.to_be_bytes());
        hasher.update(self.tax_usd_cents.to_be_bytes());
        hasher.update(self.nanos.to_be_bytes());
        hasher.update(&(self.decision as u8).to_be_bytes());
        hasher.update(&self.patent_tag);
        hasher.update(self.call_seq.to_be_bytes());
        hasher.finalize().into()
    }
}

/// MAIN ENTRY POINT
pub fn decide(slip: &PaySlip) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // 1. Hash the slip blob
    let mut hasher = Sha3_256::new();
    hasher.update(&slip.employee_hash);
    hasher.update(slip.gross_usd_cents.to_be_bytes());
    hasher.update(slip.tax_usd_cents.to_be_bytes());
    let slip_hash: [u8; 32] = hasher.finalize().into();

    // 2. Dummy IRS/HMRC compliance: tax withheld ≥ 10 % of gross
    let decision = if slip.tax_usd_cents * 10 >= slip.gross_usd_cents {
        Decision::Filed
    } else {
        Decision::Rejected
    };

    let cert = Certificate {
        decision,
        employee_hash: slip.employee_hash,
        gross_usd_cents: slip.gross_usd_cents,
        tax_usd_cents: slip.tax_usd_cents,
        nanos: slip.timestamp_nanos,
        patent_tag: PATENT_TAG,
        call_seq: seq,
    };

    (decision, cert)
}
