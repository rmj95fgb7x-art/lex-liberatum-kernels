#!/usr/bin/env bash
# GitHub Codespaces / web shell compatible
set -e
echo "Minting kernels 034 → 1000 …"
for id in {034..1000}; do
  name=$(printf "kl-%03d" $id)
  cargo new --lib --name "$name" "kernels/$name"
  # copy placeholder lib.rs (we’ll generate it next)
  cat > "kernels/$name/src/lib.rs" << 'EOF'
#![no_std]
#![forbid(unsafe_code)]
//! Kernel KL-XXX – copyright 2025 Lex Libertatum Trust – Per-Decision Royalty Licence
extern crate alloc;
use alloc::vec::Vec;
pub struct Action { pub payload: Vec<u8>, }
pub enum Decision { Allow, Deny }
pub fn decide(_action: &Action) -> (Decision, &'static str) { (Decision::Allow, "stub") }
EOF
done
echo "✅ 1,000 kernel crates ready – upload the kernels/ folder to repo"
