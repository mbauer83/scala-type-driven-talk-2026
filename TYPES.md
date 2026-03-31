# The Type Safety Ladder

## From "it might crash" to "it cannot compile wrong"

This document climbs a sequence of type systems, each one catching a strictly larger class of errors at compile time. Every rung is motivated by a bug the previous rung could not prevent. The final rung is this project.

Code examples start in vanilla JavaScript (no types at all) and move to Scala as the type system becomes sophisticated enough to require it. Each stage names its theoretical position so you can calibrate how much expressive power has been added and what new class of error is now ruled out.

---

## Stage 0 — No types: vanilla JavaScript

**Type theory position:** Untyped lambda calculus (λ)

In the beginning, there is only runtime.

```javascript
function bookFlight(criteria, passengers) {
  const quote   = getQuote(criteria, passengers)
  const hold    = reserveSeat(criteria)
  const payment = { amount: quote.perPerson * passengers, token: "tok_abc" }
  return issueTickets(hold, payment)
}
```

There is no description of what `criteria` is, what `passengers` must look like, whether `getQuote` must be called before `reserveSeat`, or whether `payment.amount` is correct. The function is a bag of hope.

**Errors caught at compile time:** none.

**Errors discovered:** at runtime, in production, by crashing.

Typical bugs:
- `passengers` is `undefined` — `quote.perPerson * undefined` silently produces `NaN`
- `reserveSeat` called before `getQuote` — wrong protocol order, undetectable
- `payment` covers 3 passengers but the hold is for 2 — silently wrong
- `issueTickets` called twice on a consumed hold

---

## Stage 1 — Simple types: STLC

**Type theory position:** Simply Typed Lambda Calculus (λ→)

Assign a fixed base type to every variable. Function types `A → B` describe what a function accepts and returns. The type checker rejects any program where these annotations are inconsistent.

```typescript
interface SearchCriteria { origin: string; destination: string; date: string }
interface Quote          { perPerson: number; passengers: number }
interface Hold           { holdId: string }
interface Payment        { amount: number; token: string }
interface Tickets        { codes: string[] }

function getQuote(c: SearchCriteria, passengers: number): Quote { ... }
function reserveSeat(c: SearchCriteria): Hold { ... }
function issueTickets(hold: Hold, payment: Payment): Tickets { ... }
```

**New errors caught:**
- Passing a `string` where a `number` is expected
- Calling `issueTickets(payment, hold)` — the types of the two arguments cannot be swapped
- Accessing `.perPerson` on a `Hold` — the field does not exist on that type

**Errors still not caught:**
- `payment.amount` is `1` when it should be `900` — both are `number`
- `reserveSeat` called before `getQuote` — both calls are individually well-typed
- `passengers` is `0` or `−1` — still a valid `number`

STLC is a coarse sieve. It rejects nonsense at the level of structure — "you gave a chicken where a number belongs" — but is completely blind to any constraint that lives *within* a type or *between* separate values.

---

## Stage 2 — Parametric polymorphism: System F

**Type theory position:** System F (λ2) — terms depending on types

STLC has only fixed base types. System F adds **type abstraction**: a function can abstract over an arbitrary type `A`, and the caller supplies `A` at the call site. This is the kind of polymorphism available in modern generics.

```scala
case class Box[A](value: A)

sealed trait Result[A]
case class Ok[A](value: A)     extends Result[A]
case class Err[A](msg: String)  extends Result[A]

def validate[A](value: A, check: A => Boolean, msg: String): Result[A] =
  if check(value) then Ok(value) else Err(msg)
```

`validate` is one function, verified once, usable for any `A`. The type parameter `A` is introduced with `[A]` and applied at the call site; the compiler checks that `Ok[Quote]` cannot be used where `Ok[Hold]` is required.

In the lambda cube, System F adds the axis of **terms depending on types** (type abstraction `Λ A. e` and type application `e [T]`).

**New errors caught:**
- `Ok[Quote]` used where `Ok[Hold]` is required
- Returning `Result[String]` from a function declared `Result[Int]`

**Errors still not caught:**
- Any constraint on the value of `A`; the number `0` is still a valid `Int`
- Relationships between two separate values of the same type

---

## Stage 3 — Bounded polymorphism: System F<:

**Type theory position:** System F<: (F-sub) — parametric polymorphism with a subtyping lattice

Pure System F quantifies over *any* type. System F<: adds **bounds**: the type variable `A` must be a subtype of some bound `B`. This is the `[A <: B]` syntax.

```scala
// N must be a subtype of Int — some concrete integer type
case class Passengers[N <: Int](count: Int)
case class Quote[N <: Int](perPersonAmount: BigDecimal, passengerCount: Int)
```

The bound `N <: Int` is not cosmetic. At this stage it means: only types that are subtypes of `Int` may appear as `N`. It says nothing yet about *which* integer — that comes later.

More structurally important is the bound on protocol continuations:

```scala
sealed trait Protocol
final class Send[A, Next <: Protocol] extends Protocol
final class Receive[A, Next <: Protocol] extends Protocol
```

The bound `Next <: Protocol` **closes the protocol grammar**. The compiler cannot construct `Send[Int, String]` because `String` does not satisfy `<: Protocol`. Only types in the `Protocol` hierarchy are valid session continuations. This is a structural invariant enforced purely by the type system — no runtime check, no documentation.

```scala
// Compile error: String does not conform to Protocol
val bad: Send[Int, String] = ???
```

**New errors caught:**
- Any non-protocol type used as a session state continuation
- Type arguments to protocol constructors that fall outside the `Protocol` hierarchy

**Errors still not caught:**
- `N <: Int` allows any integer subtype; `Quote[2]` and `Quote[3]` are both valid, and a payment for 3 passengers on a 2-passenger quote still compiles
- Protocol steps can still be called in any order — the grammar is closed, but no usage discipline is enforced yet

---

## Stage 4 — Refinement types: predicates on values

**Type theory position:** Refinement type systems (LiquidHaskell, F*, Whiley) — a type intersected with a logical predicate: `{x : T | P(x)}`

A refinement type `{x : Int | x >= 1 && x <= 9}` admits only integers between 1 and 9. The type checker verifies that all values of this type satisfy `P`.

Scala 3 lacks first-class refinement types, but the **smart constructor** pattern achieves the same effect at system boundaries:

```scala
final case class Passengers[N <: Int] private (count: Int)

object Passengers:
  def of[N <: Int & Singleton](n: N): Either[String, Passengers[N]] =
    if n >= 1 && n <= 9 then Right(new Passengers[N](n))
    else Left(s"Passenger count must be 1–9, got $n")
```

The constructor is `private`. There is exactly one way to obtain a `Passengers[N]`, and it runs the predicate. Once you hold a `Passengers[N]`, the rest of the program — including the entire session protocol — treats it as a *proof token*: evidence that the count was valid. You pay the runtime validation cost once, at the boundary. You never validate again.

Note the `N <: Int & Singleton` bound here — we are moving ahead of ourselves slightly on the `& Singleton` part, which is formally introduced in Stage 5. For now, read it as "some integer type that is specific enough to be a type-level index."

**New errors caught:**
- `Passengers.of(0)` → `Left(...)` — cannot enter the protocol with 0 passengers
- Any attempt to call `new Passengers[N](...)` directly is a compile error

**Errors still not caught:**
- `Passengers[2]` and `Passengers[3]` are both valid; a payment for 3 passengers on a 2-passenger booking still compiles

---

## Stage 5 — Singleton literal types: values embedded in types

**Type theory position:** A restricted, decidable fragment of dependent types (Π-types / λΠ) — a type indexed by a specific constant value

A **dependent type** is a type that depends on a value: in full dependent type theory one writes `Vec (n : Nat) A` for the type of lists of exactly `n` elements, where `n` is an arbitrary term. This is the most expressive axis of the lambda cube, but it makes type checking undecidable in general.

Scala 3 offers a restricted, decidable fragment: **singleton literal types**. The literal `2` has type `2` (the *singleton type* whose unique inhabitant is the integer `2`), and `2 <: Int`. The bound `N <: Int & Singleton` constrains `N` to be a specific integer constant known at the call site, not merely "some Int".

```scala
final case class Quote[N <: Int](perPersonAmount: BigDecimal, passengers: Int)
final case class PaymentFor[N <: Int](amount: BigDecimal, cardToken: String)

def validate[N <: Int](payment: PaymentFor[N], quote: Quote[N]): Either[String, PaymentFor[N]] =
  if payment.amount == quote.total then Right(payment)
  else Left(s"Payment ${payment.amount} ≠ quote total ${quote.total}")
```

The type parameter `N` is shared across `validate`'s two arguments. The compiler must unify them. Passing a `PaymentFor[3]` for a `Quote[2]` is a **type error**:

```scala
val q: Quote[2]      = Quote[2](BigDecimal("450"), 2)
val p: PaymentFor[3] = PaymentFor[3](BigDecimal("1350"), "tok")

PaymentFor.validate(p, q)
// error: Found: PaymentFor[3], Required: PaymentFor[2]
```

The `2` propagates through the entire session chain as a type-level constant:

```
Passengers[2]  →  Quote[2]  →  PaymentFor[2]  →  Tickets[2]
```

Substituting a `3` anywhere in this chain is a compile error.

**New errors caught:**
- `PaymentFor[3]` used with `Quote[2]` — `N` cannot unify
- `Tickets[3]` returned on a `Passengers[2]` booking — impossible to construct

**The ceiling of singleton types:**

`N` must be a *literal constant* known at the point where the type is written. When the passenger count comes from user input:

```scala
val n: Int = readLine().toInt
Passengers.of(n)   // returns Either[String, Passengers[???]]
```

The type `Passengers[n]` where `n` is a runtime variable is not expressible in Scala. The `Either` can only be opened by matching on a finite set of known literals or by erasing `N` to `Int`. This is the glass ceiling of this approach — and the motivation for the runtime/compile-time bridge in this project's derivation layer.

---

## Stage 6 — Session types: the protocol is a type

**Type theory position:** Session types (Honda 1993; Honda, Vasconcelos, Kubo 1998) — types for communication behaviour — combined with type-state (Strom & Yemini 1986) and simulated linearity

So far, types describe *data*. Session types describe *communication behaviour*: the legal sequence of messages on a channel, in both directions, for the lifetime of a session.

```scala
sealed trait Protocol
sealed abstract class End                                extends Protocol
final class Send[A, Next <: Protocol]                    extends Protocol
final class Receive[A, Next <: Protocol]                 extends Protocol
final class Choose[L <: Protocol, R <: Protocol]         extends Protocol
final class Offer[L <: Protocol, R <: Protocol]          extends Protocol
```

These are **phantom types** — they carry no runtime values. Their only job is to parameterise `Channel[P]` so the type checker knows which operations are legal when the channel is in state `P`.

### Duality as a match type

A well-typed session requires the server's protocol to be the exact structural complement of the client's. This is the **duality** relation, computed at compile time as a **match type** (a type-level function defined by pattern matching on type structure):

```scala
type Dual[P <: Protocol] <: Protocol = P match
  case End           => End
  case Send[a, n]    => Receive[a, Dual[n]]
  case Receive[a, n]    => Send[a, Dual[n]]
  case Choose[l, r]  => Offer[Dual[l], Dual[r]]
  case Offer[l, r]   => Choose[Dual[l], Dual[r]]
```

`Dual` is not a function that runs at runtime. It is a **type computation** — the compiler reduces `Dual[Send[Int, End]]` to `Receive[Int, End]` during type checking. `Transport.open[P]` returns `(Channel[P], Channel[Dual[P]])`, making it structurally impossible to create a mismatched client/server pair.

The duality is verified with a `summon` call that does nothing at runtime — it is a **compile-time assertion**:

```scala
summon[Dual[Refundable[2]] =:= Receive[SearchCriteria, Send[SearchResult, Send[Passengers[2], ...]]]]
```

### The type-state pattern

Each `Channel[P]` operation consumes the channel and returns a new `Channel[Next]`, where `Next` is determined by the current state `P`:

```
Channel[Receive[SearchResult, X]]  .receive()  →  (SearchResult, Channel[X])
```

After `.receive()`, the variable `c1` has been consumed. The new `c2` has type `Channel[X]`. Calling any operation on `c1` again is caught at runtime (affine flag) and, by the type-state discipline, by the type checker — the wrong operation at the wrong state has no valid instance (see Stage 7).

**New errors caught:**
- Sending when you should receive, or vice versa
- Skipping a protocol step
- Calling `finish()` before the session ends
- Using a channel after consumption
- Client and server protocols not matching (duality mismatch at `Transport.open`)
- Taking both branches of a `Choose`

---

## Stage 7 — Path-dependent types and implicit proof search

**Type theory position:** Dependent Object Types (DOT calculus — Amin et al. 2016) — type members of a value form a type that *depends on the specific value path*; and implicit resolution as proof search in a fragment of constructive logic

This stage refines Stage 6 in two independent but complementary ways: it introduces path-dependent types to eliminate redundant annotations, and it makes explicit that the `given`/`sealed trait` mechanism is already a form of proof-carrying code.

### The annotation problem

The naive session-type API requires spelling out the entire remaining protocol at every step:

```scala
val (result, c2) = c1.receive[SearchResult,
  Send[Passengers[2], Receive[Quote[2], Receive[HoldConfirmation,
  Choose[Send[PaymentFor[2], Receive[Tickets[2], End]],
         Receive[CancellationConfirmation, End]]]]]]()
```

The continuation type `Send[Passengers[2], ...]` is not a choice made by the programmer — it is fully determined by the type of `c1`. Writing it out exposes implementation details and makes the protocol illegible.

### Path-dependent types

The fix is a **type-extracting typeclass** with **type members**:

```scala
sealed trait CanReceive[P <: Protocol]:
  type Msg            // the type of the message received at this step
  type Rest <: Protocol  // the remaining protocol after this step

object CanReceive:
  given [A, Next <: Protocol]: CanReceive[Receive[A, Next]] with
    type Msg  = A
    type Rest = Next
```

`Channel.receive` is then written as:

```scala
def receive()(using r: CanReceive[P]): (r.Msg, Channel[r.Rest])
```

Here, `r.Msg` and `r.Rest` are **path-dependent types**: the types `Msg` and `Rest` accessed through the specific stable value path `r`. This is distinct from both singleton literal types (Stage 5) and full Pi-types: the dependency is not on an arbitrary term but on a *stable identifier* that the compiler can track. Two distinct instances of `CanReceive` with different type members would give different return types — but because the trait is `sealed` with a single `given`, the compiler always resolves to the same instance for a given `P`, so `r.Msg` is always `A` when `P = Receive[A, Next]`.

Note that `send` requires the `using` clause to come *before* the value parameter, so that the path-dependent type `s.Msg` is in scope as the type of `value`:

```scala
def send(using s: CanSend[P])(value: s.Msg): Channel[s.Rest]
```

At every call site, the compiler resolves `r` from `P`, substitutes `r.Msg` and `r.Rest` into the return type, and the programmer writes nothing:

```scala
val (result, c2) = c1.receive()        // r.Msg = SearchResult, r.Rest = Send[Passengers[2], ...]
val c3           = c2.send(pax)     // s.Msg = Passengers[2], s.Rest = Receive[Quote[2], ...]
val (quote,  c4) = c3.receive()        // r.Msg = Quote[2], ...
val c6           = c5.selectLeft()  // c.L = Send[PaymentFor[2], ...]
```

The protocol state flows invisibly through the chain. The type checker has full information; the programmer has none of the noise.

### The `given` mechanism as proof search

This is also the stage at which to be precise about proof-carrying code.

`CanReceive[P]` is a **proposition**: "the protocol type `P` has the shape `Receive[Msg, Rest]` for some `Msg` and `Rest`." The `given` instance:

```scala
given [A, Next <: Protocol]: CanReceive[Receive[A, Next]] with
  type Msg  = A
  type Rest = Next
```

is a **proof constructor**: given types `A` and `Next`, it constructs a proof of `CanReceive[Receive[A, Next]]`. The trait being `sealed` means no other proofs can be constructed outside this file — the set of provable propositions is exactly the set of types that decompose as `Receive`.

When the compiler type-checks `c1.receive()` where `c1: Channel[Receive[SearchResult, X]]`, it performs **proof search**: it tries to find a value of type `CanReceive[Receive[SearchResult, X]]`. It succeeds by instantiating the `given` with `A = SearchResult`, `Next = X`. If `c1: Channel[Send[...]]`, the search fails — there is no proof of `CanReceive[Send[...]]` — and the program does not compile.

This **is** proof-carrying code in the Curry-Howard sense: types are propositions, `given` instances are proofs, and the compiler accepts a program only when it can construct a proof. The `summon` calls in `BookingProtocol` are explicit proof requests: "compiler, prove this or refuse to compile."

Scala's implicit resolution implements a fragment of constructive logic — essentially typed Horn clause resolution. It is sound, decidable, and already present in this project. What Idris 2, Agda, and Lean add is not proof-carrying code per se, but rather **full dependent types** and **arbitrary proof terms** — the subject of the final section.

---

## Stage 8 — Higher-kinded types and catamorphisms: the Policy DSL

**Type theory position:** System Fω (λω) — types depending on type operators; kinds `* → *` and `(* → *) → *`

Booking rules arrive at runtime from external configuration. They must be represented as data, interpreted in multiple ways (render as text, check cancellability, extract capabilities), and ultimately used to select a protocol variant.

The natural representation is a recursive tree, and there is an obvious way to write one:

```scala
// The standard recursive ADT approach
enum Policy:
  case Refundable(next: Policy)
  case NonRefundable(next: Policy)
  case MinStay(days: Int, next: Policy)
  case And(left: Policy, right: Policy)
  case Done
```

To interpret this tree you write a fold:

```scala
def describe(policy: Policy): String = policy match
  case Policy.Refundable(next)    => s"[Refundable] → ${describe(next)}"  // recursion here
  case Policy.MinStay(days, next) => s"[Min stay: ${days}d] → ${describe(next)}"
  case Policy.Done                => "✓"

def permitsCancellation(policy: Policy): Boolean = policy match
  case Policy.Refundable(_)    => true
  case Policy.NonRefundable(_) => false
  case Policy.MinStay(_, next) => permitsCancellation(next)   // recursion here too
  case Policy.And(l, r)        => permitsCancellation(l) && permitsCancellation(r)
  case Policy.Done             => true
```

This works. But notice that the recursion — "unwrap one level, call self on subtrees" — is written identically in every interpretation. With five interpretations, this pattern appears five times. If you add a new constructor to `Policy`, you must find and update every one of them. If you forget one, the compiler may warn you but the traversal logic itself is still duplicated and must be gotten right independently each time.

You might try to factor out the recursion using a `Functor`-like interface in the OO style:

```scala
trait PolicyAlgebra[A]:
  def refundable(next: A): A
  def nonRefundable(next: A): A
  def minStay(days: Int, next: A): A
  def done: A

def naiveFold[A](policy: Policy, alg: PolicyAlgebra[A]): A = policy match
  case Policy.Refundable(next)    => alg.refundable(naiveFold(next, alg))   // still recursive
  case Policy.NonRefundable(next) => alg.nonRefundable(naiveFold(next, alg))
  case Policy.MinStay(d, next)    => alg.minStay(d, naiveFold(next, alg))
  case Policy.Done                => alg.done
```

This is better — the recursion now lives in one place, and each interpretation is a `PolicyAlgebra[A]` instance. But two problems remain:

First, `naiveFold` is specific to `Policy`. If you have a second recursive data type (`Expr`, `Term`, `Query`), you write a second fold, a second algebra, and so on. Nothing is shared — not the recursion scheme, not the concept of "algebra". The fold appears in multiple places with no common type.

Second, and more fundamentally: **this signature cannot be made generic over the functor in a language without HKT**. The algebra `PolicyAlgebra[A]` carries the shape of `Policy` baked into it — it knows about `Refundable`, `MinStay`, and `And` because those are the fields of `Policy`. There is no way to express "`interpret` is a function that works for any functor `F[_]`" without being able to quantify over type constructors.

### The base functor and Fix

The HKT-based solution separates the *shape of one tree level* from the *recursion*:

```scala
enum PolicyF[+A]:       // A is the recursive position, not yet tied to Policy
  case Refundable(next: A)
  case NonRefundable(next: A)
  case MinStay(days: Int, next: A)
  case RequiresID(next: A)
  case And(left: A, right: A)
  case Done

case class Fix[F[_]](unfix: F[Fix[F]])
type Policy = Fix[PolicyF]
```

`PolicyF[A]` is one level of the tree with the recursive positions replaced by the type variable `A`. It is not recursive: `PolicyF[String]` is a flat value with `String`s where the sub-trees would be. `Fix[F]` ties the knot by substituting `Fix[F]` itself back in for `A`, giving a fully recursive tree.

`Fix[F[_]]` requires `F` to have **kind `* → *`** — it is a type *constructor*, not a type. This is exactly System Fω: quantification over type operators, not just types. In a language without HKT (Java before generics of generics, TypeScript before 4.7), `case class Fix[F[_]](...)` does not typecheck. You can write `FixPolicyF` for the specific functor, but `Fix` as a generic abstraction does not exist.

The `Functor[F[_]]` typeclass has the same requirement:

```scala
trait Functor[F[_]]:
  def map[A, B](fa: F[A])(f: A => B): F[B]
```

`F[_]` is a type constructor parameter. Scala's `List`, `Option`, and `PolicyF` all satisfy it; `Int` and `String` do not. Without HKT, this typeclass cannot be stated — you can write `map` as a method on each specific container, but you cannot abstract over the container shape.

### The catamorphism (`interpret`)

With `Fix` and `Functor` in hand, the **catamorphism** is a single generic function:

```scala
def interpret[F[_]: Functor, A](alg: F[A] => A)(fix: Fix[F]): A =
  alg(Functor[F].map(fix.unfix)(interpret(alg)))
```

`interpret` is the **only** place recursion is written, for all functors at once. The algebra type is now simply `F[A] => A` — a plain Scala function. The compiler checks it against the shape of `F[A]`, which means pattern matching on it is exhaustive by construction.

Every interpretation is a non-recursive function passed to `interpret`:

```scala
val describe: Policy => String =
  interpret[PolicyF, String]:
    case PolicyF.Refundable(next)    => s"[Refundable] → $next"
    case PolicyF.MinStay(days, next) => s"[Min stay: ${days}d] → $next"
    case PolicyF.NoConstraint        => "✓"
    ...

val analyze: Policy => Analysis =
  interpret[PolicyF, Analysis]:
    case PolicyF.Refundable(a)  => a.copy(cancellationPermitted = true)
    case PolicyF.Both(l, r)     => Analysis(l.cancellationPermitted && r.cancellationPermitted, ...)
    ...
```

The `Functor[PolicyF]` instance — the `map` that says "to transform an `A` inside a `PolicyF`, apply `f` to each recursive position" — is verified once by the compiler, separately from any interpretation. All interpretations rely on it being correct. Add a new constructor to `PolicyF`, and the compiler will require you to update the `Functor` instance (exhaustiveness) and will surface missing cases in every algebra.

**New errors caught:**
- A missing case in an algebra — the pattern match on `F[A] => A` is checked for exhaustiveness
- An algebra returning the wrong type for a case
- The `map` function in `Functor[PolicyF]` missing a constructor — caught at the instance definition, not scattered across interpretations

---

## The Grand Finale — Dependent session types with refinement

This project combines every stage above into a single coherent system.

### The full protocol type

```scala
type Refundable[N <: Int] =                              // Stage 3: bounded quantification
  Send[SearchCriteria,                                   // Stage 6: session type grammar
  Receive[SearchResult,
  Send[Passengers[N],                                    // Stage 5: N is a singleton-literal index
  Receive[Quote[N],                                         // Stage 5: same N — consistency enforced
  Receive[HoldConfirmation,
  Choose[                                                // Stage 6: branching
    Send[PaymentFor[N], Receive[Tickets[N], End]],          // Stage 5: N propagates to payment/tickets
    Receive[CancellationConfirmation, End]
  ]]]]]]
```

The session type grammar (Stage 6) is closed by the `<: Protocol` bounds (Stage 3). The passenger count `N` is a singleton literal index (Stage 5) threaded through all four domain types. The `Dual[P]` match type (Stage 6) ensures the server's type is the exact structural complement of the client's.

### The channel chain

```scala
val searching: Channel[Refundable[2]] = ...

val c1               = searching.send(criteria)   // c1: Channel[Receive[SearchResult, ...]]
val (result, c2)     = c1.receive()               // c2: Channel[Send[Passengers[2], ...]]
val c3               = c2.send(passengers)        // c3: Channel[Receive[Quote[2], ...]]
val (quote,  c4)     = c3.receive()               // c4: Channel[Receive[HoldConfirmation, ...]]
val (hold,   c5)     = c4.receive()               // c5: Channel[Choose[..., ...]]
val c6               = c5.selectLeft()            // c6: Channel[Send[PaymentFor[2], Receive[Tickets[2], End]]]
val c7               = c6.send(payment)           // c7: Channel[Receive[Tickets[2], End]]
val (tickets, done)  = c7.receive()               // done: Channel[End]
done.finish()
```

Every variable has a distinct, fully determined type. Moving a line, skipping a step, or repeating a step is a type error. The type checker knows the protocol state after every single operation.

The types at each step are inferred via the path-dependent type mechanism (Stage 7): `r.Msg` and `r.Rest` are resolved by the compiler from the channel's `P`, and the programmer writes nothing.

### The guarantees, cross-referenced

| What cannot go wrong | Mechanism | Stage |
|---|---|---|
| Non-protocol type as a session continuation | `Next <: Protocol` bound | 3 |
| 0 or invalid passenger count enters the protocol | `Passengers.of` smart constructor | 4 |
| Payment for wrong passenger count | `PaymentFor[N]` vs `Quote[N]` must unify | 5 |
| Messages in wrong order | Type-state: each op requires a specific `P` | 6 |
| Session closed before it ends | `finish()` requires `P =:= End` | 6 |
| Server protocol ≠ client protocol | `Transport.open` returns `Channel[Dual[P]]` | 6 |
| Both branches of `Choose` taken | `selectLeft`/`selectRight` return `Channel[L]`/`Channel[R]` | 6 |
| Channel used after consumption | Affine `AtomicBoolean` flag + type-state | 6 |
| Annotation noise obscuring the protocol | Path-dependent types via `CanReceive[P]`, etc. | 7 |
| `receive()` called on a `Send[...]` channel | No `CanReceive` instance for `Send[...]` — proof fails | 7 |
| Policy algebra is non-exhaustive | Exhaustiveness check in `interpret` | 8 |
| Runtime-selected variant is not type-checked | All branches of `ProtocolVariant` match are typed | 6+8 |

### Where in the lambda cube

The lambda cube has three axes, each representing one kind of dependency that a type system can add on top of STLC:

- **λ2** (horizontal): terms may depend on types — parametric polymorphism, `List[A]`
- **λΠ** (depth): types may depend on terms — dependent types, `Vec n A`
- **λω** (vertical): types may depend on type operators — higher-kinded types, `Fix[F[_]]`

The eight corners are the eight combinations of these extensions. The base corner λ→ (STLC) has none; the far corner λC (Calculus of Constructions) has all three simultaneously.

```
            λΠω ─────────── λC
           /|              /|
          / |             / |
        λω ──────────── λ2ω |
         |  |    ·····  |   |
         |  λΠ ··········|· λ2Π
         | /      ↑      | /
         |/       |      |/
        λ→ ──────────── λ2

  λ→   STLC (Stage 1)
  λ2   + parametric polymorphism (Stage 2)
  λω   + type operators / HKT (Stage 8)
  λΠ   + full dependent types  (not reached)
  λ2ω  + both λ2 and λω = System Fω  ← this project's main position
  λC   + all three = Calculus of Constructions  (Idris 2, Agda, Lean)

  ·····  dotted path = the fragment of λΠ this project uses
         (singleton literals, path-dependent types, match types)
         — enough to step off the λ2ω face toward λC,
           but not enough to reach the full λΠ face
```

The project sits firmly at **λ2ω** — it requires both the λ2 axis (every generic type, `Channel[P]`, `Result[A]`) and the λω axis (`Fix[F[_]]`, `Functor[F[_]]`). On top of that, three features push it partially along the λΠ axis without reaching it:

| Feature | λΠ fragment used |
|---|---|
| `N <: Int & Singleton`, `Quote[N]` | type indexed by a constant term (Stage 5) |
| `r.Msg`, `r.Rest` in `recv()` return type | type depending on a stable value path — DOT (Stage 7) |
| `Dual[P]` match type, `summon[... =:= ...]` | type-level computation and equality proofs (Stage 6) |

None of these reach a full λΠ corner because the index language is restricted: `N` must be a compile-time literal, `r` must be a stable path, and match types are pattern-matched on type structure, not on arbitrary terms. Full λΠ — and hence λC — requires the index to be any term of the language, with no such restriction.

---

## What a language with full dependent types would add

Scala's singleton literal types and path-dependent types are restricted fragments of dependent types. They are decidable and practical. The restrictions are real.

### 1. Types indexed by arbitrary runtime terms

In this project, `N` must be a literal constant at the point where `Transport.open[BookingProtocol.Refundable[2]]` is written. A session parameterised by a runtime integer requires a seam:

```scala
// We cannot write this in Scala
val n: Int = readLine().toInt
Transport.open[BookingProtocol.Refundable[n]]  // not valid
```

In Idris 2, the passenger count can be a runtime value used directly as a type index:

```idris
booking : (n : Nat) -> {auto ok : n >= 1 && n <= 9 = True}
       -> Session (refundableProtocol n) -> IO (Tickets n)
```

`n` is simultaneously a runtime term and a type-level index. The `{auto ok}` implicit argument is a **proof** that `n` is in range, synthesised automatically when the value is a literal and demanded from the caller when it is not. The entire `ProtocolDerivation.scala` seam dissolves.

### 2. Protocol structure derived from arbitrary runtime data

In this project, the set of protocol variants is fixed at compile time (`Refundable`, `NonRefundable`, `NoAvailability`). A new variant requires a new type alias and a new match arm. The derivation is finite enumeration, not computation.

In Idris 2, the protocol type itself can be computed by recursion on a `Policy` value, because a function from terms to types (a Pi-type) is directly expressible:

```idris
protocolDerivedFrom : (n : Nat) -> Policy -> SessionType
protocolDerivedFrom n policy =
  if permitsCancellation policy
    then refundableProtocol n
    else nonRefundableProtocol n
```

`protocolDerivedFrom n policy` is a *type computed from values*. The type checker verifies it is total — it handles all `Policy` constructors — and the session type for any policy is derived without enumeration. The `ProtocolVariant` seam dissolves entirely.

### 3. Richer proof languages and arbitrary propositions

As established in Stage 7, this project already carries proofs in the Curry-Howard sense: `CanReceive[P]` is a proposition, the `given` instance is a proof constructor, implicit resolution is proof search, and a program that fails to construct a required proof is rejected. The type checker already enforces properties — not just types — about the communication structure.

What Idris 2, Agda, and Lean add is a substantially more expressive index language and a correspondingly richer class of provable propositions:

- **Full Pi-types**: the type index can be any term of the language, not only a literal constant or a stable path. `Vec n A` is indexed by the runtime value `n`, allowing types to express properties of values that are not known until the program runs.
- **Totality checking**: the type checker verifies that all functions terminate and all pattern matches are exhaustive. Without totality, a proof constructor could loop forever or fail to cover a case — making any proof built on it unsound. Totality is what makes the Curry-Howard correspondence a *guarantee*, not just an analogy.
- **First-class proof terms**: proofs are values that can be inspected, manipulated, passed as arguments, and stored. In Scala, a `given` instance is a proof in the logical sense, but it is erased at runtime and cannot be reasoned about within the program itself.
- **Arbitrary propositions**: the proposition language is the full type language. You can state and prove that a sorting function returns a sorted list, that two protocol endpoints are in a race-free relationship, or that a payment system satisfies a conservation law — not merely that a type constructor can be decomposed in a particular way.

The gap to Idris/Agda/Lean is not in the presence of proof-carrying code, but in the **expressiveness of what can appear as a type index** and the **breadth of propositions that the type system can verify** — from structural decomposition (this project) to arbitrary mathematical properties (full dependent type theory).

---

## The error classes, accumulated

| Error class | First caught at |
|---|---|
| Wrong base type (string where number expected) | Stage 1 (STLC) |
| Arguments in wrong order | Stage 1 (STLC) |
| Wrong type argument to a generic container | Stage 2 (System F) |
| Non-protocol type as a session continuation | Stage 3 (System F<:) |
| Invalid passenger count enters the protocol | Stage 4 (Refinement) |
| Payment for wrong passenger count | Stage 5 (Singleton types) |
| Messages in wrong order | Stage 6 (Session types) |
| Protocol step skipped or repeated | Stage 6 (Session types) |
| Client and server protocols not matching | Stage 6 (Duality) |
| Channel used after consumption | Stage 6 (Type-state + affine) |
| Session closed before completion | Stage 6 (Session types) |
| `recv` called on a `Send` state | Stage 7 (Implicit proof search) |
| Annotation noise hiding the protocol | Stage 7 (Path-dependent types) |
| Non-exhaustive rule interpretation | Stage 8 (HKT / catamorphism) |
| Runtime-selected variant not type-checked | Stage 6 + 8 (Derivation bridge) |
| Protocol indexed by arbitrary runtime value | ✗ requires full Π-types (Idris 2 / Agda / Lean) |
| Protocol *structure* derived from runtime data | ✗ requires full Π-types |
| Proofs about arbitrary mathematical properties | ✗ requires totality + full proof language |
