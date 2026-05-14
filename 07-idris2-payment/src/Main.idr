||| Payment demos showing the end-state story for the talk.
module Main

import System
import System.Concurrency
import Data.Vect

import PaymentSessionTypes
import PaymentDomain
import PaymentRules
import PaymentChannel

%default covering

-- Idris parser note:
-- avoid reserved identifiers such as `proof` in top-level argument names.
-- See COMPILE_ISSUE.md for the failure mode and docs pointers.

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

runRefundableSettlementServer : AuthorizedPayment n c -> Session (dual (commonSettlement True n c)) -> IO ()
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

runFinalSettlementServer : AuthorizedPayment n c -> Session (dual (commonSettlement False n c)) -> IO ()
runFinalSettlementServer authorized session = do
  afterAuth <- sendLogged session authorized
  afterCapture <- sendLogged afterAuth (capture authorized)
  finish afterCapture

runRefundableSettlementClient : Bool -> Session (commonSettlement True n c) -> IO ()
runRefundableSettlementClient refundRequested session = do
  (authorized, afterAuth) <- receiveLogged {a = AuthorizedPayment n c} session
  note ("Authorized: " ++ show authorized)
  (captured, afterCapture) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Captured: " ++ show captured)
  case refundRequested of
    True => do
      refunding <- selectLeft afterCapture
      (refunded, done) <- receiveLogged {a = RefundedPayment n c} refunding
      note ("Refunded: " ++ show refunded)
      finish done
    False => do
      done <- selectRight afterCapture
      finish done

runFinalSettlementClient : Session (commonSettlement False n c) -> IO ()
runFinalSettlementClient session = do
  (authorized, afterAuth) <- receiveLogged {a = AuthorizedPayment n c} session
  note ("Authorized: " ++ show authorized)
  (captured, done) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Captured: " ++ show captured)
  finish done

showDerivedFlow : Order n c -> RiskSnapshot -> IO ()
showDerivedFlow order snapshot = do
  note ("Derived policy: " ++ describe (policyFromOrder order))
  note ("Protocol path: "  ++ protocolLabelFor order)
  note ("Snapshot: "       ++ show snapshot)

-- ─── Server: low-risk ─────────────────────────────────────────────────────────

serverLowRiskRefundable : Session (dual (lowRiskProtocol True n c)) -> IO ()
serverLowRiskRefundable session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  case assessOrder submitted of
    (LowRisk ** assessment) =>
      runRefundableSettlementServer (authorize assessment AutoApproved) afterSnapshot
    (MediumRisk ** _) =>
      note "SERVER BUG: low-risk protocol received a medium-risk assessment"
    (HighRisk ** _) =>
      note "SERVER BUG: low-risk protocol received a high-risk assessment"

serverLowRiskFinal : Session (dual (lowRiskProtocol False n c)) -> IO ()
serverLowRiskFinal session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  case assessOrder submitted of
    (LowRisk ** assessment) =>
      runFinalSettlementServer (authorize assessment AutoApproved) afterSnapshot
    (MediumRisk ** _) =>
      note "SERVER BUG: low-risk protocol received a medium-risk assessment"
    (HighRisk ** _) =>
      note "SERVER BUG: low-risk protocol received a high-risk assessment"

-- ─── Server: medium-risk ──────────────────────────────────────────────────────

serverMediumRiskRefundable : Session (dual (mediumRiskProtocol True n c)) -> IO ()
serverMediumRiskRefundable session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  case assessOrder submitted of
    (MediumRisk ** assessment) => do
      let challenge = MkThreeDSChallenge ("3ds-" ++ orderId submitted) "soft"
      afterChallenge <- sendLogged afterSnapshot challenge
      (threeDSProof, afterProof) <- receiveLogged {a = ThreeDSProof} afterChallenge
      let authorized = authorize assessment (ThreeDSApproved threeDSProof)
      runRefundableSettlementServer authorized afterProof
    (LowRisk ** _) =>
      note "SERVER BUG: medium-risk protocol received a low-risk assessment"
    (HighRisk ** _) =>
      note "SERVER BUG: medium-risk protocol received a high-risk assessment"

serverMediumRiskFinal : Session (dual (mediumRiskProtocol False n c)) -> IO ()
serverMediumRiskFinal session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  case assessOrder submitted of
    (MediumRisk ** assessment) => do
      let challenge = MkThreeDSChallenge ("3ds-" ++ orderId submitted) "soft"
      afterChallenge <- sendLogged afterSnapshot challenge
      (threeDSProof, afterProof) <- receiveLogged {a = ThreeDSProof} afterChallenge
      let authorized = authorize assessment (ThreeDSApproved threeDSProof)
      runFinalSettlementServer authorized afterProof
    (LowRisk ** _) =>
      note "SERVER BUG: medium-risk protocol received a low-risk assessment"
    (HighRisk ** _) =>
      note "SERVER BUG: medium-risk protocol received a high-risk assessment"

-- ─── Server: high-risk ────────────────────────────────────────────────────────

serverHighRiskRefundable : Session (dual (highRiskProtocol True n c)) -> IO ()
serverHighRiskRefundable session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  case assessOrder submitted of
    (HighRisk ** assessment) => do
      let reviewRequest = MkManualReviewRequest "manual-review" (reason assessment)
      afterReview <- sendLogged afterSnapshot reviewRequest
      (reviewApproval, afterApproval) <- receiveLogged {a = ManualReviewApproval} afterReview
      let authorized = authorize assessment (ReviewerApproved reviewApproval)
      runRefundableSettlementServer authorized afterApproval
    (LowRisk ** _) =>
      note "SERVER BUG: high-risk protocol received a low-risk assessment"
    (MediumRisk ** _) =>
      note "SERVER BUG: high-risk protocol received a medium-risk assessment"

serverHighRiskFinal : Session (dual (highRiskProtocol False n c)) -> IO ()
serverHighRiskFinal session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot <- sendLogged afterOrder (riskSnapshotFor submitted)
  case assessOrder submitted of
    (HighRisk ** assessment) => do
      let reviewRequest = MkManualReviewRequest "manual-review" (reason assessment)
      afterReview <- sendLogged afterSnapshot reviewRequest
      (reviewApproval, afterApproval) <- receiveLogged {a = ManualReviewApproval} afterReview
      let authorized = authorize assessment (ReviewerApproved reviewApproval)
      runFinalSettlementServer authorized afterApproval
    (LowRisk ** _) =>
      note "SERVER BUG: high-risk protocol received a low-risk assessment"
    (MediumRisk ** _) =>
      note "SERVER BUG: high-risk protocol received a medium-risk assessment"

-- ─── Client: low-risk ─────────────────────────────────────────────────────────

clientLowRiskRefundable : Bool -> Order n c -> Session (lowRiskProtocol True n c) -> IO ()
clientLowRiskRefundable refundRequested order session = do
  afterOrder <- sendLogged session order
  (snapshot, settling) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  runRefundableSettlementClient refundRequested settling

clientLowRiskFinal : Order n c -> Session (lowRiskProtocol False n c) -> IO ()
clientLowRiskFinal order session = do
  afterOrder <- sendLogged session order
  (snapshot, settling) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  runFinalSettlementClient settling

-- ─── Client: medium-risk ──────────────────────────────────────────────────────

clientMediumRiskRefundable : Bool -> Order n c -> Session (mediumRiskProtocol True n c) -> IO ()
clientMediumRiskRefundable refundRequested order session = do
  afterOrder <- sendLogged session order
  (snapshot, challenged) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (challenge, afterChallenge) <- receiveLogged {a = ThreeDSChallenge} challenged
  note ("Challenge: " ++ show challenge)
  settling <- sendLogged afterChallenge (MkThreeDSProof (challengeId challenge) True)
  runRefundableSettlementClient refundRequested settling

clientMediumRiskFinal : Order n c -> Session (mediumRiskProtocol False n c) -> IO ()
clientMediumRiskFinal order session = do
  afterOrder <- sendLogged session order
  (snapshot, challenged) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (challenge, afterChallenge) <- receiveLogged {a = ThreeDSChallenge} challenged
  note ("Challenge: " ++ show challenge)
  settling <- sendLogged afterChallenge (MkThreeDSProof (challengeId challenge) True)
  runFinalSettlementClient settling

-- ─── Client: high-risk ────────────────────────────────────────────────────────

clientHighRiskRefundable : Bool -> Order n c -> Session (highRiskProtocol True n c) -> IO ()
clientHighRiskRefundable refundRequested order session = do
  afterOrder <- sendLogged session order
  (snapshot, reviewing) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (reviewRequest, afterReview) <- receiveLogged {a = ManualReviewRequest} reviewing
  note ("Manual review requested: " ++ show reviewRequest)
  settling <- sendLogged afterReview (MkManualReviewApproval "ops-reviewer" "KYC and invoice matched")
  runRefundableSettlementClient refundRequested settling

clientHighRiskFinal : Order n c -> Session (highRiskProtocol False n c) -> IO ()
clientHighRiskFinal order session = do
  afterOrder <- sendLogged session order
  (snapshot, reviewing) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  (reviewRequest, afterReview) <- receiveLogged {a = ManualReviewRequest} reviewing
  note ("Manual review requested: " ++ show reviewRequest)
  settling <- sendLogged afterReview (MkManualReviewApproval "ops-reviewer" "KYC and invoice matched")
  runFinalSettlementClient settling

-- ─── Scenario runner ─────────────────────────────────────────────────────────

runOrderScenario : {n : Nat} -> {c : Currency} -> (refundRequested : Bool) -> Order n c -> IO ()
runOrderScenario refundRequested order = do
  let snapshot = riskSnapshotFor order
  let refund   = snapshot.refundPermitted
  note ("Protocol derived from runtime order value: " ++ protocolLabelFor order)
  case snapshot.level of
    LowRisk => do
      case refund of
        True => do
          (clientEnd, serverEnd) <- openSession (lowRiskProtocol True n c)
          tid <- fork (serverLowRiskRefundable serverEnd)
          clientLowRiskRefundable refundRequested order clientEnd
          threadWait tid
        False => do
          (clientEnd, serverEnd) <- openSession (lowRiskProtocol False n c)
          tid <- fork (serverLowRiskFinal serverEnd)
          clientLowRiskFinal order clientEnd
          threadWait tid
    MediumRisk => do
      case refund of
        True => do
          (clientEnd, serverEnd) <- openSession (mediumRiskProtocol True n c)
          tid <- fork (serverMediumRiskRefundable serverEnd)
          clientMediumRiskRefundable refundRequested order clientEnd
          threadWait tid
        False => do
          (clientEnd, serverEnd) <- openSession (mediumRiskProtocol False n c)
          tid <- fork (serverMediumRiskFinal serverEnd)
          clientMediumRiskFinal order clientEnd
          threadWait tid
    HighRisk => do
      case refund of
        True => do
          (clientEnd, serverEnd) <- openSession (highRiskProtocol True n c)
          tid <- fork (serverHighRiskRefundable serverEnd)
          clientHighRiskRefundable refundRequested order clientEnd
          threadWait tid
        False => do
          (clientEnd, serverEnd) <- openSession (highRiskProtocol False n c)
          tid <- fork (serverHighRiskFinal serverEnd)
          clientHighRiskFinal order clientEnd
          threadWait tid

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 1 — Low-risk payment
-- ══════════════════════════════════════════════════════════════════════════════

demo1 : IO ()
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

demo2 : IO ()
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

demo3 : IO ()
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

demo4 : IO ()
demo4 = do
  section "DEMO 4 — Refined Boundary Checks"
  note ("mkOrderLine qty=0 -> " ++ show (mkOrderLine "BUGGY" (eur 1000) 0))
  note ("mkOrder []      -> " ++ show (mkOrder "ord-empty" "cust-x" (the (Vect 0 (OrderLine EUR)) []) (Card "tok")))
  outcome "Bad inputs are rejected once, before the protocol is entered"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 5 — Typestate and indexed audit trail
-- ══════════════════════════════════════════════════════════════════════════════

demo5 : IO ()
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

demo6 : IO ()
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

demo7 : IO ()
demo7 = do
  section "DEMO 7 — Idris-Only Endgame"
  note "dualInvolution : (p : SessionType) -> dual (dual p) = p"
  note "protocolDerivedFrom order : SessionType"
  note "assessOrder : Order n c -> (lvl ** Assessment lvl n c)"
  note "authorize : Assessment lvl n c -> Approval lvl -> AuthorizedPayment n c"
  note "This is the step Scala cannot finish:"
  note "  the protocol and the required witness both depend on runtime values."
  outcome "Dependent types remove the last bridge between runtime analysis and compile-time guarantees"

main : IO ()
main = do
  demo1
  demo2
  demo3
  demo4
  demo5
  demo6
  demo7
