#![no_std]
#![forbid(unsafe_code)]
//! AIOX kernel – copyright 2025 Lex Libertatum Trust, A.T.W.W., Trustee
//! Per-Decision Royalty Licence (see LICENCE-RDR)

extern crate alloc;
use alloc::vec::Vec;
use core::sync::atomic::{AtomicU64, Ordering};

pub const LICENCE_RDR: &[u8] = b"Lex-Libertatum-Trust-RDR-2025-Per-Decision-Royalty";
pub const PATENT_TAG: [u8; 6] = *b"UPAT\x01\xFF"; // claims 0-7 enabled

static CALL_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub enum Decision {
    Allow,
    Deny,
}

pub struct Action {
    pub payload: Vec<u8>,
}

/// Returns (Decision, reason, royalty_sequence, patent_tag)
pub fn decide(action: &Action) -> (Decision, &'static str, u64, [u8; 6]) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);

    // Constraint 1: payload must start with 0xAA (trusted signature)
    if action.payload.first() != Some(&0xAA) {
        return (Decision::Deny, "bad_signature", seq, PATENT_TAG);
    }
    // Constraint 2: length must be ≤ 1 kB
    if action.payload.len() > 1024 {
        return (Decision::Deny, "payload_too_large", seq, PATENT_TAG);
    }
    // Constraint 3: multi-sig override (last 64 bytes = two Ed25519 signatures)
    //    Dummy: last byte must be 0xBB (stands for "valid multisig")
    if action.payload.last() != Some(&0xBB) {
        return (Decision::Deny, "multisig_fail", seq, PATENT_TAG);
    }
    // All constraints passed
    (Decision::Allow, "all_constraints_passed", seq, PATENT_TAG)
}
