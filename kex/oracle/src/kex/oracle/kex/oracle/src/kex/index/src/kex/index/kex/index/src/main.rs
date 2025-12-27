use kex_index::lib::{calc, KernelInput};

fn main() {
    let input = vec![
        KernelInput { name: "lexwing",  decisions: 140_000, royalty_wei: 11_000_000_000_000_000_000, incidents: 2, uptime_bps: 9995 },
        KernelInput { name: "lexcrop",  decisions: 130_000, royalty_wei: 10_000_000_000_000_000_000, incidents: 1, uptime_bps: 9990 },
    ];

    let snaps = calc(&input);
    for (i, s) in snaps.iter().enumerate() {
        println!("{}: fee={}bp vol={}bp eq={}bp", input[i].name, s.fee_weight, s.vol_weight, s.eq_weight);
    }
}
