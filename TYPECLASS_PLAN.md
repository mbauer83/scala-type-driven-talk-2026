# Implementation Plan: Typeclass-Only Variant

A third implementation — alongside the existing Scala 3 (subtyping + match types) and Idris 2
versions — demonstrating the same session-type guarantees using **only typeclasses and
`compiletime`**, with no subtyping in the application code and no match types.

---

## Motivation

The existing Scala implementation uses two subtyping mechanisms:

| Site | Mechanism | Purpose |
|---|---|---|
| `sealed trait Protocol` + `<: Protocol` bounds | Nominal subtyping | Close the session-type grammar |
| `type Dual[P <: Protocol] = P match { … }` | Match type (type-level function) | Compute the dual of a protocol type |
| `N <: Int & Singleton` on `Passengers[N]`, `Quote[N]`, etc. | Singleton literal subtyping | Thread the passenger count as a type-level index |
| `Tickets[N](codes: List[String])` | None — runtime `require` | Ticket count *not* enforced by the type |

The typeclass-only version eliminates all four. The key insight for the `N <: Int` problem is
Haskell's `KnownNat n` pattern: wrap the singleton bound inside a typeclass so that domain
types carry an unconstrained type parameter `N`, and operations require `KnownNat[N]` evidence
rather than a structural bound. The `compiletime.constValue` mechanism delivers the runtime
integer from the type without exposing `<: Int` to callers.

`KnownNat[N]` also unlocks a proper `Vec[N, A]` using `compiletime.ops.int` arithmetic — so
`Tickets[N]` can carry a `Vec[N, String]` that statically guarantees the ticket count, which the
current implementation cannot do (it uses `List` with a runtime `require`).

---

## Design decisions

### 1. Protocol grammar — `IsProtocol[P]` replaces `<: Protocol`

```scala
// Current: subtyping closes the grammar
sealed trait Protocol
final class Send[A, Next <: Protocol] extends Protocol

// Proposed: phantom types + typeclass
final class Send[A, Next]       // no extends, no bound
final class Receive[A, Next]
final class Choose[L, R]
final class Offer[L, R]
sealed abstract class End
object End extends End

sealed trait IsProtocol[P]        // sealed = no instances outside this file
object IsProtocol:
  given IsProtocol[End]                                      = ???
  given [A, N: IsProtocol]: IsProtocol[Send[A, N]]          = ???
  given [A, N: IsProtocol]: IsProtocol[Receive[A, N]]       = ???
  given [L: IsProtocol, R: IsProtocol]: IsProtocol[Choose[L, R]] = ???
  given [L: IsProtocol, R: IsProtocol]: IsProtocol[Offer[L, R]]  = ???
```

Every function that currently takes `P <: Protocol` instead takes `[P: IsProtocol]`.

**Trade-off**: The grammar is still closed (sealed), but it is now *open-world* in principle —
any external code could add `given IsProtocol[MyType]` *if* the `given` instances were not
inside the `sealed` object. Because they are, the guarantee is preserved. The compiler cannot
prove `IsProtocol[String]` without an instance in scope, so `Send[Int, String]` cannot
be used as a valid session type.

### 2. Duality — `HasDual[P]` replaces the match type

```scala
// Current: match type; Dual[P] is a type-level function
type Dual[P <: Protocol] <: Protocol = P match
  case Send[a, n]  => Receive[a, Dual[n]]
  …

// Proposed: associated-type typeclass (Haskell type-family style)
sealed trait HasDual[P]:
  type DualOf          // the dual of P; no bound — IsProtocol constraint is separate

object HasDual:
  type Aux[P, Q] = HasDual[P] { type DualOf = Q }   // Aux pattern for equational use

  given HasDual[End] with { type DualOf = End }

  given [A, N, M](using HasDual.Aux[N, M]): HasDual[Send[A, N]] with
    type DualOf = Receive[A, M]

  given [A, N, M](using HasDual.Aux[N, M]): HasDual[Receive[A, N]] with
    type DualOf = Send[A, M]

  given [L1, R1, L2, R2](using HasDual.Aux[L1, L2], HasDual.Aux[R1, R2]):
    HasDual[Choose[L1, R1]] with { type DualOf = Offer[L2, R2] }

  given [L1, R1, L2, R2](using HasDual.Aux[L1, L2], HasDual.Aux[R1, R2]):
    HasDual[Offer[L1, R1]] with { type DualOf = Choose[L2, R2] }
```

`Transport.open` signature changes from:

```scala
// Current: match type in return position
def open[P <: Protocol]: (Channel[P], Channel[Dual[P]])

// Proposed: associated type in return position
def open[P](using d: HasDual[P]): (Session[P], Session[d.DualOf])
```

The return type `Session[d.DualOf]` uses a **path-dependent type** on `d`. This is not
subtyping — it is DOT-style membership type. The compiler resolves `d.DualOf` by finding the
unique `HasDual[P]` instance (sealed, so deterministic) and reading its `DualOf` member.

**Involution** — `Dual[Dual[P]] = P` — is expressed as a pair of constraints that the compiler
can satisfy through implicit search:

```scala
// Rather than summon[Dual[Dual[P]] =:= P] over a match type:
def checkInvolution[P, Q](using HasDual.Aux[P, Q], HasDual.Aux[Q, P]): Unit = ()
// Compiler must find both directions; the given instances are exactly symmetric.
```

**Trade-off**: With the match type you can write `Session[Dual[P]]` as a standalone type in
any context. With `HasDual[P]`, the dual type is only accessible as `d.DualOf` where `d` is a
stable `HasDual[P]` evidence value in scope. This makes it slightly harder to name the dual type
in non-local contexts (e.g., in a type alias). The `Aux` pattern mostly covers this:
`HasDual.Aux[P, Q]` brings `Q = Dual(P)` into scope as a named type variable.

### 3. Phantom-type grammar operations — `CanSend[P]`, `CanReceive[P]`, etc.

These are already typeclasses in the current implementation. The only change is dropping the
`<: Protocol` bounds:

```scala
// Current
sealed trait CanReceive[P <: Protocol]:
  type Msg
  type Rest <: Protocol

// Proposed
sealed trait CanReceive[P]:
  type Msg
  type Rest

object CanReceive:
  given [A, N]: CanReceive[Receive[A, N]] with
    type Msg  = A
    type Rest = N
```

The `Session.receive()` signature is unchanged:

```scala
def receive()(using r: CanReceive[P]): (r.Msg, Session[r.Rest])
```

### 4. Passenger count — `KnownNat[N]` replaces `N <: Int & Singleton`

```scala
// Current: bound on every domain type
final case class Passengers[N <: Int] private(count: Int)
def of[N <: Int & Singleton](n: N): Either[String, Passengers[N]]

// Proposed: unconstrained N; constraint lives only in the typeclass
final case class Passengers[N] private(count: Int)

sealed trait KnownNat[N]:
  def value: Int

object KnownNat:
  // The bound appears ONCE, inside the derivation machinery, hidden from users.
  transparent inline given [N <: Int & Singleton]: KnownNat[N] =
    new KnownNat[N] { val value = scala.compiletime.constValue[N] }
```

Domain type declarations:

```scala
final case class Passengers[N] private (count: Int)
final case class Quote[N](perPersonAmount: BigDecimal, passengerCount: Int)
final case class PaymentFor[N](amount: BigDecimal, cardToken: String)
final case class Tickets[N](codes: Vec[N, String])   // see §5
```

Smart constructor:

```scala
object Passengers:
  // Callers write Passengers.of(2) — identical to current API.
  // N <: Int & Singleton is not visible; KnownNat is the only evidence needed.
  inline def of[N](inline n: N)(using KnownNat[N]): Either[String, Passengers[N]] =
    val v = summon[KnownNat[N]].value
    if v >= 1 && v <= 9 then Right(new Passengers[N](v))
    else Left(s"Passenger count must be 1–9, got $v")
```

`PaymentFor.validate` and `Tickets.issue` work unchanged — they just require `KnownNat[N]`
in context, which the compiler supplies automatically for any literal call site.

### 5. `Vec[N, A]` — compile-time-sized vector via `compiletime.ops.int`

The current `Tickets[N](codes: List[String])` uses a `List` with a runtime `require`. The
typeclass version replaces this with a proper fixed-size vector where the length is tracked
in the type.

```scala
import scala.compiletime.ops.int.*

// Opaque type: at runtime it is an IndexedSeq[A]; at compile time it carries N.
opaque type Vec[N <: Int, +A] = scala.collection.immutable.ArraySeq[A]

object Vec:
  /** Build a Vec[N, A] by applying f to each index 0 until N. */
  inline def tabulate[N <: Int & Singleton, A](f: Int => A)(using KnownNat[N]): Vec[N, A] =
    ArraySeq.tabulate(summon[KnownNat[N]].value)(f)

  /** Concatenation: Vec[M, A] ++ Vec[K, A] = Vec[M + K, A] — size arithmetic in the type. */
  def concat[M <: Int, K <: Int, A](a: Vec[M, A], b: Vec[K, A]): Vec[M + K, A] =
    a ++ b   // M + K is computed by compiletime.ops.int.+

  extension [N <: Int, A](v: Vec[N, A])
    def toList: List[A]               = v.toList
    def apply(i: Int): A              = v(i)
    def length(using KnownNat[N]): Int = summon[KnownNat[N]].value
```

`Tickets.issue` now produces a `Vec` with exactly the right size:

```scala
object Tickets:
  def issue[N <: Int & Singleton](pax: Passengers[N], flight: Flight)
      (using KnownNat[N]): Tickets[N] =
    Tickets(Vec.tabulate[N, String](i => s"${flight.flightNumber}-${('A' + i).toChar}"))
```

The runtime `require` in `Tickets` disappears. The type system now proves ticket count = passenger count.

**New capability**: size arithmetic is expressible as types:

```scala
// Split a group booking into two legs — sizes must add up
def splitTickets[M <: Int, K <: Int](combined: Vec[M + K, String]): (Vec[M, String], Vec[K, String])
```

This is not possible in the current implementation.

### 6. Protocol derivation — `ProtocolVariant` stays; shape types are narrowed

The `ProtocolVariant` enum and the `interpret`-based derivation are unchanged. The protocol
shape type aliases change only in their bounds:

```scala
// Current
type RefundableBooking[N <: Int] = Send[SearchCriteria, Receive[SearchResult, Send[Passengers[N], …]]]

// Proposed — no bound on N at all
type RefundableBooking[N] = Send[SearchCriteria, Receive[SearchResult, Send[Passengers[N], …]]]
```

Operations on sessions of type `Session[RefundableBooking[N]]` require `KnownNat[N]` in scope
(surfaced naturally when `Passengers[N]` or `Quote[N]` is used), so the absence of the bound
on the type alias does not lose any safety.

### 7. `Fix[F]` + catamorphism — no change

`Fix[F[_]]` and `interpret[F[_]: Functor, A]` are already fully typeclass-based. They are
copied unchanged.

---

## File layout

```
typeclass/
├── build.sbt                         ← new sbt sub-project
└── src/
    ├── main/scala/
    │   ├── protocol/
    │   │   ├── Protocol.scala        ← phantom types (no sealed trait, no extends)
    │   │   ├── IsProtocol.scala      ← IsProtocol[P] typeclass
    │   │   ├── HasDual.scala         ← HasDual[P] typeclass + Aux pattern
    │   │   └── Evidence.scala        ← CanSend, CanReceive, CanChoose, CanOffer (no bounds)
    │   ├── domain/
    │   │   ├── KnownNat.scala        ← KnownNat[N] typeclass (constValue-backed)
    │   │   ├── Vec.scala             ← Vec[N, A] opaque type + compiletime.ops.int
    │   │   └── Domain.scala          ← Passengers[N], Quote[N], PaymentFor[N], Tickets[N]
    │   ├── rules/
    │   │   ├── PolicyF.scala         ← unchanged copy
    │   │   ├── Fix.scala             ← unchanged copy
    │   │   └── Interpretations.scala ← unchanged copy
    │   ├── runtime/
    │   │   ├── Session.scala         ← Session[P] (no P <: Protocol bound)
    │   │   └── Transport.scala       ← open[P](using HasDual[P])
    │   └── demos/
    │       ├── BookingProtocol.scala ← type aliases with no N <: Int bounds
    │       └── BookingDemo.scala     ← same 6 demos; proof style changes in demo 6
    └── test/scala/
        ├── DomainTests.scala         ← same domain validation tests
        ├── DualityTests.scala        ← involution via HasDual.Aux pairs instead of summon[=:=]
        ├── VecTests.scala            ← new: Vec concat, tabulate, length arithmetic
        └── IntegrationTests.scala    ← same 3 integration scenarios
```

The new sub-project is added to the existing `build.sbt`:

```scala
lazy val typeclass = project
  .in(file("typeclass"))
  .settings(
    name         := "scala-type-driven-talk-typeclass",
    scalaVersion := scala3Version,
    libraryDependencies ++= Seq(
      "org.typelevel" %% "cats-core" % "2.13.0",
      "org.scalameta" %% "munit"     % "1.0.3" % Test,
    ),
    scalacOptions ++= Seq("-deprecation", "-feature"),
    Compile / mainClass := Some("demos.BookingDemo"),
  )
```

---

## What is gained vs what is lost

### Gained

| Gain | Detail |
|---|---|
| No `<: Protocol` anywhere in application code | Domain types, protocol shapes, session ops — all constraint-free type params |
| No `N <: Int` on domain types | `Passengers[N]`, `Quote[N]`, `PaymentFor[N]`, `Tickets[N]` carry unconstrained `N` |
| `Tickets[N]` statically sized | `Vec[N, String]` replaces `List[String]` + runtime `require`; ticket count = passenger count *in the type* |
| `Vec` size arithmetic | `Vec[M, A] ++ Vec[K, A] : Vec[M + K, A]` — impossible in the current version |
| Open-world in principle | `IsProtocol` could be extended if the `sealed` constraint is relaxed — current version cannot |
| Closer to Haskell / OCaml style | `KnownNat`, `HasDual`, `IsProtocol` map directly onto Haskell typeclasses and Rust traits |

### Lost / traded

| Cost | Detail |
|---|---|
| `Session[Dual[P]]` as a standalone type | With `HasDual`, the dual type is only `d.DualOf` where `d` is in scope; `Aux` pattern covers most cases but is more verbose |
| `summon[Dual[Dual[P]] =:= P]` | Match-type involution is a direct compiler reduction; typeclass involution requires both `HasDual.Aux[P, Q]` and `HasDual.Aux[Q, P]` in scope simultaneously |
| One instance of `N <: Int & Singleton` survives | It is hidden inside `KnownNat`'s `given` derivation — invisible to callers, but present in the library layer |
| Slightly more `using` noise at function boundaries | Every `[P <: Protocol]` becomes `[P: IsProtocol]`; rare in demos but visible in the runtime layer |

---

## Implementation sequence

These steps are ordered by dependency; each is independently testable before the next begins.

1. **`protocol/Protocol.scala`** — copy the five phantom type declarations, remove all `extends Protocol` and `<: Protocol` bounds. No logic, just declarations.

2. **`protocol/IsProtocol.scala`** — `sealed trait IsProtocol[P]` with five `given` instances (recursive for `Send`, `Receive`, `Choose`, `Offer`). Write a compile-time sanity check: `summon[IsProtocol[Send[Int, Receive[String, End]]]]`.

3. **`protocol/HasDual.scala`** — `sealed trait HasDual[P]` with `type DualOf`, five instances, and the `Aux` type alias. Write compile-time checks for all base cases and the involution property using the `Aux`-pair pattern.

4. **`protocol/Evidence.scala`** — `CanSend`, `CanReceive`, `CanChoose`, `CanOffer` — drop `<: Protocol` from all bounds. Copy the existing `given` instances verbatim minus the bounds.

5. **`domain/KnownNat.scala`** — `sealed trait KnownNat[N]` with one `transparent inline given` backed by `compiletime.constValue`. Verify `summon[KnownNat[2]].value == 2` in a test.

6. **`domain/Vec.scala`** — `opaque type Vec[N <: Int, +A]` backed by `ArraySeq[A]`. Implement `tabulate`, `concat`, `toList`, `length`. Write `VecTests` covering: `tabulate` size, `concat` type-level addition, element access.

7. **`domain/Domain.scala`** — rewrite domain types without `N <: Int` bounds. `Tickets[N]` now wraps `Vec[N, String]`. Update `Passengers.of` to use `KnownNat[N]`. Remove the `require` from `Tickets`.

8. **`rules/`** — copy `PolicyF.scala`, `Fix.scala`, `Interpretations.scala` unchanged.

9. **`runtime/Session.scala`** — copy `Chan.scala`, remove `P <: Protocol` from `Session[P]` declaration and from all `CanSend[P]` / `CanReceive[P]` usages (bounds already removed in step 4). Add `[P: IsProtocol]` where necessary.

10. **`runtime/Transport.scala`** — rewrite `open` to use `HasDual`: `def open[P](using d: HasDual[P]): (Session[P], Session[d.DualOf])`.

11. **`demos/BookingProtocol.scala`** — copy protocol shape type aliases, remove all `N <: Int` bounds from `RefundableBooking[N]`, `NonRefundableBooking[N]`. Rewrite `DualityVerification` using `HasDual.Aux` pairs.

12. **`derivation/ProtocolDerivation.scala`** — copy unchanged; `ProtocolVariant` and `Capability` are value-level and do not involve the new mechanisms.

13. **`demos/BookingDemo.scala`** — copy all six demos. Call sites for `Passengers.of(2)` are identical. Invocation of `Transport.open` now requires `HasDual[P]` in scope — provided automatically by the compiler for all concrete protocol types.

14. **Tests** — copy `DomainTests`, `IntegrationTests`, update `DualityTests` to use `Aux`-pair involution checks, add `VecTests`.

---

## Comparison table across all three implementations

| Property | Scala (subtyping) | Scala (typeclass) | Idris 2 |
|---|---|---|---|
| Protocol grammar closure | `sealed trait` + `<: Protocol` | `sealed trait IsProtocol[P]` | `data SessionType` (ADT) |
| Duality | `Dual[P]` match type | `HasDual[P]` associated type | `dual : SessionType -> SessionType` total function |
| `N` in domain types | `N <: Int & Singleton` | `KnownNat[N]` (unconstrained `N`) | `n : Nat` (plain value) |
| Ticket vector | `List[String]` + runtime `require` | `Vec[N, String]` (compile-time sized) | `Vect n String` (compile-time sized) |
| Involution proof | `summon[Dual[Dual[P]] =:= P]` (match type) | `HasDual.Aux[P, Q] + HasDual.Aux[Q, P]` | `dualInvolution : (p : SessionType) -> dual (dual p) = p` |
| Runtime N in session type | Not possible | Not possible | `refundableProtocol n` — `n` from stdin |
| Protocol derived from policy | Enum + bridge | Enum + bridge | `protocolDerivedFrom n policy` — total function |
