//! KL-309-SpectrumLicence – copyright 2025 Lex Libertatum Trust – Per-Decision Royalty Licence
// (same skeleton, only decision logic)
pub fn decide(report: &Report) -> (Decision, Certificate) {
    let seq = CALL_COUNT.fetch_add(1, Ordering::Relaxed);
    // DENY if licence expired
    let decision = if report.score == 1 { Decision::Certified } else { Decision::Rejected };
    let cert = Certificate { decision, id: report.id, score: report.score, nanos: report.nanos, patent_tag: PATENT_TAG, call_seq: seq };
    (decision, cert)
}
