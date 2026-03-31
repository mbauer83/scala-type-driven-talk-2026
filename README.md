# Type-Driven Programming in Scala 3
## A Research-Grade Session-Types Demo

A fully runnable Scala 3 project demonstrating the **maximum practical expressiveness** of the type system for session types, duality, affine usage, dependent types, and higher-kinded type programming.

---

## Quick start

```bash
sbt run    # run all 6 demo scenarios
sbt test   # 35 tests (compile-time + runtime)
```

---

## Architecture: Four Strict Layers

| Layer | Package | What lives there |
|-------|---------|-----------------|
| **Protocol** | `protocol/` | `Protocol` ADT, `Dual` match type — **types only** |
| **Domain**   | `domain/`   | Validated data (`Passengers[N]`, `Quote[N]`, `PaymentFor[N]`) |
| **Structure**| `rules/`    | Policy DSL via `Fix[F]` + HKTs, `interpret`, and interpretations |
| **Runtime**  | `runtime/`  | `Channel[P]`, `Transport`, structured logger |

Mixing layers is explicitly forbidden by the design.

---

## Feature showcase

### Match-type Duality (compile-time)

```scala
type Dual[P <: Protocol] <: Protocol = P match
  case End              => End
  case Send[a, n]       => Receive[a, Dual[n]]
  case Receive[a, n]    => Send[a, Dual[n]]
  case Choose[l, r]     => Offer[Dual[l], Dual[r]]
  case Offer[l, r]      => Choose[Dual[l], Dual[r]]
```

`Transport.open[P]` returns `(Channel[P], Channel[Dual[P]])`. It is impossible to create a client/server pair whose protocols don't correspond — this is a **type error**.

All duality proofs in `Dual.scala` and `DualityTests.scala` are verified by the compiler at compile time via `summon[_ =:= _]`.

### Affine Channel Runtime

```scala
class Channel[P <: Protocol]:
  def send[A, Next <: Protocol](value: A)(using CanSend[P]): Channel[Next]
  def receive[A, Next <: Protocol]()(using CanReceive[P]): (A, Channel[Next])
  def selectLeft[L <: Protocol, R <: Protocol]()(using CanChoose[P]): Channel[L]
  def selectRight[L <: Protocol, R <: Protocol]()(using CanChoose[P]): Channel[R]
  def awaitChoice[L <: Protocol, R <: Protocol]()(using CanOffer[P]): Either[Channel[L], Channel[R]]
  def finish()(using P =:= End): Unit
```

Each operation **consumes** the channel and returns a new `Channel[Next]`. Calling `send` on a `Channel[Receive[...]]` is a compile error. Calling any operation twice on the same channel is caught at runtime.

### Dependent Domain Types

```scala
type BookingProtocol[N <: Int] =
  Send[SearchCriteria,
  Receive[SearchResult,
  Send[Passengers[N],
  Receive[Quote[N],
  Receive[HoldConfirmation,
  Choose[
    Send[PaymentFor[N], Receive[Tickets[N], End]],
    Receive[CancellationConfirmation, End]
  ]]]]]]
```

The singleton literal type `N` flows through the entire protocol. Attempting to pay a 2-passenger `Quote[2]` with a `PaymentFor[3]` is a **type error** — caught before the program runs.

### Fix + HKT Policy DSL

The recursion is factored out into `Fix[F]`; all interpretations are written as algebras over `PolicyF[A]` and passed to `interpret`:

```scala
val describe:             Policy => String   // human-readable description
val permitsCancellation:  Policy => Boolean  // can be cancelled?
val minimumNights:        Policy => Int      // minimum-stay constraint
val analyze:              Policy => Analysis // combined single-pass: (cancel, minStay, needsDoc)
```

No interpretation contains recursion. Composition is free — the combined `analyze` is one `interpret` call that produces all three values simultaneously.

### Protocol Derivation from Policy

```
Policy  →  interpret → Set[Capability]  →  ProtocolVariant  →  Channel[RefundableBooking[N]]
                                                                 or
                                                                Channel[NonRefundableBooking[N]]
```

The policy structure is evaluated at runtime; both protocol variants are fully type-checked at compile time.

---

## Guarantees

| Guarantee | Mechanism |
|-----------|-----------|
| Protocol misuse impossible | `CanSend`/`CanReceive`/`CanChoose`/`CanOffer` on every Channel operation |
| Client/server always dual  | `Transport.open[P]: (Channel[P], Channel[Dual[P]])` |
| Payment matches reservation | `PaymentFor[N]` / `Quote[N]` share singleton `N` |
| No illegal passenger count | `Passengers.of(n): Either[String, Passengers[N]]` |
| Policy reuse across interpretations | `interpret[PolicyF, A]` — one recursion, many algebras |

---

## Limitations

- **Linearity is by convention**, not enforced by the compiler. Scala lacks linear types; the `used` flag provides a runtime guard.
- **Singleton N is compile-time only**. `N` must be a literal at call sites (e.g. `BookingProtocol[2]`). Fully dependent typing over runtime-determined `n` requires a language like Idris.
- **Recursive protocols** (`Rec[F]`) are not implemented. Extension is straightforward but was outside the scope of this demo.

---

## Demo scenarios

| Demo | Description |
|------|-------------|
| 1 | Happy path: search → quote → pay → tickets |
| 2 | Cancellation: search → quote → cancel |
| 3 | No availability: search → empty result → End |
| 4 | Invalid passengers: domain validation at the boundary |
| 5 | Payment mismatch: dependent-type enforcement |
| 6 | Protocol derivation: Policy DSL → capabilities → variant selection |

---

## Technology

- **Scala 3.8.3** — match types, dependent function types, opaque types, enums, `inline`, `compiletime.*`, `given`/`using`
- **cats-core** — `Functor[PolicyF]` typeclass instance
- **munit** — unit + integration tests
