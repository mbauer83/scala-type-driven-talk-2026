||| Six booking demos + three Idris-only demos
||| demonstrating capabilities not expressible in Scala 3.
module Main

import System
import System.Concurrency
import Data.Vect

import SessionTypes
import Domain
import Rules
import Channel

%default covering

-- ─── Sample data ──────────────────────────────────────────────────────────────

frankfurtLondonFlight : Flight
frankfurtLondonFlight = MkFlight "LH404" "JFK" "LHR" 450.0

londonSearch : Nat -> SearchCriteria
londonSearch n = MkSearch "JFK" "LHR" "2026-06-15" n

-- ─── Server: refundable booking ───────────────────────────────────────────────

serverProcessRefundable : (n : Nat) -> Session (dual (refundableProtocol n)) -> IO ()
serverProcessRefundable n session = do
  (criteria, searching)    <- receiveLogged {a = SearchCriteria} session
  let found = filter (\f => f.origin == "JFK" && f.destination == "LHR") [frankfurtLondonFlight]
  let result = MkResult (not (null found)) found
  quoting                  <- sendLogged searching result
  (passengers, pricing)    <- receiveLogged {a = Passengers n} quoting
  let quote = MkQuote 450.0 (passengerCount passengers)
  holding                  <- sendLogged pricing quote
  let hold = MkHold ("hold-" ++ show n) 15
  offering                 <- sendLogged holding hold
  choice <- awaitChoice offering
  case choice of
    Left takingPayment => do
      (payment, paid)  <- receiveLogged {a = PaymentFor n} takingPayment
      case validatePayment payment quote of
        Right _ => do
          let tickets = issueTickets passengers frankfurtLondonFlight
          ticketed     <- sendLogged paid tickets
          finish ticketed
        Left err => note ("SERVER: payment failed: " ++ err)
    Right cancelling => do
      let cancellation = MkCancellation hold.holdId "Booking cancelled, no charge"
      cancelled        <- sendLogged cancelling cancellation
      finish cancelled

-- ─── Server: non-refundable ───────────────────────────────────────────────────

serverProcessNonRefundable : (n : Nat) -> Session (dual (nonRefundableProtocol n)) -> IO ()
serverProcessNonRefundable n session = do
  (_, searching)           <- receive {a = SearchCriteria} session
  quoting                  <- sendLogged searching (MkResult True [frankfurtLondonFlight])
  (passengers, pricing)    <- receive {a = Passengers n} quoting
  let quote = MkQuote 450.0 (passengerCount passengers)
  holding                  <- sendLogged pricing quote
  offering                 <- sendLogged holding (MkHold "hold-nr" 15)
  (_, paid)                <- receive {a = PaymentFor n} offering
  ticketed                 <- sendLogged paid (issueTickets passengers frankfurtLondonFlight)
  finish ticketed

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 1 — Happy path
-- ══════════════════════════════════════════════════════════════════════════════

demo1 : IO ()
demo1 = do
  section "DEMO 1 — Happy Path  (n=2, refundable, pay branch)"
  let n = 2
  (clientEnd, serverEnd) <- openSession (refundableProtocol n)
  tid       <- fork (serverProcessRefundable n serverEnd)
  searching <- sendLogged clientEnd (londonSearch n)
  (result, reviewing)      <- receiveLogged {a = SearchResult} searching
  note ("Availability: " ++ show result.available)
  pricing   <- sendLogged reviewing (unsafePassengers n)
  (quote, holding)         <- receiveLogged {a = Quote n} pricing
  note ("Quote total: " ++ show (totalAmount quote))
  (hold, deciding)         <- receiveLogged {a = HoldConfirmation} holding
  note ("Hold: " ++ hold.holdId)
  paying    <- selectLeft deciding
  ticketing <- sendLogged paying (MkPayment (totalAmount quote) "tok_visa")
  (tickets, done)          <- receiveLogged {a = Tickets n} ticketing
  finish done
  threadWait tid
  outcome ("Tickets: " ++ show (toList tickets.codes))

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 2 — Cancellation
-- ══════════════════════════════════════════════════════════════════════════════

demo2 : IO ()
demo2 = do
  section "DEMO 2 — Cancellation  (n=1, choose cancel branch)"
  let n = 1
  (clientEnd, serverEnd) <- openSession (refundableProtocol n)
  tid       <- fork (serverProcessRefundable n serverEnd)
  searching <- sendLogged clientEnd (londonSearch n)
  (_, reviewing)           <- receive {a = SearchResult} searching
  pricing   <- sendLogged reviewing (unsafePassengers n)
  (_, holding)             <- receive {a = Quote n} pricing
  (_, deciding)            <- receive {a = HoldConfirmation} holding
  cancelling               <- selectRight deciding
  (cancellation, done)     <- receiveLogged {a = CancellationConfirmation} cancelling
  finish done
  threadWait tid
  outcome ("Cancelled: " ++ cancellation.message)

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 3 — No availability
-- ══════════════════════════════════════════════════════════════════════════════

demo3 : IO ()
demo3 = do
  section "DEMO 3 — No Availability  (short protocol, End after result)"
  (clientEnd, serverEnd) <- openSession noAvailabilityProtocol
  tid <- fork $ do
    (_, searching) <- receive {a = SearchCriteria} serverEnd
    done           <- sendLogged searching (MkResult False [])
    finish done
  searching          <- sendLogged clientEnd (MkSearch "JFK" "NRT" "2026-06-15" 1)
  (result, done)     <- receiveLogged {a = SearchResult} searching
  finish done
  threadWait tid
  outcome ("available=" ++ show result.available ++ ", flights=" ++ show (length result.flights))

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 4 — Invalid passengers
-- ══════════════════════════════════════════════════════════════════════════════

demo4 : IO ()
demo4 = do
  section "DEMO 4 — Invalid Passengers  (domain boundary validation)"
  case validatePassengers 0 of
    Left  e => note ("validatePassengers 0  -> Left:  " ++ e)
    Right p => note ("validatePassengers 0  -> Right: " ++ show p)
  case validatePassengers 10 of
    Left  e => note ("validatePassengers 10 -> Left:  " ++ e)
    Right p => note ("validatePassengers 10 -> Right: " ++ show p)
  case validatePassengers 2 of
    Left  e => note ("validatePassengers 2  -> Left:  " ++ e)
    Right p => note ("validatePassengers 2  -> Right: " ++ show p)
  outcome "Validation prevents entering the protocol with bad data"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 5 — Payment mismatch + Vect
-- ══════════════════════════════════════════════════════════════════════════════

demo5 : IO ()
demo5 = do
  section "DEMO 5 — Payment Mismatch + Vect-backed Tickets"
  let quote : Quote 2          = MkQuote 450.0 2
  let correctPayment : PaymentFor 2 = MkPayment 900.0 "tok_ok"
  let shortPayment   : PaymentFor 2 = MkPayment 500.0 "tok_bad"
  note ("Quote total: " ++ show (totalAmount quote))
  note ("Correct payment: " ++ show (validatePayment correctPayment quote))
  note ("Short   payment: " ++ show (validatePayment shortPayment   quote))
  -- The following would be a TYPE ERROR (PaymentFor 3 vs Quote 2):
  --   let wrong : PaymentFor 3 = MkPayment 1350.0 "tok"
  --   validatePayment wrong quote   -- ERROR: type mismatch
  note "Vect n String for Tickets:"
  note ("  issueTickets (unsafePassengers 3) frankfurtLondonFlight = " ++
        show (issueTickets (unsafePassengers 3) frankfurtLondonFlight))
  note "  (Cannot construct Vect 3 with 2 elements — type error)"
  outcome "PaymentFor[3] vs Quote[2] is a type error; Vect n enforces exact ticket count"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 6 — Policy DSL catamorphism
-- ══════════════════════════════════════════════════════════════════════════════

demo6 : IO ()
demo6 = do
  section "DEMO 6 — Policy DSL: catamorphism (same as Scala, but built-in Functor)"
  let flexiblePolicy = refundable (minStay 2 (requiresIdentification noConstraint))
  let strictPolicy   = both (nonRefundable noConstraint) (minStay 5 noConstraint)
  note ("Flexible: " ++ describe flexiblePolicy)
  note ("  analyze: " ++ show (analyze flexiblePolicy))
  note ("Strict:   " ++ describe strictPolicy)
  note ("  analyze: " ++ show (analyze strictPolicy))
  outcome "Catamorphism: one recursion shared by all interpretations"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 7 — dualInvolution theorem
-- ══════════════════════════════════════════════════════════════════════════════

demo7 : IO ()
demo7 = do
  section "DEMO 7 — Compiler-verified dualInvolution theorem"
  note "In Scala: individual summon[Dual[Dual[P]] =:= P] per concrete P."
  note "In Idris: one proof, universally quantified over ALL SessionType values."
  note ""
  note "Theorem (from SessionTypes.idr):"
  note "  dualInvolution : (p : SessionType) -> dual (dual p) = p"
  note "  dualInvolution End          = Refl"
  note "  dualInvolution (Send a p)   = cong (Send a) (dualInvolution p)"
  note "  dualInvolution (Receive a p)= cong (Receive a) (dualInvolution p)"
  note "  dualInvolution (Choose l r) ="
  note "    rewrite dualInvolution l in rewrite dualInvolution r in Refl"
  note "  dualInvolution (Offer l r)  = (same)"
  note ""
  note "This file ONLY COMPILES if the proof is correct."
  note "The proof is checked by Idris's type checker (dependent elimination)."
  outcome "No runtime check needed — the proof is a compile-time certificate"

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 8 — Runtime n in session type (IMPOSSIBLE IN SCALA)
-- ══════════════════════════════════════════════════════════════════════════════

demo8 : IO ()
demo8 = do
  section "DEMO 8 — Runtime n in Session Type  (NOT POSSIBLE IN SCALA)"
  note "In Scala: Transport.open[BookingProtocol.Refundable[n]]"
  note "  -- n MUST be a compile-time literal (e.g. 2, 3)."
  note "  -- Passengers.of(readLine().toInt) returns Either[String, Passengers[???]]"
  note "  -- The ??? type cannot be expressed."
  note ""
  note "In Idris: refundableProtocol n is a SessionType VALUE computed from n."
  note "  -- n can be ANY Nat, including one from getLine."
  note ""

  -- Get n from command-line args (falls back to 4 if not given)
  args <- getArgs
  let n : Nat = case args of
        (_ :: nStr :: _) => cast (the Integer (cast nStr))
        _                => 4

  note ("n from args (or default): " ++ show n)

  case validatePassengers n of
    Left err => do
      note ("Invalid: " ++ err)
      outcome "Validation failed — no session created"
    Right passengers => do
      -- THIS is the key line: refundableProtocol n computes the SessionType from n.
      -- The type of (clientEnd, serverEnd) depends on n, a runtime value.
      note ("Creating Session (refundableProtocol " ++ show n ++ ")")
      (clientEnd, serverEnd) <- openSession (refundableProtocol n)
      tid       <- fork (serverProcessRefundable n serverEnd)
      searching <- sendLogged clientEnd (londonSearch n)
      (_, reviewing)         <- receive {a = SearchResult} searching
      pricing   <- sendLogged reviewing passengers
      (quote, holding)       <- receive {a = Quote n} pricing
      (_, deciding)          <- receive {a = HoldConfirmation} holding
      paying    <- selectLeft deciding
      ticketing <- sendLogged paying (MkPayment (totalAmount quote) "tok_runtime")
      (tickets, done)        <- receive {a = Tickets n} ticketing
      finish done
      threadWait tid
      outcome ("n=" ++ show n ++ " tickets: " ++ show (length (toList tickets.codes)))

-- ══════════════════════════════════════════════════════════════════════════════
-- Demo 9 — protocolDerivedFrom: protocol computed from Policy (IMPOSSIBLE IN SCALA)
-- ══════════════════════════════════════════════════════════════════════════════

demo9 : IO ()
demo9 = do
  section "DEMO 9 — Protocol Derived from Policy  (NOT POSSIBLE IN SCALA)"
  note "In Scala: SelectedVariant enum enumerates fixed variants at compile time."
  note "  ProtocolVariant.selectFrom(caps) -> Refundable | NonRefundable"
  note "  Then a match selects which pre-defined protocol to instantiate."
  note ""
  note "In Idris: protocolDerivedFrom n policy : SessionType"
  note "  A total function.  No enum.  No bridge.  No seam."
  note ""

  let n : Nat  = 2
  let policy1  = refundable (minStay 3 noConstraint)
  let policy2  = both (nonRefundable noConstraint) (minStay 7 noConstraint)

  note ("Policy 1: " ++ describe policy1)
  note ("  permitsCancellation = " ++ show (permitsCancellation policy1))
  note ("  protocolDerivedFrom " ++ show n ++ " policy1 = refundableProtocol " ++ show n)

  note ("Policy 2: " ++ describe policy2)
  note ("  permitsCancellation = " ++ show (permitsCancellation policy2))
  note ("  protocolDerivedFrom " ++ show n ++ " policy2 = nonRefundableProtocol " ++ show n)

  -- In Scala: you need a ProtocolVariant enum and ProtocolVariant.selectFrom to bridge
  --           runtime capabilities to compile-time types.  The set of variants is fixed.
  -- In Idris: protocolDerivedFrom is a total function that computes a SessionType VALUE.
  --           Case-splitting on the same condition gives exact types — no enum, no seam.
  note "--- Running protocol derived from policy1 ---"
  case permitsCancellation policy1 of
    True => do
      -- protocolDerivedFrom n policy1 = refundableProtocol n  (by definition, True branch)
      (clientEnd, serverEnd) <- openSession (refundableProtocol n)
      tid       <- fork (serverProcessRefundable n serverEnd)
      searching <- sendLogged clientEnd (londonSearch n)
      (_, reviewing)         <- receive {a = SearchResult} searching
      pricing   <- sendLogged reviewing (unsafePassengers n)
      (quote, holding)       <- receive {a = Quote n} pricing
      (_, deciding)          <- receive {a = HoldConfirmation} holding
      paying    <- selectLeft deciding
      ticketing <- sendLogged paying (MkPayment (totalAmount quote) "tok_derived")
      (tickets, done)        <- receive {a = Tickets n} ticketing
      finish done
      threadWait tid
      outcome ("Derived protocol executed — " ++ show (length (toList tickets.codes)) ++ " tickets")
    False => do
      -- protocolDerivedFrom n policy1 = nonRefundableProtocol n  (False branch)
      (clientEnd, serverEnd) <- openSession (nonRefundableProtocol n)
      tid       <- fork (serverProcessNonRefundable n serverEnd)
      searching <- sendLogged clientEnd (londonSearch n)
      (_, reviewing)         <- receive {a = SearchResult} searching
      pricing   <- sendLogged reviewing (unsafePassengers n)
      (quote, holding)       <- receive {a = Quote n} pricing
      (_, deciding)          <- receive {a = HoldConfirmation} holding
      ticketing <- sendLogged deciding (MkPayment (totalAmount quote) "tok_derived")
      (tickets, done)        <- receive {a = Tickets n} ticketing
      finish done
      threadWait tid
      outcome ("Derived protocol executed — " ++ show (length (toList tickets.codes)) ++ " tickets")

-- ─── Entry point ─────────────────────────────────────────────────────────────

main : IO ()
main = do
  demo1
  demo2
  demo3
  demo4
  demo5
  demo6
  demo7
  demo8
  demo9
