//! KEX index family – fee-weighted, volume-weighted, equal-weighted
#![no_std]
#![forbid(unsafe_code)]
extern crate alloc;
use alloc::vec::Vec;

#[derive(Clone)]
pub struct KernelInput {
    pub name: &'static str,
    pub decisions: u64,
    pub royalty_wei: u64,
    pub incidents: u16,
    pub uptime_bps: u16,
}

pub struct IndexSnap {
    pub fee_weight: u32,   // basis points (sum = 10 000)
    pub vol_weight: u32,
    pub eq_weight: u32,
}

pub fn calc(weights: &[KernelInput]) -> Vec<IndexSnap> {
    let total_fees: u64 = weights.iter().map(|k| k.royalty_wei).sum();
    let total_vol: u64 = weights.iter().map(|k| k.decisions).sum();
    let n = weights.len() as u32;

    weights
        .iter()
        .map(|k| IndexSnap {
            fee_weight: ((k.royalty_wei * 10_000) / total_fees) as u32,
            vol_weight: ((k.decisions * 10_000) / total_vol) as u32,
            eq_weight: 10_000 / n,
        })
        .collect()
}
