||| Policy DSL plus runtime protocol derivation for payment flows.
module PaymentRules

import PaymentSessionTypes
import PaymentDomain

%default covering

-- ─── Policy DSL ───────────────────────────────────────────────────────────────

public export
data PaymentPolicyF : Type -> Type where
  AllowRefund         : a -> PaymentPolicyF a
  Require3DS          : a -> PaymentPolicyF a
  RequireManualReview : a -> PaymentPolicyF a
  CaptureWithinHours  : Nat -> a -> PaymentPolicyF a
  AppendAudit         : a -> PaymentPolicyF a
  Both                : a -> a -> PaymentPolicyF a
  PolicyDone          : PaymentPolicyF a

public export
Functor PaymentPolicyF where
  map f (AllowRefund a) = AllowRefund (f a)
  map f (Require3DS a) = Require3DS (f a)
  map f (RequireManualReview a) = RequireManualReview (f a)
  map f (CaptureWithinHours h a) = CaptureWithinHours h (f a)
  map f (AppendAudit a) = AppendAudit (f a)
  map f (Both l r) = Both (f l) (f r)
  map _ PolicyDone = PolicyDone

public export
data Fix : (Type -> Type) -> Type where
  In : f (Fix f) -> Fix f

public export
Policy : Type
Policy = Fix PaymentPolicyF

public export
interpret : Functor f => (f a -> a) -> Fix f -> a
interpret alg (In layer) = alg (map (interpret alg) layer)

public export
allowRefund : Policy -> Policy
allowRefund = In . AllowRefund

public export
require3DS : Policy -> Policy
require3DS = In . Require3DS

public export
requireManualReview : Policy -> Policy
requireManualReview = In . RequireManualReview

public export
captureWithinHours : Nat -> Policy -> Policy
captureWithinHours hours = In . CaptureWithinHours hours

public export
appendAudit : Policy -> Policy
appendAudit = In . AppendAudit

public export
both : Policy -> Policy -> Policy
both left right = In (Both left right)

public export
done : Policy
done = In PolicyDone

public export
record Analysis where
  constructor MkAnalysis
  refundPermitted      : Bool
  requires3DS          : Bool
  requiresManualReview : Bool
  captureWindowHours   : Nat
  auditRequired        : Bool

export
Show Analysis where
  show a =
    "Analysis(refund=" ++ show a.refundPermitted
      ++ ", 3ds=" ++ show a.requires3DS
      ++ ", manual=" ++ show a.requiresManualReview
      ++ ", window=" ++ show a.captureWindowHours ++ "h"
      ++ ", audit=" ++ show a.auditRequired ++ ")"

export
describe : Policy -> String
describe = interpret alg
  where
    alg : PaymentPolicyF String -> String
    alg (AllowRefund next) = "[Refundable] -> " ++ next
    alg (Require3DS next) = "[Require3DS] -> " ++ next
    alg (RequireManualReview next) = "[RequireManualReview] -> " ++ next
    alg (CaptureWithinHours hours next) = "[CaptureWithin " ++ show hours ++ "h] -> " ++ next
    alg (AppendAudit next) = "[AppendAudit] -> " ++ next
    alg (Both l r) = "(" ++ l ++ " AND " ++ r ++ ")"
    alg PolicyDone = "done"

private
strictestWindow : Nat -> Nat -> Nat
strictestWindow l r = min l r

export
analyze : Policy -> Analysis
analyze = interpret alg
  where
    alg : PaymentPolicyF Analysis -> Analysis
    alg (AllowRefund next) = { refundPermitted := True } next
    alg (Require3DS next) = { requires3DS := True } next
    alg (RequireManualReview next) = { requiresManualReview := True } next
    alg (CaptureWithinHours hours next) = { captureWindowHours := hours } next
    alg (AppendAudit next) = { auditRequired := True } next
    alg (Both l r) =
      MkAnalysis
        (l.refundPermitted && r.refundPermitted)
        (l.requires3DS || r.requires3DS)
        (l.requiresManualReview || r.requiresManualReview)
        (strictestWindow l.captureWindowHours r.captureWindowHours)
        (l.auditRequired || r.auditRequired)
    alg PolicyDone = MkAnalysis False False False 72 False

export
derivedRisk : Analysis -> RiskLevel
derivedRisk analysis =
  if analysis.requiresManualReview then HighRisk
  else if analysis.requires3DS then MediumRisk
  else LowRisk

-- ─── Runtime interpretations ──────────────────────────────────────────────────

export
policyFromOrder : Order n c -> Policy
policyFromOrder order =
  let base =
        appendAudit $
          captureWithinHours
            (case classifyRisk order of
               LowRisk => 24
               MediumRisk => 12
               HighRisk => 2)
            done

      withRefund =
        if supportsRefund order.paymentMethod
          then allowRefund base
          else base
  in case classifyRisk order of
       LowRisk => withRefund
       MediumRisk => require3DS withRefund
       HighRisk => both (requireManualReview withRefund) (require3DS withRefund)

export
riskSnapshotFor : Order n c -> RiskSnapshot
riskSnapshotFor order =
  let analysis = analyze (policyFromOrder order)
  in MkRiskSnapshot
       (derivedRisk analysis)
       (riskReason order)
       analysis.requires3DS
       analysis.requiresManualReview
       analysis.refundPermitted
       analysis.captureWindowHours

-- ─── Session shapes derived from runtime facts ───────────────────────────────

public export
postCapture : Bool -> Nat -> Currency -> SessionType
postCapture True n c = Choose (Receive (RefundedPayment n c) End) End
postCapture False _ _ = End

public export
commonSettlement : Bool -> Nat -> Currency -> SessionType
commonSettlement refundAllowed n c =
  Receive (AuthorizedPayment n c) $
  Receive (CapturedPayment n c) $
  postCapture refundAllowed n c

public export
lowRiskProtocol : (refundAllowed : Bool) -> (n : Nat) -> (c : Currency) -> SessionType
lowRiskProtocol refundAllowed n c =
  Send (Order n c) $
  Receive RiskSnapshot $
  commonSettlement refundAllowed n c

public export
mediumRiskProtocol : (refundAllowed : Bool) -> (n : Nat) -> (c : Currency) -> SessionType
mediumRiskProtocol refundAllowed n c =
  Send (Order n c) $
  Receive RiskSnapshot $
  Receive ThreeDSChallenge $
  Send ThreeDSProof $
  commonSettlement refundAllowed n c

public export
highRiskProtocol : (refundAllowed : Bool) -> (n : Nat) -> (c : Currency) -> SessionType
highRiskProtocol refundAllowed n c =
  Send (Order n c) $
  Receive RiskSnapshot $
  Receive ManualReviewRequest $
  Send ManualReviewApproval $
  commonSettlement refundAllowed n c

public export
protocolDerivedFrom : {n : Nat} -> {c : Currency} -> (order : Order n c) -> SessionType
protocolDerivedFrom {n} {c} order =
  let snapshot = riskSnapshotFor order
  in case snapshot.level of
       LowRisk => lowRiskProtocol snapshot.refundPermitted n c
       MediumRisk => mediumRiskProtocol snapshot.refundPermitted n c
       HighRisk => highRiskProtocol snapshot.refundPermitted n c

export
protocolLabelFor : Order n c -> String
protocolLabelFor order =
  let snapshot = riskSnapshotFor order
      refundLabel = if snapshot.refundPermitted then "refund-enabled" else "final-sale"
  in case snapshot.level of
       LowRisk => "low-risk fast path (" ++ refundLabel ++ ")"
       MediumRisk => "3DS challenge path (" ++ refundLabel ++ ")"
       HighRisk => "manual review path (" ++ refundLabel ++ ")"
