||| Payment domain with refined inputs, indexed audit trails, and typestate.
module PaymentDomain

import Data.List
import Data.Vect

%default total

-- ─── Money and boundary validation ────────────────────────────────────────────

public export
data Currency = EUR | USD

export
currencyCode : Currency -> String
currencyCode EUR = "EUR"
currencyCode USD = "USD"

public export
record Money (c : Currency) where
  constructor MkMoney
  cents : Nat

export
zeroMoney : Money c
zeroMoney = MkMoney 0

export
plusMoney : Money c -> Money c -> Money c
plusMoney (MkMoney l) (MkMoney r) = MkMoney (l + r)

export
scaleMoney : Money c -> Nat -> Money c
scaleMoney (MkMoney cents) n = MkMoney (cents * n)

export
Show (Money c) where
  show (MkMoney cents) = show cents ++ "c"

public export
data Positive : Nat -> Type where
  ItIsPositive : Positive (S k)

public export
record PositiveNat where
  constructor MkPositiveNat
  value    : Nat
  positive : Positive value

export
validatePositiveNat : Nat -> Either String PositiveNat
validatePositiveNat 0 = Left "Expected a positive natural number"
validatePositiveNat (S k) = Right (MkPositiveNat (S k) ItIsPositive)

export
Show PositiveNat where
  show p = show p.value

public export
data PaymentMethod
  = Card String
  | Wallet String
  | Invoice String

export
paymentMethodLabel : PaymentMethod -> String
paymentMethodLabel (Card _) = "card"
paymentMethodLabel (Wallet _) = "wallet"
paymentMethodLabel (Invoice _) = "invoice"

export
supportsRefund : PaymentMethod -> Bool
supportsRefund (Invoice _) = False
supportsRefund _ = True

export
Show PaymentMethod where
  show method = "PaymentMethod(" ++ paymentMethodLabel method ++ ")"

public export
data RiskLevel = LowRisk | MediumRisk | HighRisk

export
riskLabel : RiskLevel -> String
riskLabel LowRisk = "low"
riskLabel MediumRisk = "medium"
riskLabel HighRisk = "high"

export
Show RiskLevel where
  show level = "Risk(" ++ riskLabel level ++ ")"

public export
record RiskSnapshot where
  constructor MkRiskSnapshot
  level                : RiskLevel
  reason               : String
  requires3DS          : Bool
  requiresManualReview : Bool
  refundPermitted      : Bool
  captureWindowHours   : Nat

export
Show RiskSnapshot where
  show snap =
    "RiskSnapshot(level=" ++ riskLabel snap.level
      ++ ", refund=" ++ show snap.refundPermitted
      ++ ", 3ds=" ++ show snap.requires3DS
      ++ ", manual=" ++ show snap.requiresManualReview
      ++ ", window=" ++ show snap.captureWindowHours ++ "h)"

public export
record ThreeDSChallenge where
  constructor MkThreeDSChallenge
  challengeId : String
  amountBand  : String

export
Show ThreeDSChallenge where
  show c = "ThreeDSChallenge(" ++ c.challengeId ++ ", " ++ c.amountBand ++ ")"

public export
record ThreeDSProof where
  constructor MkThreeDSProof
  challengeId    : String
  liabilityShift : Bool

export
Show ThreeDSProof where
  show p = "ThreeDSProof(" ++ p.challengeId ++ ", shift=" ++ show p.liabilityShift ++ ")"

public export
record ManualReviewRequest where
  constructor MkManualReviewRequest
  queue  : String
  reason : String

export
Show ManualReviewRequest where
  show req = "ManualReview(" ++ req.queue ++ ", " ++ req.reason ++ ")"

public export
record ManualReviewApproval where
  constructor MkManualReviewApproval
  reviewer : String
  note     : String

export
Show ManualReviewApproval where
  show approval = "ManualApproval(" ++ approval.reviewer ++ ")"

public export
record OrderLine (c : Currency) where
  constructor MkOrderLine
  sku       : String
  unitPrice : Money c
  quantity  : PositiveNat

export
lineTotal : OrderLine c -> Money c
lineTotal line = scaleMoney line.unitPrice line.quantity.value

export
mkOrderLine : String -> Money c -> Nat -> Either String (OrderLine c)
mkOrderLine sku unitPrice qty =
  case validatePositiveNat qty of
    Left err => Left err
    Right positiveQty => Right (MkOrderLine sku unitPrice positiveQty)

export
Show (OrderLine c) where
  show line =
    "OrderLine(" ++ line.sku
      ++ ", unit=" ++ show line.unitPrice
      ++ ", qty=" ++ show line.quantity.value
      ++ ", total=" ++ show (lineTotal line) ++ ")"

public export
interface Priced a c | a where
  amountOf : a -> Money c

export
Priced (OrderLine c) c where
  amountOf = lineTotal

export
sumAmounts : Priced a c => Vect n a -> Money c
sumAmounts [] = zeroMoney
sumAmounts (x :: xs) = plusMoney (amountOf x) (sumAmounts xs)

-- ─── Orders and runtime risk classification ──────────────────────────────────

public export
record Order (n : Nat) (c : Currency) where
  constructor MkOrder
  orderId       : String
  customerId    : String
  lines         : Vect n (OrderLine c)
  nonEmptyLines : Positive n
  paymentMethod : PaymentMethod

export
mkOrder : String -> String -> Vect n (OrderLine c) -> PaymentMethod -> Either String (Order n c)
mkOrder orderId customerId [] paymentMethod =
  Left "Order must contain at least one line"
mkOrder orderId customerId lines@(_ :: _) paymentMethod =
  Right (MkOrder orderId customerId lines ItIsPositive paymentMethod)

export
orderTotal : Order n c -> Money c
orderTotal order = sumAmounts order.lines

export
orderTotalCents : Order n c -> Nat
orderTotalCents order = (orderTotal order).cents

private
lteNat : Nat -> Nat -> Bool
lteNat l r =
  case isLTE l r of
    Yes _ => True
    No _ => False

export
classifyRisk : Order n c -> RiskLevel
classifyRisk order =
  let amt = orderTotalCents order
  in case order.paymentMethod of
       Invoice _ => HighRisk
       Wallet _ =>
         if lteNat amt 20000 then LowRisk else MediumRisk
       Card _ =>
         if lteNat amt 15000 then LowRisk
         else if lteNat amt 80000 then MediumRisk
         else HighRisk

export
riskReason : Order n c -> String
riskReason order =
  let amtStr = show (orderTotal order)
  in case classifyRisk order of
       LowRisk => "small order total " ++ amtStr ++ " via " ++ paymentMethodLabel order.paymentMethod
       MediumRisk => "higher order total " ++ amtStr ++ " requires customer challenge"
       HighRisk => "high-value or invoice flow " ++ amtStr ++ " requires manual review"

-- ─── Runtime assessment and approval evidence ────────────────────────────────

public export
record Assessment (lvl : RiskLevel) (n : Nat) (c : Currency) where
  constructor MkAssessment
  order  : Order n c
  reason : String

export
assessOrder : Order n c -> (lvl : RiskLevel ** Assessment lvl n c)
assessOrder order =
  let why = riskReason order
  in case classifyRisk order of
       LowRisk => (LowRisk ** MkAssessment order why)
       MediumRisk => (MediumRisk ** MkAssessment order why)
       HighRisk => (HighRisk ** MkAssessment order why)

public export
data Approval : RiskLevel -> Type where
  AutoApproved    : Approval LowRisk
  ThreeDSApproved : ThreeDSProof -> Approval MediumRisk
  ReviewerApproved : ManualReviewApproval -> Approval HighRisk

export
approvalSummary : {lvl : RiskLevel} -> Approval lvl -> String
approvalSummary AutoApproved = "auto-approved"
approvalSummary (ThreeDSApproved p) =
  "3ds-proof:" ++ p.challengeId ++ " shift=" ++ show p.liabilityShift
approvalSummary (ReviewerApproved a) =
  "reviewer=" ++ a.reviewer ++ " note=" ++ a.note

-- ─── Typestate and indexed audit trail ───────────────────────────────────────

public export
data PaymentState = Initiated | Authorized | Captured | Refunded

public export
data AuditTrail : PaymentState -> Currency -> Nat -> Type where
  Started       : (orderId : String) -> AuditTrail Initiated c amount
  AuthorizedEvt : (entry : String) -> AuditTrail Initiated c amount -> AuditTrail Authorized c amount
  CapturedEvt   : (entry : String) -> AuditTrail Authorized c amount -> AuditTrail Captured c amount
  RefundedEvt   : (entry : String) -> AuditTrail Captured c amount -> AuditTrail Refunded c amount

export
auditEntries : AuditTrail state c amount -> List String
auditEntries (Started orderId) = ["started:" ++ orderId]
auditEntries (AuthorizedEvt entry prev) = auditEntries prev ++ ["authorized:" ++ entry]
auditEntries (CapturedEvt entry prev) = auditEntries prev ++ ["captured:" ++ entry]
auditEntries (RefundedEvt entry prev) = auditEntries prev ++ ["refunded:" ++ entry]

public export
data AuthorizedPayment : Nat -> Currency -> Type where
  MkAuthorizedPayment :
       (order : Order n c)
    -> (authCode : String)
    -> AuditTrail Authorized c (orderTotalCents order)
    -> AuthorizedPayment n c

public export
data CapturedPayment : Nat -> Currency -> Type where
  MkCapturedPayment :
       (order : Order n c)
    -> (captureId : String)
    -> AuditTrail Captured c (orderTotalCents order)
    -> CapturedPayment n c

public export
data RefundedPayment : Nat -> Currency -> Type where
  MkRefundedPayment :
       (order : Order n c)
    -> (refundId : String)
    -> AuditTrail Refunded c (orderTotalCents order)
    -> RefundedPayment n c

export
authorizedOrder : AuthorizedPayment n c -> Order n c
authorizedOrder (MkAuthorizedPayment order _ _) = order

export
capturedOrder : CapturedPayment n c -> Order n c
capturedOrder (MkCapturedPayment order _ _) = order

export
authorize : {lvl : RiskLevel} -> Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c
authorize assessment approval =
  let order = assessment.order
      trail = AuthorizedEvt (approvalSummary approval) (Started order.orderId)
  in MkAuthorizedPayment order ("auth-" ++ order.orderId) trail

export
capture : AuthorizedPayment n c -> CapturedPayment n c
capture (MkAuthorizedPayment order _ trail) =
  MkCapturedPayment order ("cap-" ++ order.orderId) (CapturedEvt "funds-captured" trail)

export
refund : CapturedPayment n c -> RefundedPayment n c
refund (MkCapturedPayment order _ trail) =
  MkRefundedPayment order ("refund-" ++ order.orderId) (RefundedEvt "customer-requested-refund" trail)

export
Show (AuthorizedPayment n c) where
  show (MkAuthorizedPayment order authCode trail) =
    "AuthorizedPayment(order=" ++ order.orderId
      ++ ", total=" ++ show (orderTotal order)
      ++ ", auth=" ++ authCode
      ++ ", audit=" ++ show (auditEntries trail) ++ ")"

export
Show (CapturedPayment n c) where
  show (MkCapturedPayment order captureId trail) =
    "CapturedPayment(order=" ++ order.orderId
      ++ ", total=" ++ show (orderTotal order)
      ++ ", capture=" ++ captureId
      ++ ", audit=" ++ show (auditEntries trail) ++ ")"

export
Show (RefundedPayment n c) where
  show (MkRefundedPayment order refundId trail) =
    "RefundedPayment(order=" ++ order.orderId
      ++ ", total=" ++ show (orderTotal order)
      ++ ", refund=" ++ refundId
      ++ ", audit=" ++ show (auditEntries trail) ++ ")"

export
Show (Order n c) where
  show order =
    "Order(" ++ order.orderId
      ++ ", lines=" ++ show (toList order.lines)
      ++ ", total=" ++ show (orderTotal order)
      ++ ", method=" ++ paymentMethodLabel order.paymentMethod ++ ")"
