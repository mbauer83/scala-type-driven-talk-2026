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



-- ─── Settlement: the shared back-end of every protocol ──────────────────────
--
-- Both Refundable (refund=True) and Final (refund=False) settlement paths
-- share the same authorise → send → capture → send structure. They differ
-- only in the post-capture step: refundable offers a choice; final ends.
-- Pattern-matching on the `refundAllowed` Bool drives `commonSettlement`
-- to reduce to the appropriate protocol type, and one function covers both.
-- NOTE: the `1 _ : Session ...` arguments declares quantitative constraints
-- on the value of type Session: it must be used exactly once. The `L` in `L IO ()`
-- is the linear monad, which marks and enforces linear usage constraints 
-- of the IO-computation returned by this function.

settleServer : (refundAllowed : Bool) -> AuthorizedPayment n c
            -> (1 _ : Session (dual (commonSettlement refundAllowed n c)))
            -> L IO ()
settleServer True authorized session = do
  afterAuth    <- sendLogged session authorized
  let captured =  capture authorized
  afterCapture <- sendLogged afterAuth captured
  branch       <- awaitChoice afterCapture
  case branch of
    Left refunding => do
      done <- sendLogged refunding (refund captured)
      finish done
    Right done => finish done
settleServer False authorized session = do
  afterAuth    <- sendLogged session authorized
  afterCapture <- sendLogged afterAuth (capture authorized)
  finish afterCapture


settleClient : (refundAllowed : Bool) -> (refundRequested : Bool)
            -> (1 _ : Session (commonSettlement refundAllowed n c))
            -> L IO ()
settleClient True refundRequested session = do
  (MkBang _        # afterAuth)    <- receiveLogged {a = AuthorizedPayment n c} session
  (MkBang captured # afterCapture) <- receiveLogged {a = CapturedPayment   n c} afterAuth
  case refundRequested of
    True => do
      refunding         <- selectLeft afterCapture
      (MkBang _ # done) <- receiveLogged {a = RefundedPayment n c} refunding
      finish done
    False => do
      done <- selectRight afterCapture
      finish done
settleClient False _ session = do
  (MkBang _ # afterAuth) <- receiveLogged {a = AuthorizedPayment n c} session
  (MkBang _ # done)      <- receiveLogged {a = CapturedPayment   n c} afterAuth
  finish done


showDerivedFlow : Order n c -> RiskSnapshot -> L IO ()
showDerivedFlow order snapshot = do
  note ("Derived policy: " ++ describe (policyFromOrder order))
  note ("Protocol path: "  ++ protocolLabelFor order)
  note ("Snapshot: "       ++ show snapshot)



-- ─── Per-risk-level handlers ─────────────────────────────────────────────────
--
-- One server + one client per risk level (three of each). The `refundAllowed`
-- Bool flows into the session-type parameter, so a single signature covers
-- both the refundable and final paths.
-- NOTE: `MkBang` is used to construct re-usable "unlimited" values inside of 
-- a context where usage is otherwise quantitatively tracked. At the type level,
-- this is marked as `(!*) p` for some type p.

serverLowRisk : (refundAllowed : Bool) -> Assessment LowRisk n c
             -> (1 _ : Session (dual (lowRiskProtocol refundAllowed n c)))
             -> L IO ()
serverLowRisk refundAllowed assessment session = do
  (MkBang submitted # afterOrder) <- receiveLogged {a = Order n c} session
  afterSnapshot                   <- sendLogged afterOrder (riskSnapshotFor submitted)
  settleServer refundAllowed (authorize assessment AutoApproved) afterSnapshot


serverMediumRisk : (refundAllowed : Bool) -> Assessment MediumRisk n c
                -> (1 _ : Session (dual (mediumRiskProtocol refundAllowed n c)))
                -> L IO ()
serverMediumRisk refundAllowed assessment session = do
  (MkBang submitted    # afterOrder) <- receiveLogged {a = Order        n c} session
  afterSnapshot                      <- sendLogged afterOrder (riskSnapshotFor submitted)
  let challenge                      =  MkThreeDSChallenge ("3ds-" ++ orderId submitted) "soft"
  afterChallenge                     <- sendLogged afterSnapshot challenge
  (MkBang threeDSProof # afterProof) <- receiveLogged {a = ThreeDSProof    } afterChallenge
  settleServer refundAllowed (authorize assessment (ThreeDSApproved threeDSProof)) afterProof


serverHighRisk : (refundAllowed : Bool) -> Assessment HighRisk n c
              -> (1 _ : Session (dual (highRiskProtocol refundAllowed n c)))
              -> L IO ()
serverHighRisk refundAllowed assessment session = do
  (MkBang submitted # afterOrder)   <- receiveLogged {a = Order                n c} session
  afterSnapshot                     <- sendLogged afterOrder (riskSnapshotFor submitted)
  let request                       =  MkManualReviewRequest "manual-review" (reason assessment)
  afterReview                       <- sendLogged afterSnapshot request
  (MkBang approval # afterApproval) <- receiveLogged {a = ManualReviewApproval    } afterReview
  settleServer refundAllowed (authorize assessment (ReviewerApproved approval)) afterApproval


clientLowRisk : (refundAllowed : Bool) -> (refundRequested : Bool) -> Order n c
             -> (1 _ : Session (lowRiskProtocol refundAllowed n c))
             -> L IO ()
clientLowRisk refundAllowed refundRequested order session = do
  afterOrder                   <- sendLogged session order
  (MkBang snapshot # settling) <- receiveLogged {a = RiskSnapshot} afterOrder
  showDerivedFlow order snapshot
  settleClient refundAllowed refundRequested settling


clientMediumRisk : (refundAllowed : Bool) -> (refundRequested : Bool) -> Order n c
                -> (1 _ : Session (mediumRiskProtocol refundAllowed n c))
                -> L IO ()
clientMediumRisk refundAllowed refundRequested order session = do
  afterOrder                          <- sendLogged session order
  (MkBang snapshot  # challenged)     <- receiveLogged {a = RiskSnapshot    } afterOrder
  showDerivedFlow order snapshot
  (MkBang challenge # afterChallenge) <- receiveLogged {a = ThreeDSChallenge} challenged
  settling                            <- sendLogged afterChallenge (MkThreeDSProof (challengeId challenge) True)
  settleClient refundAllowed refundRequested settling


clientHighRisk : (refundAllowed : Bool) -> (refundRequested : Bool) -> Order n c
              -> (1 _ : Session (highRiskProtocol refundAllowed n c))
              -> L IO ()
clientHighRisk refundAllowed refundRequested order session = do
  afterOrder                     <- sendLogged session order
  (MkBang snapshot # reviewing)  <- receiveLogged {a = RiskSnapshot       } afterOrder
  showDerivedFlow order snapshot
  (MkBang request  # afterReview) <- receiveLogged {a = ManualReviewRequest} reviewing
  settling                       <- sendLogged afterReview (MkManualReviewApproval "ops-reviewer" "KYC and invoice matched")
  settleClient refundAllowed refundRequested settling



-- ─── Scenario runner ─────────────────────────────────────────────────────────

||| Dispatch. Destructuring `snap` reduces `protocolFromSnapshot` to the
||| concrete protocol shape selected by the risk level, and the refund
||| flag flows straight into both handlers as a runtime argument. `par`
||| runs server and client concurrently in linear IO; both sessions are
||| consumed exactly once.
runScenarioFor : {n : Nat} -> {c : Currency}
              -> (refundRequested : Bool)
              -> (order : Order n c)
              -> (snap : RiskSnapshot)
              -> (1 _ : Session (protocolFromSnapshot snap n c))
              -> (1 _ : Session (dual (protocolFromSnapshot snap n c)))
              -> L IO ()
runScenarioFor refundRequested order
    (MkRiskSnapshot LowRisk _ _ _ refund _) clientEnd serverEnd = do
  let assessment : Assessment LowRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverLowRisk refund assessment serverEnd)
           (clientLowRisk refund refundRequested order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot MediumRisk _ _ _ refund _) clientEnd serverEnd = do
  let assessment : Assessment MediumRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverMediumRisk refund assessment serverEnd)
           (clientMediumRisk refund refundRequested order clientEnd)
  pure ()
runScenarioFor refundRequested order
    (MkRiskSnapshot HighRisk _ _ _ refund _) clientEnd serverEnd = do
  let assessment : Assessment HighRisk n c = MkAssessment order (riskReason order)
  _ <- par (serverHighRisk refund assessment serverEnd)
           (clientHighRisk refund refundRequested order clientEnd)
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
