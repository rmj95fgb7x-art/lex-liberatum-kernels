#![no_std]
#![forbid(unsafe_code)]
//! KL-039-AML-Oracle – copyright 2025 Lex Libertatum Trust – Per-Decision Royalty Licence
extern crate alloc;
use alloc::vec::Vec;
use core::convert::TryInto;
use sha2::{Digest, Sha256};   // add sha2 = { version = "0.10", default-features = false } in Cargo.toml

pub struct Action { pub payload: Vec<u8>, }
pub enum Decision { Allow, Deny }

/// Oracle public key (compressed secp256k1) – replace with real key
const ORACLE_PK: &[u8] = b"\x02\x8b\x9c\xc9...";

/// Expected JSON prefix version byte (first byte of blob)
const VERSION: u8 = 0x01;

/// Decision byte positions (fixed-offset for speed)
const DECISION_BYTE: usize = 65;   // last byte before signature
const EXPIRY_OFFSET: usize = 57;   // 4-byte big-endian expiry
const NONCE_OFFSET:  usize = 49;   // 8-byte nonce

pub fn decide(action: &Action) -> (Decision, &'static str) {
    // 1. length check
    if action.payload.len() < 85 { return (Decision::Deny, "payload_short"); }
    
    // 2. split signature (last 65 bytes)
    let (blob, sig) = action.payload.split_at(action.payload.len() - 65);
    
    // 3. verify signature over keccak256(blob)
    let hash = Sha256::digest(blob);          // or keccak256 if you prefer
    if !ecrecover_verify(&hash, sig, ORACLE_PK) { return (Decision::Deny, "sig_invalid"); }
    
    // 4. version byte
    if blob[0] != VERSION { return (Decision::Deny, "version_mismatch"); }
    
    // 5. expiry check (seconds since unix epoch)
    let expiry = u32::from_be_bytes(blob[EXPIRY_OFFSET..EXPIRY_OFFSET+4].try_into().unwrap_or_default());
    if expiry < now_seconds() { return (Decision::Deny, "expired"); }
    
    // 6. decision byte ('A' = Allow, 'D' = Deny)
    match blob[DECISION_BYTE] {
        b'A' => (Decision::Allow, "oracle_signed_allow"),
        b'D' => (Decision::Deny,  "oracle_signed_deny"),
        _    => (Decision::Deny,  "oracle_unknown_code"),
    }
}

// ---------- crypto helpers ----------
fn ecrecover_verify(hash: &[u8; 32], sig: &[u8], pk: &[u8]) -> bool {
    // real impl: libsecp256k1::verify(hash, sig, pk)
    // stub for compile test
    sig.len() == 65 && pk.len() == 33
}

fn now_seconds() -> u32 {
    // stub – replace with block.timestamp in Solidity or external oracle timestamp
    1_704_067_200
}
