//! Deterministic LRU cache for air-gapped or ultra-low-latency mode.
#![cfg(feature = "air-gap")]

use crate::{Report, Certificate};
use alloc::collections::BTreeMap;

const CACHE_CAP: usize = 8_192;
static mut CACHE: Option<BTreeMap<[u8; 32], Certificate>> = None;

/// Read-only cache hit (no royalty increment).
pub fn cached_decide(report: &Report) -> Option<Certificate> {
    unsafe { CACHE.get_or_insert_with(BTreeMap::new).get(&report.id).cloned() }
}

/// Insert after real decide() (royalty already counted).
pub fn cache_insert(cert: Certificate) {
    unsafe {
        let c = CACHE.get_or_insert_with(BTreeMap::new);
        if c.len() == CACHE_CAP { c.pop_first(); }
        c.insert(cert.id, cert);
    }
}
