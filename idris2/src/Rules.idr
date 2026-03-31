||| LAYER 3 — Policy DSL (Fix + HKT) and Protocol Derivation
|||
||| KEY ADVANCE: protocolDerivedFrom : (n : Nat) -> Policy -> SessionType
|||
||| In Scala the protocol variants are fixed at compile time and a
||| SelectedVariant enum bridges runtime analysis to compile-time types.
||| Here, protocolDerivedFrom IS the derivation — a total function, no seam, no enum.
module Rules

import SessionTypes
import Domain

%default covering   -- fold terminates on finite Fix trees; covering for clarity

-- ─── Base functor ─────────────────────────────────────────────────────────────

public export
data PolicyF : Type -> Type where
  Refundable    : a -> PolicyF a
  NonRefundable : a -> PolicyF a
  MinStay       : Nat -> a -> PolicyF a
  RequiresIdentification    : a -> PolicyF a
  Both          : a -> a -> PolicyF a
  NoConstraint  : PolicyF a

public export
Functor PolicyF where
  map f (Refundable a)    = Refundable (f a)
  map f (NonRefundable a) = NonRefundable (f a)
  map f (MinStay days a)  = MinStay days (f a)
  map f (RequiresIdentification a)    = RequiresIdentification (f a)
  map f (Both la ra)      = Both (f la) (f ra)
  map _ NoConstraint      = NoConstraint

-- ─── Fixpoint combinator ─────────────────────────────────────────────────────

public export
data Fix : (Type -> Type) -> Type where
  In : f (Fix f) -> Fix f

public export
Policy : Type
Policy = Fix PolicyF

||| Catamorphism: the single recursion operator shared by all interpretations.
||| None of the algebras below contain any recursion — this is the only place.
public export
interpret : Functor f => (f a -> a) -> Fix f -> a
interpret alg (In x) = alg (map (interpret alg) x)

-- ─── Smart constructors ───────────────────────────────────────────────────────

public export
refundable : Policy -> Policy
refundable = In . Refundable

public export
nonRefundable : Policy -> Policy
nonRefundable = In . NonRefundable

public export
minStay : Nat -> Policy -> Policy
minStay d = In . MinStay d

public export
requiresIdentification : Policy -> Policy
requiresIdentification = In . RequiresIdentification

public export
both : Policy -> Policy -> Policy
both l r = In (Both l r)

public export
noConstraint : Policy
noConstraint = In NoConstraint

-- ─── Interpretations ─────────────────────────────────────────────────────────

public export
describe : Policy -> String
describe = interpret alg
  where
    alg : PolicyF String -> String
    alg (Refundable next)    = "[Refundable] -> " ++ next
    alg (NonRefundable next) = "[Non-refundable] -> " ++ next
    alg (MinStay days next)  = "[MinStay " ++ show days ++ "d] -> " ++ next
    alg (RequiresIdentification next)    = "[RequiresIdentification] -> " ++ next
    alg (Both l r)            = "(" ++ l ++ "  AND  " ++ r ++ ")"
    alg NoConstraint                 = "done"

public export
permitsCancellation : Policy -> Bool
permitsCancellation = interpret alg
  where
    alg : PolicyF Bool -> Bool
    alg (Refundable _)    = True
    alg (NonRefundable _) = False
    alg (MinStay _ next)  = next
    alg (RequiresIdentification next) = next
    alg (Both l r)         = l && r
    alg NoConstraint              = True

public export
minimumNights : Policy -> Nat
minimumNights = interpret alg
  where
    alg : PolicyF Nat -> Nat
    alg (Refundable next)    = next
    alg (NonRefundable next) = next
    alg (MinStay days _)     = days
    alg (RequiresIdentification next)    = next
    alg (Both l r)            = max l r
    alg NoConstraint                 = 0

public export
identificationRequired : Policy -> Bool
identificationRequired = interpret alg
  where
    alg : PolicyF Bool -> Bool
    alg (Refundable next)          = next
    alg (NonRefundable next)       = next
    alg (MinStay _ next)           = next
    alg (RequiresIdentification _) = True
    alg (Both l r)                 = l || r
    alg NoConstraint               = False

public export
record Analysis where
  constructor MkAnalysis
  cancellationPermitted : Bool
  minimumStay           : Nat
  needsIdentification   : Bool

public export
Show Analysis where
  show a = "cancellationPermitted=" ++ show a.cancellationPermitted
        ++ "  minimumNights=" ++ show a.minimumStay ++ "d"
        ++ "  identificationRequired=" ++ show a.needsIdentification

public export
analyze : Policy -> Analysis
analyze = interpret alg
  where
    alg : PolicyF Analysis -> Analysis
    alg (Refundable a)             = { cancellationPermitted := True } a
    alg (NonRefundable a)          = { cancellationPermitted := False } a
    alg (MinStay d a)              = { minimumStay := d } a
    alg (RequiresIdentification a) = { needsIdentification := True } a
    alg (Both l r)                 = MkAnalysis (l.cancellationPermitted && r.cancellationPermitted)
                                                (max l.minimumStay r.minimumStay)
                                                (l.needsIdentification || r.needsIdentification)
    alg NoConstraint               = MkAnalysis True 0 False

-- ─── Protocol derivation ─────────────────────────────────────────────────────

||| Refundable protocol: search -> hold -> Choose(pay | cancel).
||| n is a runtime Nat — not a compile-time literal constraint.
public export
refundableProtocol : (n : Nat) -> SessionType
refundableProtocol n =
  Send SearchCriteria $
  Receive SearchResult $
  Send (Passengers n) $
  Receive (Quote n) $
  Receive HoldConfirmation $
  Choose
    (Send (PaymentFor n) (Receive (Tickets n) End))
    (Receive CancellationConfirmation End)

||| Non-refundable: no cancel branch.
public export
nonRefundableProtocol : (n : Nat) -> SessionType
nonRefundableProtocol n =
  Send SearchCriteria $
  Receive SearchResult $
  Send (Passengers n) $
  Receive (Quote n) $
  Receive HoldConfirmation $
  Send (PaymentFor n) (Receive (Tickets n) End)

||| Fast-path: no flights available.
public export
noAvailabilityProtocol : SessionType
noAvailabilityProtocol = Send SearchCriteria (Receive SearchResult End)

||| Derive the session type directly from a Policy and passenger count.
|||
||| KEY ADVANCE OVER SCALA:
|||   Scala:  fixed variant enum + runtime bridge (SelectedVariant)
|||   Idris:  this function IS the derivation — total, no seam, no enum
public export
protocolDerivedFrom : (n : Nat) -> Policy -> SessionType
protocolDerivedFrom n rule =
  if permitsCancellation rule
    then refundableProtocol n
    else nonRefundableProtocol n
