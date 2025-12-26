Require Import Bool.
Parameter Action : Type.
Parameter Certificate : Type.
Parameter decide : Action -> (bool * Certificate).
Theorem decide_det : forall a b1 b2 c1 c2,
  decide a = (b1, c1) -> decide a = (b2, c2) -> b1 = b2 /\ c1 = c2.
Proof. intros; congruence. Qed.
