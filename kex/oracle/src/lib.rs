//! KEX telemetry oracle – reads on-chain kernel counters and pushes daily CSV
#![no_std]
#![forbid(unsafe_code)]
extern crate alloc;
use alloc::string::String;
use alloc::vec::Vec;
use sha3::{Digest, Sha3_256};

/// Stats emitted by every kernel
pub struct KernelDay {
    pub kernel: String,        // e.g. "lexwing"
    pub day: u32,              // unix day number
    pub decisions: u64,
    pub royalty_wei: u64,      // 25 bp already converted to wei
    pub incidents: u16,        // regulator flagged
    pub uptime_bps: u16,       // basis points (0-10_000)
}

/// Merkle-root of daily batch for on-chain anchor
pub fn root_of(days: &[KernelDay]) -> [u8; 32] {
    let mut h = Sha3_256::new();
    for d in days {
        h.update(d.kernel.as_bytes());
        h.update(&d.day.to_be_bytes());
        h.update(&d.decisions.to_be_bytes());
        h.update(&d.royalty_wei.to_be_bytes());
        h.update(&d.incidents.to_be_bytes());
        h.update(&d.uptime_bps.to_be_bytes());
    }
    h.finalize().into()
}
