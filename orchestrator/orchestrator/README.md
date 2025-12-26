# orchestrator  
Mobile-first CLI to mint new Lex kernels in 5 s.

## one-time install (phone)
1. Install Rust:  
   iOS ➜ App Store → “a-Shell” (Rust pre-built).  
   Android ➜ F-Droid → “Termux”, then `pkg install rust`.
2. Clone repo:  
   `git clone https://github.com/rmj95fgb7x-art/lex-liberatum-kernels`
3. `cd lex-liberatum-kernels/orchestrator && cargo build --release`

## mint a kernel
```bash
cargo run
# type: aviation
# → templates/lexaviation/src/lib.rs created

