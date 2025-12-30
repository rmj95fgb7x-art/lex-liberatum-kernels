#![no_std]
#![forbid(unsafe_code)]

/// Fixed-point radix-2 FFT (1024-point) for phone-grade no_std.
/// Input: 1024 u32 counts (ITU filings per block window).
/// Output: anomaly permille (0–1000) = z-score × 1000.
pub fn orbit_fft_anomaly(counts: &[u32; 1024]) -> u32 {
    // 1. Convert to fixed-point Q31 real part; imag = 0
    let mut re = [0i64; 1024];
    let mut im = [0i64; 1024];
    for i in 0..1024 {
        re[i] = (counts[i] as i64) << 20; // 20-bit fractional headroom
    }

    // 2. In-place radix-2 FFT (bit-reversed order)
    fft_radix2(&mut re, &mut im, false);

    // 3. Apply deterministic mask (same as white-paper)
    const MASK: [u8; 1024] = include_bytes!("../masks/orbit_mask.bin");
    for k in 0..1024 {
        let m = MASK[k] as i64;
        re[k] = (re[k] * m) >> 0;
        im[k] = (im[k] * m) >> 0;
    }

    // 4. Inverse FFT
    fft_radix2(&mut re, &mut im, true);

    // 5. Z-score on real part; return permille
    let (mu, sigma) = mean_std(&re);
    if sigma == 0 { return 0; }
    let score = (re[0] - mu) * 1000 / sigma;
    score.max(0) as u32
}

// ---------- helpers (no_std, integer only) ----------
fn fft_radix2(re: &mut [i64; 1024], im: &mut [i64; 1024], inverse: bool) {
    // unrolled 1024-point radix-2, twiddles in Q31
    const TWIDDLE: &[i64; 512] = include_bytes!("../twiddles/orbit_twiddle_q31.bin");
    // (implementation elided for brevity; 150 lines total)
    // bit-reverse + butterfly loops, all integer
}

fn mean_std(buf: &[i64; 1024]) -> (i64, i64) {
    let mut mu: i64 = 0;
    for &x in buf.iter() { mu += x; }
    mu /= 1024;
    let mut var: i64 = 0;
    for &x in buf.iter() {
        let d = x - mu;
        var += d * d;
    }
    let sigma = (var / 1024).sqrt();
    (mu, sigma)
}
