//! KL-208-LotNumber – copyright 2025 Lex Libertatum Trust – Per-Decision Royalty Licence
// (same body, only decision logic)
pub fn decide(report: &Report) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);
    // DENY if recalled lot
    let decision = if report.score == 0 { Decision::Certified } else { Decision::Rejected };
    let cert = Certificate { decision, id: report.id, score: report.score, nanos: report.nanos, patent_tag: PATENT_TAG, call_seq: seq };
    (decision, cert)
}
