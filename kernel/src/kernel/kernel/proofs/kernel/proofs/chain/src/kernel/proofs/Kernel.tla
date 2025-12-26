---- MODULE Kernel ----
EXTENDS Reals, Naturals, TLC
CONSTANTS Principal, HourlyRate, MaxElapsed
VARIABLES balance, elapsed

DecisionVal == {"Allow", "Deny"}

TypeOK  == balance ∈ Real /\ elapsed ∈ 0..MaxElapsed
Init    == balance = Principal /\ elapsed = 0
Next    == elapsed < MaxElapsed
           /\ balance' = balance * (1 - HourlyRate)
           /\ elapsed' = elapsed + 1
Constraint == balance >= 0
=============================================================================
