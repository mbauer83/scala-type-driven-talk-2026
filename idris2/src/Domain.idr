||| LAYER 2 — Dependent Domain Types
|||
||| Key advances over Scala 3:
|||   • n : Nat is a plain value — not a literal constraint.
|||     validatePassengers n works for ANY Nat, including one read from stdin.
|||   • Tickets n uses Vect n String — exact length guaranteed by the TYPE constructor.
|||     No way to create a Tickets n with the wrong number of codes.
module Domain

import Data.Vect

%default total

-- ─── Raw flight data ──────────────────────────────────────────────────────────

public export
record SearchCriteria where
  constructor MkSearch
  origin      : String
  destination : String
  date        : String
  passengerCount    : Nat

public export
record Flight where
  constructor MkFlight
  flightNumber : String
  origin       : String
  destination  : String
  basePrice    : Double

public export
record SearchResult where
  constructor MkResult
  available : Bool
  flights   : List Flight

public export
record HoldConfirmation where
  constructor MkHold
  holdId         : String
  expiresMinutes : Nat

public export
record CancellationConfirmation where
  constructor MkCancellation
  holdId  : String
  message : String

-- ─── Dependent domain types — indexed by passenger count n ───────────────────

||| Quote for exactly n passengers.
public export
record Quote (n : Nat) where
  constructor MkQuote
  perPersonAmount : Double
  passengers      : Nat

export
totalAmount : Quote n -> Double
totalAmount q = q.perPersonAmount * cast q.passengers

||| Validated passenger count: the phantom index n encodes the count at type level.
||| The only way to obtain a Passengers n is through validatePassengers,
||| which checks 1 <= n <= 9.  After that, the type is the proof.
public export
data Passengers : Nat -> Type where
  MkPassengers : (count : Nat) -> Passengers count

export
passengerCount : Passengers n -> Nat
passengerCount (MkPassengers n) = n

||| Smart constructor: the ONLY public way to create a Passengers n.
|||
||| KEY ADVANCE OVER SCALA:
||| In Scala: Passengers.of(2)  -- 2 must be a compile-time literal
||| In Idris: validatePassengers n  -- n is ANY Nat, including from stdin/args
public export
validatePassengers : (n : Nat) -> Either String (Passengers n)
validatePassengers 0 = Left "Passenger count must be at least 1"
validatePassengers (S k) =
  case isLTE (S k) 9 of
    Yes _ => Right (MkPassengers (S k))
    No  _ => Left  "Passenger count must be at most 9"

||| Unchecked constructor for use in demos where validity is known.
public export
unsafePassengers : (n : Nat) -> Passengers n
unsafePassengers n = MkPassengers n

||| Payment for exactly n passengers.
||| PaymentFor 3 cannot be passed to validatePayment with Quote 2 — type error.
public export
record PaymentFor (n : Nat) where
  constructor MkPayment
  amount    : Double
  cardToken : String

export
validatePayment : PaymentFor n -> Quote n -> Either String (PaymentFor n)
validatePayment pay q =
  if pay.amount == totalAmount q
    then Right pay
    else Left "Payment \{show pay.amount} != quote total \{show (totalAmount q)}"

||| Exactly n flight tickets.
|||
||| KEY ADVANCE OVER SCALA:
||| In Scala: Tickets[N](codes: List[String])  -- length is unchecked
||| In Idris: Tickets n (codes : Vect n String) -- Vect n GUARANTEES the count
|||
||| You cannot construct Vect 3 String with 2 elements.
||| issueTickets (unsafePassengers 3) ... always returns Tickets 3 — by type.
public export
record Tickets (n : Nat) where
  constructor MkTickets
  codes : Vect n String

export
issueTickets : Passengers n -> Flight -> Tickets n
issueTickets (MkPassengers n) flight = MkTickets (buildCodes n 1)
  where
    buildCodes : (m : Nat) -> Nat -> Vect m String
    buildCodes 0     _ = []
    buildCodes (S k) i =
      (flight.flightNumber ++ "-" ++ show i) :: buildCodes k (i + 1)

-- ─── Show instances ───────────────────────────────────────────────────────────

export
Show (Passengers n) where
  show (MkPassengers n) = "Passengers(" ++ show n ++ ")"

export
Show (Quote n) where
  show q = "Quote(per=" ++ show q.perPersonAmount ++ ", n=" ++ show q.passengers ++ ")"

export
Show (PaymentFor n) where
  show p = "PaymentFor(" ++ show p.amount ++ ", " ++ p.cardToken ++ ")"

export
Show (Tickets n) where
  show t = "Tickets(" ++ show (toList t.codes) ++ ")"

export
Show SearchCriteria where
  show s = "Search(" ++ s.origin ++ "->" ++ s.destination
        ++ " " ++ s.date ++ " pax=" ++ show s.passengerCount ++ ")"

export
Show Flight where
  show f = "Flight(" ++ f.flightNumber ++ " " ++ f.origin ++ "->" ++ f.destination ++ ")"

export
Show HoldConfirmation where
  show h = "Hold(" ++ h.holdId ++ " " ++ show h.expiresMinutes ++ "min)"

export
Show SearchResult where
  show r = "SearchResult(available=" ++ show r.available
        ++ ", flights=" ++ show (length r.flights) ++ ")"

export
Show CancellationConfirmation where
  show c = "Cancelled(" ++ c.message ++ ")"
