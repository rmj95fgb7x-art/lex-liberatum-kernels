//! KL-139-WellPressureLimit – copyright 2025 Lex Libertatum Trust – Per-Decision Royalty Licence
// (same body as kl-074, only decision logic changes)
pub fn decide(report: &Report) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);
    // DENY if annular pressure > 80 % MAASP
    let decision = if report.score <= 80 { Decision::Certified } else { Decision::Rejected };
    let cert = Certificate { decision, id: report.id, score: report.score, nanos: report.nanos, patent_tag: PATENT_TAG, call_seq: seq };
    (decision, cert)
}
