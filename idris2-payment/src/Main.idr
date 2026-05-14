||| Payment demos showing the end-state story for the talk.
module Main

import System
import System.Concurrency

import PaymentSessionTypes
import PaymentDomain
import PaymentRules
import PaymentChannel

%default covering

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

serverLowRisk : (refundAllowed : Bool) -> Session (dual (lowRiskProtocol refundAllowed n c)) -> IO ()
serverLowRisk refundAllowed session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  let assessment = assessOrder submitted
  let snapshot = riskSnapshotFor submitted
  afterSnapshot <- sendLogged afterOrder snapshot
  case assessment.level of
    LowRisk => do
      let authorized = authorize assessment AutoApproved
      afterAuth <- sendLogged afterSnapshot authorized
      let captured = capture authorized
      afterCapture <- sendLogged afterAuth captured
      case refundAllowed of
        True => do
          branch <- awaitChoice afterCapture
          case branch of
            Left refunding => do
              refunded <- sendLogged refunding (refund captured)
              finish refunded
            Right done => finish done
        False => finish afterCapture
    MediumRisk => note "SERVER BUG: low-risk handler received medium-risk order"
    HighRisk => note "SERVER BUG: low-risk handler received high-risk order"

serverMediumRisk : (refundAllowed : Bool) -> Session (dual (mediumRiskProtocol refundAllowed n c)) -> IO ()
serverMediumRisk refundAllowed session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  let assessment = assessOrder submitted
  let snapshot = riskSnapshotFor submitted
  afterSnapshot <- sendLogged afterOrder snapshot
  afterChallenge <- sendLogged afterSnapshot (MkThreeDSChallenge ("3ds-" ++ submitted.orderId) "soft")
  (proof, afterProof) <- receiveLogged {a = ThreeDSProof} afterChallenge
  case assessment.level of
    MediumRisk => do
      let authorized = authorize assessment (ThreeDSApproved proof)
      afterAuth <- sendLogged afterProof authorized
      let captured = capture authorized
      afterCapture <- sendLogged afterAuth captured
      case refundAllowed of
        True => do
          branch <- awaitChoice afterCapture
          case branch of
            Left refunding => do
              refunded <- sendLogged refunding (refund captured)
              finish refunded
            Right done => finish done
        False => finish afterCapture
    LowRisk => note "SERVER BUG: medium-risk handler received low-risk order"
    HighRisk => note "SERVER BUG: medium-risk handler received high-risk order"

serverHighRisk : (refundAllowed : Bool) -> Session (dual (highRiskProtocol refundAllowed n c)) -> IO ()
serverHighRisk refundAllowed session = do
  (submitted, afterOrder) <- receiveLogged {a = Order n c} session
  let assessment = assessOrder submitted
  let snapshot = riskSnapshotFor submitted
  afterSnapshot <- sendLogged afterOrder snapshot
  afterReview <- sendLogged afterSnapshot (MkManualReviewRequest "manual-review" assessment.reason)
  (approval, afterApproval) <- receiveLogged {a = ManualReviewApproval} afterReview
  case assessment.level of
    HighRisk => do
      let authorized = authorize assessment (ReviewerApproved approval)
      afterAuth <- sendLogged afterApproval authorized
      let captured = capture authorized
      afterCapture <- sendLogged afterAuth captured
      case refundAllowed of
        True => do
          branch <- awaitChoice afterCapture
          case branch of
            Left refunding => do
              refunded <- sendLogged refunding (refund captured)
              finish refunded
            Right done => finish done
        False => finish afterCapture
    LowRisk => note "SERVER BUG: high-risk handler received low-risk order"
    MediumRisk => note "SERVER BUG: high-risk handler received medium-risk order"

clientLowRisk : (refundRequested : Bool) -> (refundAllowed : Bool) -> Order n c -> Session (lowRiskProtocol refundAllowed n c) -> IO ()
clientLowRisk refundRequested refundAllowed order session = do
  afterOrder <- sendLogged session order
  (snapshot, afterSnapshot) <- receiveLogged {a = RiskSnapshot} afterOrder
  note ("Derived policy: " ++ describe (policyFromOrder order))
  note ("Protocol path: " ++ protocolLabelFor order)
  note ("Snapshot: " ++ show snapshot)
  (authorized, afterAuth) <- receiveLogged {a = AuthorizedPayment n c} afterSnapshot
  note ("Authorized: " ++ show authorized)
  (captured, afterCapture) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Captured: " ++ show captured)
  case refundAllowed of
    True =>
      case refundRequested of
        True => do
          refunding <- selectLeft afterCapture
          (refunded, done) <- receiveLogged {a = RefundedPayment n c} refunding
          note ("Refunded: " ++ show refunded)
          finish done
        False => do
          done <- selectRight afterCapture
          finish done
    False => finish afterCapture

clientMediumRisk : (refundRequested : Bool) -> (refundAllowed : Bool) -> Order n c -> Session (mediumRiskProtocol refundAllowed n c) -> IO ()
clientMediumRisk refundRequested refundAllowed order session = do
  afterOrder <- sendLogged session order
  (snapshot, afterSnapshot) <- receiveLogged {a = RiskSnapshot} afterOrder
  note ("Derived policy: " ++ describe (policyFromOrder order))
  note ("Protocol path: " ++ protocolLabelFor order)
  note ("Snapshot: " ++ show snapshot)
  (challenge, afterChallenge) <- receiveLogged {a = ThreeDSChallenge} afterSnapshot
  note ("Challenge: " ++ show challenge)
  afterProof <- sendLogged afterChallenge (MkThreeDSProof challenge.challengeId True)
  (authorized, afterAuth) <- receiveLogged {a = AuthorizedPayment n c} afterProof
  (captured, afterCapture) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Authorized: " ++ show authorized)
  note ("Captured: " ++ show captured)
  case refundAllowed of
    True =>
      case refundRequested of
        True => do
          refunding <- selectLeft afterCapture
          (refunded, done) <- receiveLogged {a = RefundedPayment n c} refunding
          note ("Refunded: " ++ show refunded)
          finish done
        False => do
          done <- selectRight afterCapture
          finish done
    False => finish afterCapture

clientHighRisk : (refundRequested : Bool) -> (refundAllowed : Bool) -> Order n c -> Session (highRiskProtocol refundAllowed n c) -> IO ()
clientHighRisk refundRequested refundAllowed order session = do
  afterOrder <- sendLogged session order
  (snapshot, afterSnapshot) <- receiveLogged {a = RiskSnapshot} afterOrder
  note ("Derived policy: " ++ describe (policyFromOrder order))
  note ("Protocol path: " ++ protocolLabelFor order)
  note ("Snapshot: " ++ show snapshot)
  (reviewRequest, afterReviewRequest) <- receiveLogged {a = ManualReviewRequest} afterSnapshot
  note ("Manual review requested: " ++ show reviewRequest)
  afterApproval <- sendLogged afterReviewRequest (MkManualReviewApproval "ops-reviewer" "KYC and invoice matched")
  (authorized, afterAuth) <- receiveLogged {a = AuthorizedPayment n c} afterApproval
  (captured, afterCapture) <- receiveLogged {a = CapturedPayment n c} afterAuth
  note ("Authorized: " ++ show authorized)
  note ("Captured: " ++ show captured)
  case refundAllowed of
    True =>
      case refundRequested of
        True => do
          refunding <- selectLeft afterCapture
          (refunded, done) <- receiveLogged {a = RefundedPayment n c} refunding
          note ("Refunded: " ++ show refunded)
          finish done
        False => do
          done <- selectRight afterCapture
          finish done
    False => finish afterCapture

runOrderScenario : (refundRequested : Bool) -> Order n c -> IO ()
runOrderScenario refundRequested order = do
  let snapshot = riskSnapshotFor order
  let derived = protocolDerivedFrom order
  note ("Protocol derived from runtime order value: " ++ protocolLabelFor order)
  case snapshot.level of
    LowRisk => do
      (clientEnd, serverEnd) <- openSession derived
      tid <- fork (serverLowRisk snapshot.refundPermitted serverEnd)
      clientLowRisk refundRequested snapshot.refundPermitted order clientEnd
      threadWait tid
    MediumRisk => do
      (clientEnd, serverEnd) <- openSession derived
      tid <- fork (serverMediumRisk snapshot.refundPermitted serverEnd)
      clientMediumRisk refundRequested snapshot.refundPermitted order clientEnd
      threadWait tid
    HighRisk => do
      (clientEnd, serverEnd) <- openSession derived
      tid <- fork (serverHighRisk snapshot.refundPermitted serverEnd)
      clientHighRisk refundRequested snapshot.refundPermitted order clientEnd
      threadWait tid

demo1 : IO ()
demo1 =
  case lowRiskOrder of
    Left err => note ("Failed to build low-risk order: " ++ err)
    Right order => do
      section "DEMO 1 — Low-Risk Card Payment"
      runOrderScenario False order
      outcome "Low-risk path: direct authorize -> capture, no extra challenge"

demo2 : IO ()
demo2 =
  case mediumRiskOrder of
    Left err => note ("Failed to build medium-risk order: " ++ err)
    Right order => do
      section "DEMO 2 — Medium-Risk Card Payment With 3DS"
      runOrderScenario True order
      outcome "Medium-risk path: runtime risk policy inserts 3DS and keeps refund branch"

demo3 : IO ()
demo3 =
  case highRiskOrder of
    Left err => note ("Failed to build high-risk order: " ++ err)
    Right order => do
      section "DEMO 3 — High-Risk Invoice Payment With Manual Review"
      runOrderScenario False order
      outcome "High-risk path: manual review gate before authorization, no refund branch"

demo4 : IO ()
demo4 = do
  section "DEMO 4 — Refined Boundary Checks"
  note ("mkOrderLine qty=0 -> " ++ show (mkOrderLine "BUGGY" (eur 1000) 0))
  note ("mkOrder []      -> " ++ show (mkOrder "ord-empty" "cust-x" [] (Card "tok")))
  outcome "Bad inputs are rejected once, before the protocol is entered"

demo5 : IO ()
demo5 =
  case lowRiskOrder of
    Left err => note ("Failed to build typestate demo order: " ++ err)
    Right order => do
      section "DEMO 5 — Typestate + Indexed Audit Trail"
      let assessment = assessOrder order
      case assessment.level of
        LowRisk => do
          let authorized = authorize assessment AutoApproved
          let captured = capture authorized
          let refunded = refund captured
          note ("Authorized trail: " ++ show authorized)
          note ("Captured trail:   " ++ show captured)
          note ("Refunded trail:   " ++ show refunded)
          note "Illegal transitions now fail to typecheck:"
          note "  capture (refund captured)"
          note "  refund authorized"
          note "  authorize assessment (ReviewerApproved ...)"
          outcome "The state machine lives in types, not in booleans and comments"
        MediumRisk => note "Unexpected medium-risk order in typestate demo"
        HighRisk => note "Unexpected high-risk order in typestate demo"

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

demo7 : IO ()
demo7 = do
  section "DEMO 7 — Idris-Only Endgame"
  note "dualInvolution : (p : SessionType) -> dual (dual p) = p"
  note "protocolDerivedFrom order : SessionType"
  note "authorize : (assessment : Assessment n c) -> Approval assessment.level -> AuthorizedPayment n c"
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
