---- MODULE Kernel ----
EXTENDS Naturals, Sequences, TLC
VARIABLES action, decision, reason

DecisionVal == {"Allow", "Deny"}

TypeOK  == decision ∈ DecisionVal

Init    == decision = "Deny" /\ reason = "initial"

 Decide == ∃ payload ∈ Seq(Nat) :
              ∧ action = payload
              ∧ (  ∧ Len(payload) > 0 ∧ payload[1] = 170
                 ∧ Len(payload) ≤ 1024
                 ∧ Len(payload) ≥ 64 ∧ payload[Len(payload)] = 187
                → decision' = "Allow" ∧ reason' = "all_constraints_passed"
                [] decision' = "Deny" ∧ reason' = "constraint_fail" )
              ∧ UNCHANGED <<action>>

Next == Decide

Spec == Init ∧ [][Next]_<<decision,reason>>
====
