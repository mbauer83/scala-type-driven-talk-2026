-- ─── Stage 07: Idris 2 — dependent types, first-class session values ──────────
-- Run: idris2 --build payment.ipkg && ./build/exec/paymentdemo
--
-- Lambda-cube position: λC — Calculus of Constructions (all three axes).
-- Proof-theoretic gain: Π-types — return type depends on runtime input value;
-- Σ-types — dependent witness pairs (risk level + proof); runtime-to-type bridge eliminated.
-- protocolDerivedFrom : Order -> SessionType IS a Π-type, running at compile time.
--
-- Linearity addition (this stage): the channel API uses Idris 2's
-- Quantitative Type Theory multiplicities. Every `Session p` argument is
-- bound at multiplicity 1; the linearity checker rejects programs that drop
-- a session without consuming it via `finish` (or by chaining it through
-- another protocol step). "Drop a channel without closing it" is no longer
-- expressible — closing the gap that the Scala 3 stage was honest about.
--
-- ELIMINATED — compiler now proves these; their runtime tests can be deleted:
--
--   ✗ Separate bridge ADT (ProtocolVariant) needed to connect risk level → protocol type  [was stage 06]
--       Main.idr             openSession receives a SessionType value computed from the Order
--       PaymentSessionTypes.idr:7  data SessionType : Type — session types are first-class values
--       In Scala a closed ProtocolVariant enum bridges runtime risk to a compile-time type alias.
--       In Idris the protocol IS the value passed to openSession; no bridge ADT is needed.
--       removes tests: "protocol variant matches assessed risk level"
--
--   ✗ Assessment level can mismatch the approval type  [was stage 06]
--       PaymentDomain.idr      assessOrder : Order n c -> (lvl : RiskLevel ** Assessment lvl n c)
--       PaymentDomain.idr      data Approval : RiskLevel -> Type — indexed by RiskLevel
--       PaymentDomain.idr      authorize : Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c
--       AutoApproved : Approval LowRisk cannot unify with Approval MediumRisk — type error.
--       removes tests: "assessment level matches approval constructor"
--
--   ✗ Channel dropped before protocol completion  [was stage 06]
--       PaymentChannel.idr   Session p is consumed at multiplicity 1; missing `finish` is a
--                            linearity error, not just a runtime omission.
--       removes tests: "every protocol path ends in finish"
--
--   ✗ Duality of a protocol not machine-checked  [was stage 06]
--       PaymentSessionTypes.idr  dualInvolution : (p : SessionType) -> dual (dual p) = p
--       dual is a total function; its involution is proved by structural induction, not asserted.
--
-- REMAINING GAPS — not yet proved by the compiler:
--
--   ✗ Serialisation safety relies on unsafe casts  [open]
--       PaymentChannel.idr   packBlob/unpackBlob via believe_me — transport layer remains untyped.
--
-- ─────────────────────────────────────────────────────────────────────────────

||| Payment demos showing the end-state story for the talk.
module Main

import System
import Data.Vect
import Control.Linear.LIO
import Data.Linear.Notation
import Data.Linear.LEither
import System.Concurrency.Linear

import PaymentSessionTypes
import PaymentDomain
import PaymentRules
import PaymentChannel

%default covering

-- ─── Sample data ──────────────────────────────────────────────────────────────

eur : Nat -> Money EUR
eur cents = MkMoney cents

lowRiskOrder : Either String (Order 1 EUR)
lowRiskOrder =
  case mkOrderLine "BOOK-TP-001" (eur 4500) 1 of
    Left err => Left err
    Right line => mkOrder "ord-low" "cust-01" [line] (Card "tok_low")

mediumRiskOrder : Either String (Order 2 EUR)
mediumRiskOrder =
  case mkOrderLine "LAPTOP-15" (eur 12000) 1 of
    Left err => Left err
    Right line1 =>
      case mkOrderLine "MOUSE-PRO" (eur 3500) 2 of
        Left err => Left err
        Right line2 => mkOrder "ord-medium" "cust-02" [line1, line2] (Card "tok_3ds")

highRiskOrder : Either String (Order 1 EUR)
highRiskOrder =
  case mkOrderLine "B2B-SERVER-RACK" (eur 120000) 1 of
    Left err => Left err
    Right line => mkOrder "ord-high" "cust-03" [line] (Invoice "PO-7788")

-- ─── Shared settlement steps ──────────────────────────────────────────────────

runRefundableSettlementServer : AuthorizedPayment n c
                             -> (1 _ : Session (dual (commonSettlement True n c)))
                             -> L IO ()
runRefundableSettlementServer authorized session = do
  afterAuth <- sendLogged session authorized
  let captured = capture authorized
  afterCapture <- sendLogged afterAuth captured
  branch <- awaitChoice afterCapture
  case branch of
    Left refunding => do
      done <- sendLogged refunding (refund captured)
      finish done
    Right done => finish done

runFinalSettlementServer : AuthorizedPayment n c
                        -> (1 _ : Session (dual (commonSettlement False n c)))
                        -> L IO ()
runFinalSettlementServer authorized session = do
  afterAuth <- sendLogged session authorized
  afterCapture <- sendLogged afterAuth (capture authorized)
  finish afterCapture

runRefundableSettlementClient : Bool
                             -> (1 _ : Session (commonSettlement True n c))
                             -> L IO ()
runRefundableSettlementClient refundRequested session = do
  (MkBang authorized # afterAuth) <- receiveLogged {a = AuthorizedPayment n c} session
  note ("Authorized: " ++ show authorized)
  (MkBang captured # afterCapture) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Captured: " ++ show captured)
  case refundRequested of
    True => do
      refunding <- selectLeft afterCapture
      (MkBang refunded # done) <- receiveLogged {a = RefundedPayment n c} refunding
      note ("Refunded: " ++ show refunded)
      finish done
    False => do
      done <- selectRight afterCapture
      finish done

runFinalSettlementClient : (1 _ : Session (commonSettlement False n c)) -> L IO ()
runFinalSettlementClient session = do
  (MkBang authorized # afterAuth) <- receiveLogged {a = AuthorizedPayment n c} session
  note ("Authorized: " ++ show authorized)
  (MkBang captured # done) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Captured: " ++ show captured)
  finish done

showDerivedFlow : Order n c -> RiskSnapshot -> L IO ()
showDerivedFlow order snapshot = do
  note ("Derived policy: " ++ describe (policyFromOrder order))
  note ("Protocol path: "  ++ protocolLabelFor order)
  note ("Snapshot: "       ++ show snapshot)

-- ─── Server: low-risk ─────────────────────────────────────────────────────────

serverLowRiskRefundable : Assessment LowRisk n c
                       -> (1 _ : Session (dual (lowRiskProtocol True n c)))
                       -> L IO ()
serverLowRiskRefundable assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  runRefundableSettlementServer (authorize assessment AutoApproved) afterSnapshot

serverLowRiskFinal : Assessment LowRisk n c
                  -> (1 _ : Session (dual (lowRiskProtocol False n c)))
                  -> L IO ()
serverLowRiskFinal assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  runFinalSettlementServer (authorize assessment AutoApproved) afterSnapshot

-- ─── Server: medium-risk ──────────────────────────────────────────────────────

serverMediumRiskRefundable : Assessment MediumRisk n c
                          -> (1 _ : Session (dual (mediumRiskProtocol True n c)))
                          -> L IO ()
serverMediumRiskRefundable assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  let challenge = MkThreeDSChallenge ("3ds-" ++ orderId submitted) "soft"
  afterChallenge <- sendLogged afterSnapshot challenge
  (MkBang threeDSProof # afterProof) <- receiveLogged {a = ThreeDSProof} afterChallenge
  runRefundableSettlementServer (authorize assessment (ThreeDSApproved threeDSProof)) afterProof

serverMediumRiskFinal : Assessment MediumRisk n c
                     -> (1 _ : Session (dual (mediumRiskProtocol False n c)))
                     -> L IO ()
serverMediumRiskFinal assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  let challenge = MkThreeDSChallenge ("3ds-" ++ orderId submitted) "soft"
  afterChallenge <- sendLogged afterSnapshot challenge
  (MkBang threeDSProof # afterProof) <- receiveLogged {a = ThreeDSProof} afterChallenge
  runFinalSettlementServer (authorize assessment (ThreeDSApproved threeDSProof)) afterProof

-- ─── Server: high-risk ────────────────────────────────────────────────────────

serverHighRiskRefundable : Assessment HighRisk n c
                        -> (1 _ : Session (dual (highRiskProtocol True n c)))
                        -> L IO ()
serverHighRiskRefundable assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  let reviewRequest = MkManualReviewRequest "manual-review" (reason assessment)
  afterReview <- sendLogged afterSnapshot reviewRequest
  (MkBang reviewApproval # afterApproval) <- receiveLogged {a = ManualReviewApproval} afterReview
  runRefundableSettlementServer (authorize assessment (ReviewerApproved reviewApproval)) afterApproval

serverHighRiskFinal : Assessment HighRisk n c
                   -> (1 _ : Session (dual (highRiskProtocol False n c)))
                   -> L IO ()
serverHighRiskFinal assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  let reviewRequest = MkManualReviewRequest "manual-review" (reason assessment)
  afterReview <- sendLogged afterSnapshot reviewRequest
  (MkBang reviewApproval # afterApproval) <- receiveLogged {a = ManualReviewApproval} afterReview
  runFinalSettlementServer (authorize assessment (ReviewerApproved reviewApproval)) afterApproval

-- ─── Client: low-risk ─────────────────────────────────────────────────────────

clientLowRiskRefundable : Bool -> Order n c
                       -> (1 _ : Session (lowRiskProtocol True n c))
                       -> L IO ()
clientLowRiskRefundable refundRequested order session = do
  afterOrder <- sendLogged session order
  (MkBang snapshot # settling) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  runRefundableSettlementClient refundRequested settling

clientLowRiskFinal : Order n c
                  -> (1 _ : Session (lowRiskProtocol False n c))
                  -> L IO ()
clientLowRiskFinal order session = do
  afterOrder <- sendLogged session order
  (MkBang snapshot # settling) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  runFinalSettlementClient settling

-- ─── Client: medium-risk ──────────────────────────────────────────────────────

clientMediumRiskRefundable : Bool -> Order n c
                          -> (1 _ : Session (mediumRiskProtocol True n c))
                          -> L IO ()
clientMediumRiskRefundable refundRequested order session = do
  afterOrder <- sendLogged session order
  (MkBang snapshot # challenged) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (MkBang challenge # afterChallenge) <- receiveLogged {a = ThreeDSChallenge} challenged
  note ("Challenge: " ++ show challenge)
  settling <- sendLogged afterChallenge (MkThreeDSProof (challengeId challenge) True)
  runRefundableSettlementClient refundRequested settling

clientMediumRiskFinal : Order n c
                     -> (1 _ : Session (mediumRiskProtocol False n c))
                     -> L IO ()
clientMediumRiskFinal order session = do
  afterOrder <- sendLogged session order
  (MkBang snapshot # challenged) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (MkBang challenge # afterChallenge) <- receiveLogged {a = ThreeDSChallenge} challenged
  note ("Challenge: " ++ show challenge)
  settling <- sendLogged afterChallenge (MkThreeDSProof (challengeId challenge) True)
  runFinalSettlementClient settling

-- ─── Client: high-risk ────────────────────────────────────────────────────────

clientHighRiskRefundable : Bool -> Order n c
                        -> (1 _ : Session (highRiskProtocol True n c))
                        -> L IO ()
clientHighRiskRefundable refundRequested order session = do
  afterOrder <- sendLogged session order
  (MkBang snapshot # reviewing) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (MkBang reviewRequest # afterReview) <- receiveLogged {a = ManualReviewRequest} reviewing
  note ("Manual review requested: " ++ show reviewRequest)
  settling <- sendLogged afterReview (MkManualReviewApproval "ops-reviewer" "KYC and invoice matched")
  runRefundableSettlementClient refundRequested settling

clientHighRiskFinal : Order n c
                   -> (1 _ : Session (highRiskProtocol False n c))
                   -> L IO ()
clientHighRiskFinal order session = do
  afterOrder <- sendLogged session order
  (MkBang snapshot # reviewing) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (MkBang reviewRequest # afterReview) <- receiveLogged {a = ManualReviewRequest} reviewing
  note ("Manual review requested: " ++ show reviewRequest)
  settling <- sendLogged afterReview (MkManualReviewApproval "ops-reviewer" "KYC and invoice matched")
  runFinalSettlementClient settling

-- ─── Scenario runner ─────────────────────────────────────────────────────────

||| Dispatch helper. Because both session-end types are written as
||| `Session (protocolFromSnapshot snap n c)`, destructuring `snap` in the
||| patterns below drives `protocolFromSnapshot` to reduce definitionally to
||| the concrete protocol shape, and the existing typed handlers fit without
||| explicit coercion. `par` runs server and client concurrently in linear IO;
||| both sessions are consumed exactly once.
runScenarioFor : {n : Nat} -> {c : Currency}
              -> (refundRequested : Bool)
              -> (order : Order n c)
              -> (snap : RiskSnapshot)
              -> (1 _ : Session (protocolFromSnapshot snap n c))
              -> (1 _ : Session (dual (protocolFromSnapshot snap n c)))
              -> L IO ()
runScenarioFor refundRequested order
    (MkRiskSnapshot LowRisk _ _ _ True _) clientEnd serverEnd = do
  let assessment : Assessment LowRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverLowRiskRefundable assessment serverEnd)
           (clientLowRiskRefundable refundRequested order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot LowRisk _ _ _ False _) clientEnd serverEnd = do
  let assessment : Assessment LowRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverLowRiskFinal assessment serverEnd)
           (clientLowRiskFinal order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot MediumRisk _ _ _ True _) clientEnd serverEnd = do
  let assessment : Assessment MediumRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverMediumRiskRefundable assessment serverEnd)
           (clientMediumRiskRefundable refundRequested order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot MediumRisk _ _ _ False _) clientEnd serverEnd = do
  let assessment : Assessment MediumRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverMediumRiskFinal assessment serverEnd)
           (clientMediumRiskFinal order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot HighRisk _ _ _ True _) clientEnd serverEnd = do
  let assessment : Assessment HighRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverHighRiskRefundable assessment serverEnd)
           (clientHighRiskRefundable refundRequested order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot HighRisk _ _ _ False _) clientEnd serverEnd = do
  let assessment : Assessment HighRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverHighRiskFinal assessment serverEnd)
           (clientHighRiskFinal order clientEnd)
  pure ()

||| The scenario runner. The protocol value passed to `openSession` is the
||| result of `protocolFromSnapshot snapshot n c` — equivalently
||| `protocolDerivedFrom order` — a single function call whose return TYPE
||| flows from the runtime snapshot. The dispatch into typed handlers is then
||| a single call to `runScenarioFor`, indexed by that same snapshot.
runOrderScenario : {n : Nat} -> {c : Currency} -> (refundRequested : Bool) -> Order n c -> L IO ()
runOrderScenario refundRequested order = do
  let snapshot = riskSnapshotFor order
  note ("Protocol derived from runtime order value: " ++ protocolLabelFor order)
  note ("                                ( = protocolDerivedFrom order : SessionType )")
  -- Π-elimination running: protocolFromSnapshot snapshot n c computes a
  -- SessionType whose structure depends on the snapshot, and the same
  -- expression flows straight into openSession — its return type is indexed
  -- by the protocol shape.
  (clientEnd # serverEnd) <- openSession (protocolFromSnapshot snapshot n c)
  runScenarioFor refundRequested order snapshot clientEnd serverEnd

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 1 — Low-risk payment
-- ══════════════════════════════════════════════════════════════════════════════

demo1 : L IO ()
demo1 =
  case lowRiskOrder of
    Left err => note ("Failed to build low-risk order: " ++ err)
    Right order => do
      section "DEMO 1 — Low-Risk Card Payment"
      runOrderScenario False order
      outcome "Low-risk path: direct authorize -> capture, no extra challenge"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 2 — Medium-risk payment with 3DS
-- ══════════════════════════════════════════════════════════════════════════════

demo2 : L IO ()
demo2 =
  case mediumRiskOrder of
    Left err => note ("Failed to build medium-risk order: " ++ err)
    Right order => do
      section "DEMO 2 — Medium-Risk Card Payment With 3DS"
      runOrderScenario True order
      outcome "Medium-risk path: runtime risk policy inserts 3DS and keeps refund branch"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 3 — High-risk payment with manual review
-- ══════════════════════════════════════════════════════════════════════════════

demo3 : L IO ()
demo3 =
  case highRiskOrder of
    Left err => note ("Failed to build high-risk order: " ++ err)
    Right order => do
      section "DEMO 3 — High-Risk Invoice Payment With Manual Review"
      runOrderScenario False order
      outcome "High-risk path: manual review gate before authorization, no refund branch"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 4 — Boundary validation
-- ══════════════════════════════════════════════════════════════════════════════

demo4 : L IO ()
demo4 = do
  section "DEMO 4 — Refined Boundary Checks"
  note ("mkOrderLine qty=0 -> " ++ show (mkOrderLine "BUGGY" (eur 1000) 0))
  note ("mkOrder []      -> " ++ show (mkOrder "ord-empty" "cust-x" (the (Vect 0 (OrderLine EUR)) []) (Card "tok")))
  outcome "Bad inputs are rejected once, before the protocol is entered"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 5 — Typestate and indexed audit trail
-- ══════════════════════════════════════════════════════════════════════════════

demo5 : L IO ()
demo5 =
  case lowRiskOrder of
    Left err => note ("Failed to build typestate demo order: " ++ err)
    Right order => do
      section "DEMO 5 — Typestate + Indexed Audit Trail"
      case assessOrder order of
        (LowRisk ** assessment) => do
          let authorized = authorize assessment AutoApproved
          let captured   = capture authorized
          let refunded   = refund captured
          note ("Authorized trail: " ++ show authorized)
          note ("Captured trail:   " ++ show captured)
          note ("Refunded trail:   " ++ show refunded)
          note "Illegal transitions now fail to typecheck:"
          note "  capture (refund captured)"
          note "  refund authorized"
          note "  authorize assessment (ReviewerApproved ...)"
          outcome "The state machine lives in types, not in booleans and comments"
        (MediumRisk ** _) => note "Unexpected medium-risk order in typestate demo"
        (HighRisk ** _)   => note "Unexpected high-risk order in typestate demo"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 6 — Policy DSL interpretations
-- ══════════════════════════════════════════════════════════════════════════════

demo6 : L IO ()
demo6 = do
  section "DEMO 6 — Policy DSL Interpretations"
  case lowRiskOrder of
    Left err => note ("Low-risk order unavailable: " ++ err)
    Right order => do
      let policy = policyFromOrder order
      note ("Low-risk policy: " ++ describe policy)
      note ("Low-risk analysis: " ++ show (analyze policy))
  case mediumRiskOrder of
    Left err => note ("Medium-risk order unavailable: " ++ err)
    Right order => do
      let policy = policyFromOrder order
      note ("Medium-risk policy: " ++ describe policy)
      note ("Medium-risk analysis: " ++ show (analyze policy))
  case highRiskOrder of
    Left err => note ("High-risk order unavailable: " ++ err)
    Right order => do
      let policy = policyFromOrder order
      note ("High-risk policy: " ++ describe policy)
      note ("High-risk analysis: " ++ show (analyze policy))
  outcome "One recursive policy tree drives docs, process constraints, and protocol shape"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 7 — Idris-only payoff
-- ══════════════════════════════════════════════════════════════════════════════

demo7 : L IO ()
demo7 = do
  section "DEMO 7 — Idris-Only Endgame"
  note "dualInvolution : (p : SessionType) -> dual (dual p) = p"
  note "protocolDerivedFrom order : SessionType"
  note "assessOrder : Order n c -> (lvl ** Assessment lvl n c)"
  note "authorize : Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c"
  note "Session p consumed at multiplicity 1: dropping it is a compile error."
  note "Two steps Scala cannot finish: the protocol and the required witness"
  note "  both depend on runtime values, and the channel itself is linearly tracked."
  outcome "Dependent types remove the runtime-to-type bridge; linearity closes the channel-completion gap"

main : IO ()
main = LIO.run $ do
  demo1
  demo2
  demo3
  demo4
  demo5
  demo6
  demo7
