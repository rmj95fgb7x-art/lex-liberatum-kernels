use clap::Parser;
use csv::Writer;
use serde::Serialize;
use std::fs::File;
use std::path::PathBuf;

mod lib;
use lib::{KernelDay, root_of};

#[derive(Parser)]
#[command(about = "KEX telemetry oracle – export daily kernel CSV")]
struct Args {
    /// Output CSV path
    #[arg(short, long)]
    out: PathBuf,
    /// Day number (Unix epoch days)
    #[arg(short, long)]
    day: u32,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();

    // TODO: replace with real on-chain scrape
    let mock = KernelDay {
        kernel: "lexwing".into(),
        day: args.day,
        decisions: 140_000,
        royalty_wei: 11_000_000_000_000_000_000, // 11 ETH @ 25 bp
        incidents: 2,
        uptime_bps: 9_995,
    };

    let mut wtr = Writer::from_path(args.out)?;
    wtr.serialize(&mock)?;
    wtr.flush()?;

    println!("CSV written. Merkle-root: {:x?}", root_of(&[mock]));
    Ok(())
}
