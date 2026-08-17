# Talk Redesign: Domain Model, Stage Progression, and Structural Changes

This document supersedes `REFACTOR_STAGE4_REMOVAL.md` and expands it into a full
redesign spec covering the canonical domain model, revised character stories, test
spine, stage-by-stage code changes, and all slide/deck updates.

---

## Part 0 — Key Design Decisions

| Topic | Decision |
|---|---|
| Stage count | **Six stages, numbered 0–5** |
| Phantom typestate | Introduced at **Stage 2** (requires only generics, not sealed types) |
| Sealed exhaustiveness | Introduced at **Stage 3** |
| Charlie's story | **3DS timeout path drops `Payment<Initiated>` hold** — closes Stage 5 (Idris QTT) |
| Alice's story | Empty `OrderId` — closes Stage 4 (Scala 3 refinement) |
| Bob's story | New risk tier silently auto-approves — closes Stage 3 (sealed exhaustiveness) |
| Danielle's story | Client/server protocol drift — closes Stage 4 (session types) |
| Terminal operations | **`capture` or `cancel`** — `cancel` present at every stage |
| Refund | Separate protocol referencing `CaptureId`; **not in the demo** |
| Invoice payment method | Separate flow; stays in sealed `PaymentMethod` hierarchy for exhaustiveness |
| `authorize` step | **Split**: `initiate` places the hold → authenticate → `authorize*` or `cancel` |
| 3DS outcome handling | **Shown at every stage** (SUCCESS/FAILURE/TIMEOUT arms with cancel) |
| Partial capture | **Excluded** — captured amount = authorized amount by definition |
| Stage 3 payoff | **Bob only** closed |
| Stage 4 payoff | **Alice + Danielle** closed; Bob carried from Stage 3; Charlie still open |
| Stage 5 payoff | **All four** closed |

---

## Part 1 — Canonical Domain Model

### 1.1 The payment flow (card / wallet)

```
assessRisk(order)
  → RiskDecision                           Low | Medium | High

initiate(order, riskDecision, paymentMethod)
  → InitiatedPayment                       hold placed on card

  [Medium risk: 3DS challenge initiated]
  3DS outcome:
    SUCCESS  → authorize3DS(initiated, proof)   → AuthorizedPayment
             → capture(authorized)              → CaptureConfirmation
    FAILURE  → cancel(initiated)                → CancelConfirmation   hold released
    TIMEOUT  → cancel(initiated)                → CancelConfirmation   hold released ← Charlie's bug

  [Low risk: no challenge]
    authorizeAuto(initiated) → capture(authorized) → CaptureConfirmation

  [High risk: manual review challenge]
  Review outcome:
    APPROVED → authorizeReview(initiated, approval) → capture → CaptureConfirmation
    REJECTED → cancel(initiated)                    → CancelConfirmation
    TIMEOUT  → cancel(initiated)                    → CancelConfirmation   ← same class of bug
```

`cancel` is the inverse of `initiate`: it releases the authorization hold.
It can be called on an `InitiatedPayment` (before confirmation, on authentication failure/timeout)
or on an `AuthorizedPayment` (after confirmation, if the merchant later needs to void).

**Not in the demo:**
- Refund: a separate protocol invoked after capture, referencing `CaptureId`
- Invoice: a different payment method with no authorization/hold cycle
- Partial capture: excluded; captured amount = authorized amount by definition

**Note on real-world 3DS variants**: In 3DS 2.x flows used by some processors, the
authentication token is obtained before the authorization request. The demo uses the
earlier model (hold first, authenticate second) because it creates the resource-obligation
structure that motivates linear types. Either model is legitimate; the demo's choice
should be stated explicitly in code comments.

### 1.2 Approval mechanism per risk level

| Risk level | Challenge | Type evidence |
|---|---|---|
| Low | None — automatic | `AutoApproved` (no payload) |
| Medium | 3DS authentication | `ThreeDSProof` (obtained from 3DS system) |
| High | Manual review | `ManualReviewApproval` (obtained from review system) |

At Stage 2, the three `authorize*` methods return `Payment<Authorized<R>>` with a specific,
hard-coded `R` (e.g., `authorize3DS` always returns `Payment<Authorized<MediumRisk>>`).
This means a caller cannot produce `Payment<Authorized<MediumRisk>>` without providing
a `ThreeDSProof` — the wrong-authorization bug is caught even without sealed types.

### 1.3 Why `cancel` is mandatory — and why the compiler cannot enforce it until Stage 5

`Payment<Initiated>` (or the session channel equivalent at Stage 4) is a resource created
by the payment service that carries an obligation: the hold must eventually be settled
(capture) or released (cancel). The same obligation exists if authentication fails or times out.

```java
// Stage 1 flavour (Authorization, not phantom state):
Authorization auth = paymentService.authorize(order, risk, method);  // hold placed

ThreeDSOutcome outcome = waitFor3DS();
switch (outcome) {
    case SUCCESS  -> paymentService.capture(auth);
    case FAILURE  -> paymentService.cancel(auth);      // hold released
    case TIMEOUT  -> paymentService.cancel(auth);      // hold released — easy to omit
}
```

On the `TIMEOUT` path, `auth` goes out of scope without being resolved. No exception,
no log entry. The hold persists for up to 7 days. The customer sees a pending charge.

Enforcement progression:

| Stage | What is enforced |
|---|---|
| 1 | Nothing. `cancel` exists; the compiler does not require it. |
| 2 | `Payment<Cancelled>` is a typed outcome. The compiler tracks which path produced it. Does not require it. |
| 3 | Sealed `PaymentState` and `ThreeDSOutcome` — all arms of a `switch` are visible. Still no obligation. |
| 4 (Scala 3) | Session type structurally includes the cancel branch. Runtime channel guard catches a dropped channel, but at the wrong end of the connection. |
| 5 (Idris) | QTT mult-1 on the session channel. Every code path must reach `End`. Dropping `ch` is a compile error. |

---

## Part 2 — Character Stories

### Alice — Empty OrderId (closes Stage 4, Scala 3)

A serialization bug in the upstream order service produces an empty `OrderId`. The payment
processor returns error 400 with an opaque message. Three days of debugging before anyone
verifies the ID was populated.

Closes when: `OrderId = String :| MinLength[1]` (Iron/Scala 3). Empty construction is
impossible at the type level; the constraint lives in the type definition rather than
distributed validators.

### Bob — New risk tier silently auto-approves (closes Stage 3, sealed types)

The risk engine adds `SuspectedFraud` for orders with anomalous signals. The developer
adds it to the risk enum. The approval-routing `switch` has `default → authorizeAuto()`.
`SuspectedFraud` orders are auto-approved. Chargebacks accumulate for 72 hours.

Closes when: `Risk` is a `sealed interface`. The compiler rejects every non-exhaustive
`switch` on `Risk`. Adding `SuspectedFraud` is caught at the moment it is added to the
hierarchy.

Two examples of exhaustiveness in the domain:
1. Routing authorization challenge by risk level — which `authorize*` method to call
2. Routing by `PaymentMethod` when deciding how to handle an order —  `Card | Wallet`
   proceed through the authorize/capture cycle; `Invoice` delegates to a separate service.
   `Invoice` stays in the sealed hierarchy precisely so that adding a new payment method
   cannot be silently ignored.

### Charlie — `Payment<Initiated>` dropped on 3DS timeout (closes Stage 5, Idris QTT)

The team adds a `TIMEOUT` arm to the 3DS outcome handler. The `SUCCESS` arm authorizes
and captures. The `FAILURE` arm cancels. The `TIMEOUT` arm:

```java
case TIMEOUT -> Result.failure("3DS timed out");   // initiated payment never cancelled
```

`Payment<Initiated>` (or `Authorization` at Stage 1) goes out of scope. The hold
persists for 7 days. Support tickets describe "phantom charges" on cancelled orders.
The team finds and fixes the specific path. Over the following sprints, two more error
paths are added and the same mistake recurs, because nothing in the language signals that
`initiated` is an unfulfilled obligation.

Stage 1 does not address Charlie's bug. The `cancel` method exists in the Stage 1 service
interface, so the correct resolution path is available — but nothing requires it to be
taken. The developer writes `case TIMEOUT -> Result.failure(...)` and the compiler does
not object. Typed parameter dependencies at Stage 1 prevent a different class of error:
wrong lifecycle ordering (e.g. calling `capture` without a prior `authorize`). They say
nothing about whether an initiated payment is ever resolved at all. That *cardinality*
guarantee — exactly one resolution per initiated payment — waits until Stage 5.

Closes when: the session channel (or `Payment<Initiated>` in the non-session model) has
QTT multiplicity 1. The compiler tracks whether every code path from creation of `ch` (or
`initiated`) reaches exactly one consumption. The `TIMEOUT` arm is a compile error if it
does not call `cancel` and reach `End`.

### Danielle — Client/server protocol drift (closes Stage 4, Scala 3 session types)

The backend team mandates 3DS for medium-risk orders. The server protocol now expects a
`ThreeDSProof` in the capture request. The client library was built against the old schema.
Client sends `AutoApproved`; server rejects at runtime. Medium-risk orders fail in
production on Friday afternoon.

Closes when: both sides compile against the same `PaymentProtocol` type. A protocol change
that is not reflected in the client is a compile error at client build time.

---

## Part 3 — Test Spine (revised)

Nine items. Items 1–2 close at Stage 1; item 3 at Stage 2; item 4 at Stage 3;
items 5–6 at Stage 4; items 7–9 at Stage 5.

```typst
test-list((
  ("1", [Domain types prevent primitive confusion: OrderId ≠ CaptureId ≠ String],   [S·1], "..."),
  ("2", [Lifecycle ordering: each step requires the previous step's typed output],   [S·1], "..."),
  ("3", [Approval mechanism matches the assessed risk level],                        [S·2], "..."),
  ("4", [All risk levels handled exhaustively — no silent fallthrough],              [S·3], "..."),
  ("5", [Boundary constraints: non-empty order identifiers],                         [S·4], "..."),
  ("6", [Client and server share the same protocol definition],                      [S·4], "..."),
  ("7", [Initiated payment resolved on every code path — no phantom holds],         [S·5], "..."),
  ("8", [Session channel consumed completely — never dropped mid-protocol],          [S·5], "..."),
  ("9", [Protocol shape derived from the runtime risk classification],               [S·5], "..."),
))
```

Items 7 and 8 express related but distinct QTT guarantees: item 7 is about the
capture/cancel decision being mandatory on every path (Charlie's story); item 8 is about
the full session protocol reaching `End` even on intermediate error paths.

**Summary-row labels at each payoff slide:**

| At payoff | Summary |
|---|---|
| Stage 1 | items 1–2 just-gone; no prior summary row |
| Stage 2 | "2 invariants closed ✓ — Stage 1" |
| Stage 3 | "3 invariants closed ✓ — Stages 1–2" |
| Stage 4 | "4 invariants closed ✓ — Stages 1–3" |
| Stage 5 | "6 invariants closed ✓ — Stages 1–4" |

---

## Part 4 — Stage Progression

### Stage 0 (JavaScript — unchanged)

No types. All invariants enforced by convention or not at all.

### Stage 1 — Java: nominal types + typed returns

**New mechanism:** Distinct nominal types; typed return chains.

At Stage 1, `initiate` and `authorize` are combined into a single `authorize` method for
simplicity. The hold is placed by `authorize`. The `initiate`/`authorize` split is
introduced at Stage 2 when phantom typestate makes intermediate states meaningful.

**Service interface — the program outline:**

```java
// RiskService
RiskDecision assessRisk(Order order);

// PaymentService
Result<Authorization>       authorize(Order order, RiskDecision risk, PaymentMethod method);
Result<CaptureConfirmation> capture(Authorization auth);
CancelConfirmation          cancel(Authorization auth);
```

Reading these signatures alone: risk must be assessed before authorization (typed
parameter); authorization must precede capture or cancel (typed parameter); both terminal
operations are named in the contract; `Result<T>` names fallibility. The service interface
is the outline of the payment module. This is Brady's type-driven development applied to
a service API, not just a function body.

**Demo:** Show all three risk paths, each including both the success (capture) arm and
the cancel arm. For medium risk, the 3DS challenge has `SUCCESS`, `FAILURE`, and `TIMEOUT`
arms. Comment on the `TIMEOUT` arm: the compiler does not require `cancel` here.

**Test-spine items closed:** 1 (primitive types), 2 (ordering)

**Honest gap:** Risk level is a runtime value; there is no type-level constraint between
the risk level and the authorization mechanism. `RiskDecision` is a nominal type but
carries no structural constraint on what follows it.

### Stage 2 — Java: generics + phantom typestate

**New mechanism:** Type parameters. Applied in two ways that reinforce each other.

**The `initiate`/`authorize` split** (introduced at Stage 2 with phantom typestate):

```java
// State markers — plain classes at Stage 2 (not sealed)
class Initiated  {}
class Authorized<R extends Risk> {}
class Captured   {}
class Cancelled  {}

// Payment<S> — unified lifecycle type
public final class Payment<S> {
    private Payment(String orderId, int amountCents, List<String> auditTrail) {}

    // Place the hold — this is the resource that must be resolved
    static Payment<Initiated>              initiate(Order order, RiskDecision risk, PaymentMethod method)

    // Confirm via the appropriate mechanism — each method returns the specific R
    static Payment<Authorized<LowRisk>>    authorizeAuto(Payment<Initiated> p)
    static Payment<Authorized<MediumRisk>> authorize3DS(Payment<Initiated> p, ThreeDSProof proof)
    static Payment<Authorized<HighRisk>>   authorizeReview(Payment<Initiated> p, ManualReviewApproval a)

    // Terminal operations
    static Payment<Captured>  capture(Payment<Authorized<?>> p)
    static Payment<Cancelled> cancel(Payment<Initiated> p)        // on auth failure/timeout
    static Payment<Cancelled> cancel(Payment<Authorized<?>> p)    // if voiding after authorization
}
```

A caller cannot produce `Payment<Authorized<MediumRisk>>` without providing a `ThreeDSProof`.
`authorize3DS` is the only path to `Authorized<MediumRisk>`, and it requires the proof.
Bob's story is partially closed: wrong-mechanism calls for KNOWN risk levels are rejected
by the type system.

**Why `R` is on `Authorized` but not `Initiated`:** The risk level is encoded in the
authorization *confirmation* method, not in the initiated payment. Java cannot infer a
phantom type parameter from a runtime risk enum value, so `initiate` returns
`Payment<Initiated>` with no type parameter. The risk level enters the type only at the
point of confirmation, where the specific factory method determines `R`.

**Demo:**

```java
Payment<Initiated> initiated = Payment.initiate(order, risk, method);

// For medium risk: 3DS challenge
ThreeDSResult result = run3DSChallenge();
switch (result) {
    case ThreeDSResult.Success(ThreeDSProof proof) -> {
        Payment<Authorized<MediumRisk>> auth = Payment.authorize3DS(initiated, proof);
        Payment<Captured> captured = Payment.capture(auth);
    }
    case ThreeDSResult.Failure(), ThreeDSResult.Timeout() -> {
        // The type system does not require this cancel call at Stage 2.
        // Charlie's bug: omitting it leaves Payment<Initiated> unresolved.
        Payment<Cancelled> cancelled = Payment.cancel(initiated);
    }
}
```

`AuditTrail<E>` is retained from the existing Stage 2 code as the introductory generics
example (data parameterization), shown before `Payment<S>` (state parameterization).

**Test-spine items closed:** 3 (approval mechanism matches risk level for known risk levels)

**Honest gap:** Marker classes are not sealed. A developer can add new states without
updating any handler. The risk-level encoding is incomplete: `authorizeAuto` could be
called for a high-risk order — the runtime routing logic is not type-enforced.

### Stage 3 — Java 21: sealed types + exhaustiveness

**New mechanism:** Sealed hierarchies. Every `switch` / `match` on a sealed type is
exhaustive or it does not compile.

```java
sealed interface Risk         permits LowRisk, MediumRisk, HighRisk             {}
sealed interface PaymentState permits Initiated, Authorized, Captured, Cancelled {}
sealed interface PaymentMethod permits Card, Wallet, Invoice                     {}
```

Adding `SuspectedFraud extends Risk` makes every non-exhaustive `switch` on `Risk` a
compile error. Bob's story closes: the missing case is caught at the moment the tier is
added, not at runtime.

`Invoice` is in `PaymentMethod` because exhaustiveness is the point — the `switch` on
payment method must handle all variants. The `Invoice` arm delegates to a comment (or to
a descriptive exception): "Invoice payments are processed by a separate invoicing service."
Excluding it from the sealed hierarchy would defeat the purpose.

The phantom typestate from Stage 2 is enriched: `PaymentState` is sealed, so
pattern-matching on payment state is exhaustive. Adding a new payment lifecycle state
requires updating every handler.

**Records vs. lifecycle classes:** Java records work well for value types (risk levels,
approval evidence, payment method variants). Lifecycle types (`Payment<S>`) should remain
`final class` with a private constructor — records' canonical constructors cannot be made
private on a `public record` (the constructor must be at least as accessible as the
record class), so records are inappropriate for types whose construction must be controlled.

**Test-spine items closed:** 4 (exhaustive risk dispatch)

**Honest gap:** `Payment<Initiated>` can still be dropped without resolution — nothing
enforces that `cancel` or `authorize*` is called on every code path. Java has no linear
types.

### Stage 4 — Scala 3: refinement types + session types

**New mechanisms:** Opaque refined types (Iron library). Session types.

**Alice's story closes:** `OrderId = String :| MinLength[1]`

**Danielle's story closes:** both sides compile against `PaymentProtocol`.

**Session protocol:**

```scala
type PaymentProtocol =
  Send[RiskRequest,
  Receive[RiskResponse,
  Send[InitiateRequest,
  Receive[InitiateResponse,                // hold placed on server side
  Choose[
    // Left: authentication succeeded — capture
    Send[CaptureRequest, Receive[CaptureResponse, End]],
    // Right: authentication failed or timed out — cancel
    Send[CancelRequest,  Receive[CancelResponse,  End]]
  ]]]]]
```

Refund is a separate type and not part of this protocol:
```scala
type RefundProtocol = Send[RefundRequest, Receive[RefundResponse, End]]
// Invoked independently, referencing CaptureId from a prior session
```

**Lifecycle case classes** use `private[payment]` constructors:
```scala
final case class InitiatedPayment private[payment](
  order: Order, holdRef: HoldRef, auditTrail: List[String])

final case class AuthorizedPayment[R <: Risk] private[payment](
  order: Order, authCode: AuthCode, holdRef: HoldRef, auditTrail: List[String])

final case class CapturedPayment private[payment](
  order: Order, captureId: CaptureId, auditTrail: List[String])

final case class CancelledPayment private[payment](
  order: Order, cancelRef: CancelRef, auditTrail: List[String])
```

`authorize` and `capture` are modelled as infallible for clarity. Production versions
would return `Either[AuthError, AuthorizedPayment[R]]` and `Either[CaptureError, CapturedPayment]`.
`cancel` is infallible by design — releasing a hold does not produce a value the caller
needs to act on, and treating failure to cancel as a fatal error simplifies the demo.
`refund` is out of scope.

**Runtime channel guard:** The Scala 3 channel has a runtime `AtomicBoolean` that fires
if the channel is used after being finished or dropped before being finished. This catches
Charlie's bug — but at runtime, at the OTHER end of the connection (when the server
notices the client stopped responding), not at the point of the programming error. The
developer can still write a `TIMEOUT` arm that drops the channel silently.

**RiskDecision vs. RiskSnapshot:** At Stages 1–4, `assessRisk` returns `RiskDecision`
(a simple ADT: `Low | Medium | High`). At Stage 5, the Idris dependent type requires
`RiskSnapshot` — a richer structure including `captureWindowHours`, `fraudScore`, and
other fields used to compute `protocolFromSnapshot`. The `RiskSnapshot` is introduced at
Stage 5 specifically to enable protocol derivation; it is not needed at earlier stages.

**Test-spine items closed:** 5 (non-empty identifiers), 6 (shared protocol)

### Stage 5 — Idris 2: QTT + dependent types

**New mechanisms:** Quantitative Type Theory (multiplicity annotations). Π-types.

**Charlie's story closes:**

```idris
process3DS : Channel 1 PostAuthProtocol -> IO ()
process3DS ch = do
    outcome <- await3DS
    case outcome of
        Success proof => do
            let ch' = send ch (CaptureRequest proof)
            (_, ch'') <- receive ch'
            finish ch''
        Failure => do
            let ch' = send ch CancelRequest
            (_, ch'') <- receive ch'
            finish ch''
        Timeout =>
            -- Writing `pure ()` here is a compile error:
            -- "Quantity mismatch for ch: expected to use 1 time but used 0 times"
            -- The compiler requires an explicit decision about the channel.
            let ch' = send ch CancelRequest
            (_, ch'') <- receive ch'
            finish ch''
```

**Protocol from runtime risk:**

```idris
protocolFromSnapshot : RiskSnapshot -> SessionType
protocolFromSnapshot snap = case snap.riskLevel of
    Low    => lowRiskProtocol
    Medium => mediumRiskProtocol   -- includes 3DS step
    High   => highRiskProtocol     -- includes review step

openSession : (s : RiskSnapshot) -> Channel 1 (protocolFromSnapshot s)
```

The channel type is a function of the runtime risk snapshot. A
`Channel 1 (protocolFromSnapshot lowSnap)` is not the same type as
`Channel 1 (protocolFromSnapshot medSnap)` when the two snapshots have different
risk levels, so they cannot be used interchangeably.

**Test-spine items closed:** 7 (initiated payment resolved), 8 (channel consumed), 9 (protocol from risk)

---

## Part 5 — Code Changes

### 5.1 Stage 1: `01-java-simple-types/`

**Current state:** `authorize(Order, String)` — no risk decision parameter; `refund(Capture)`;
no `cancel`.

**Required changes:**

1. **`PaymentService.java`** — update method signatures:
   ```java
   // FROM:
   Authorization authorize(Order order, String approvalNote)
   Capture       capture(Authorization auth)
   Refund        refund(Capture cap)

   // TO:
   Result<Authorization>       authorize(Order order, RiskDecision risk, PaymentMethod method)
   Result<CaptureConfirmation> capture(Authorization auth)
   CancelConfirmation          cancel(Authorization auth)
   ```
   - `assessRisk(Order): RiskDecision` already exists — thread its result explicitly into
     `authorize`.
   - Remove `refund` from this service.
   - `processLowRisk`, `processMediumRisk`, `processHighRisk` helper methods — rewrite
     `processMediumRisk` to show the 3DS scenario with SUCCESS, FAILURE, and TIMEOUT arms,
     each calling `capture` or `cancel`. Add the comment: "The compiler does not require
     `cancel` on the TIMEOUT path. This is Charlie's bug. It closes at Stage 5."
   - Add `Result<T>` (sealed: `Ok<T> | Err<String>`) if not already present.

2. **New: `CancelConfirmation.java`** — final class, private constructor,
   factory `CancelConfirmation.from(Authorization auth)`.

3. **Rename `Capture.java` → `CaptureConfirmation.java`** — consistent naming across stages.

4. **`Authorization.java`** — private constructor; factory `from(Order, RiskDecision, PaymentMethod)`.
   The `RiskDecision` records which risk level was assessed (evidence that `assessRisk` was
   called). The `PaymentMethod` records which instrument was used.

5. **Remove `Refund.java`** from the main flow. A comment in `Demo.java` may note its
   existence as a separate concern referencing `CaptureConfirmation`.

### 5.2 Stage 2: `02-java5-generics/` → rename to `02-java-generics/`

**Current state:** `AuditTrail<E>`, `Validator<T>`; no phantom typestate; `authorize(Order, String)`.

**Required changes:**

1. **Introduce the `Payment<S>` phantom typestate.** New / replaced files:
   - `Payment.java` — as specified in Part 4 Stage 2. States: `Initiated`, `Authorized<R>`,
     `Captured`, `Cancelled`. All factory methods with private constructor.
   - `PaymentState.java` — plain (not sealed) marker class hierarchy.
   - `Risk.java`, `LowRisk.java`, `MediumRisk.java`, `HighRisk.java` — plain classes/interfaces.
   - `ThreeDSProof.java`, `ManualReviewApproval.java` — simple record-like value classes.

2. **Retain `AuditTrail<E>`** as the introductory generics example (data parameterization),
   presented before `Payment<S>` (state parameterization) in the IDE demo beat.

3. **`Demo.java`** — show the three risk paths. For medium risk:
   ```java
   Payment<Initiated> initiated = Payment.initiate(order, risk, method);

   ThreeDSResult result = simulateMediumRisk3DS();
   switch (result) {
       case SUCCESS(ThreeDSProof proof) -> {
           var auth     = Payment.authorize3DS(initiated, proof);
           var captured = Payment.capture(auth);
       }
       case FAILURE, TIMEOUT -> {
           // Note: the compiler does not require this cancel() call at Stage 2.
           var cancelled = Payment.cancel(initiated);
       }
   }
   ```

4. **`Authorization.java` / `Capture.java`** — superseded by `Payment.java`. Remove.

### 5.3 Stage 3: `03-java-function-types-sealed/`

**Current state:** Sealed risk, sealed PaymentMethod, `Result<T>`, public records for
`Authorization`, `Capture`, `Refund`. No phantom typestate. No `cancel`.

**Required changes:**

1. **Seal all hierarchies:**
   ```java
   sealed interface Risk         permits LowRisk, MediumRisk, HighRisk         {}
   sealed interface PaymentState permits Initiated, Authorized, Captured, Cancelled {}
   sealed interface PaymentMethod permits Card, Wallet, Invoice                 {}
   ```
   `Invoice` stays in `PaymentMethod`. Its arm in the payment routing switch:
   ```java
   case Invoice i -> throw new UnsupportedOperationException(
       "Invoice payments are handled by the invoicing service, not the payment processor.");
   ```
   This arm must exist; without it, the switch does not compile.

2. **Replace public records for lifecycle types with final classes.** Java `public record`
   canonical constructors cannot be made more restrictive than the record's own access
   level — a `public record` has a public canonical constructor. Lifecycle types whose
   construction must be controlled (`InitiatedPayment`, `AuthorizedPayment`, etc.) must
   use `final class` with a private constructor. Records are appropriate for pure value
   types (`LowRisk`, `ThreeDSProof`, `Card`, etc.).

3. **Replace `Refund` with `CancelConfirmation`** in the main flow. Optionally define
   `Refund` as a stub in a comment: "Refund is a separate protocol referencing CaptureId."

4. **`03-java-typestate/`** (the old Stage 4 code, renamed):
   - Update `PaymentState` to be sealed.
   - Add `Cancelled` to `PaymentState` alongside `Captured`. Remove `Refunded`.
   - Add `cancel(Payment<Initiated>)` and `cancel(Payment<Authorized<?>>)` factory methods.
   - Remove `refund()`.
   - Update `Demo.java` to show the 3DS scenario with `Payment<Cancelled>` on timeout.

5. **`Demo.java`** — IDE beat:
   - Beat A: sealed `Risk` → exhaustive switch → add `SuspectedFraud` → compile error (Bob).
   - Beat B (brief): sealed `PaymentMethod` with `Invoice` arm shown — exhaustiveness as
     documentation of completeness, not just error prevention.
   - The cancel path in the 3DS scenario is present and correct as convention; the
     compiler still does not enforce it.

### 5.4 Stage 4: `04-scala3-payment/` (renamed from `05-scala3-payment/`)

**Required changes:**

1. **`src/main/scala/payment/Domain.scala`:**
   - Replace `RefundedPayment` with `CancelledPayment` (see Part 4 Stage 4 for fields).
   - Add `InitiatedPayment` with `private[payment]` constructor.
   - Add `private[payment]` to `AuthorizedPayment[R]` and `CapturedPayment`.
   - Replace `def refund(...)` with `def cancel(auth: AuthorizedPayment[?]): CancelledPayment`
     and `def cancelInitiated(p: InitiatedPayment): CancelledPayment`.
   - Header comment: models `authorize` and `capture` as infallible; in production they
     return `Either[AuthError, ...]`. `cancel` is infallible by design. `refund` is a
     separate protocol, out of scope. `RiskDecision` is used here; Stage 5 uses the richer
     `RiskSnapshot` for dependent type computation.

2. **Session protocol** — update to capture/cancel:
   ```scala
   type PaymentProtocol =
     Send[RiskRequest, Receive[RiskResponse,
     Send[InitiateRequest, Receive[InitiateResponse,
     Choose[
       Send[CaptureRequest, Receive[CaptureResponse, End]],
       Send[CancelRequest,  Receive[CancelResponse,  End]]
     ]]]]]
   ```

3. **`Chan.scala`** — add `cancel` if not present (may be `selectRight`; rename/add for
   clarity).

4. **Demo / test files** — show 3DS scenario with `Choose` left/right for capture/cancel.
   Keep the runtime `AtomicBoolean` guard demonstration: dropping the channel produces a
   runtime error (not a compile error). This contrast is the setup for Stage 5.

5. **Run `sbt test`** after changes.

### 5.5 Stage 5: `05-idris2-payment/` (renamed from `06-idris2-payment/`)

**Required changes:**

1. Update protocol to `capture | cancel` (not `capture | refund`).

2. Add the `ThreeDSOutcome` case expression demo where the `Timeout` arm is shown first
   as the bug (`pure ()`) and then corrected (call `cancel` and `finish`). The compiler
   error message ("Quantity mismatch...") is the payoff of Charlie's story.

3. Verify `protocolFromSnapshot` still computes correctly with `RiskSnapshot`.

---

## Part 6 — Slide Changes

### 6.1 Renames and deletions

```
04-java-advanced-generics-typestate/  →  03-java-typestate/
05-scala3-payment/                    →  04-scala3-payment/
06-idris2-payment/                    →  05-idris2-payment/

slides/24-java-ceiling.typ    →  22-java-ceiling.typ
slides/25-stage5.typ          →  23-stage4.typ
slides/26-session-types.typ   →  24-session-types.typ
slides/stage5-mechanisms.typ  →  stage4-mechanisms.typ
slides/27-stage5-payoff.typ   →  25-stage4-payoff.typ
slides/28-stage6-bridge.typ   →  26-stage5-bridge.typ
slides/29-mltt-running.typ    →  27-mltt-running.typ
slides/30-stage6-payoff.typ   →  28-stage5-payoff.typ
slides/31-the-climb.typ       →  29-the-climb.typ
slides/32-agentic.typ         →  30-agentic.typ
slides/33-horizon.typ         →  31-horizon.typ
slides/34-close.typ           →  32-close.typ
```

DELETE: `22-stage4.typ`, `23-stage4-payoff.typ`.

### 6.2 `slides/04-charlie.typ` — REWRITE

**Incident:** Charlie's team added a `TIMEOUT` arm to the 3DS outcome handler. The
`SUCCESS` arm authorized and captured. The `FAILURE` arm cancelled. The `TIMEOUT` arm
returned a failure result without cancelling the `InitiatedPayment` (or `Authorization`
in the Stage 1 model). The authorization hold persisted on customer cards for 7 days.
Support tickets described "phantom charges" on orders customers knew were cancelled.
The team fixed the specific path once discovered. Over the following sprints, two more
new error paths were added, and the same class of mistake recurred.

**Narrative framing:** The payment flow correctly computed the right outcome on the
timeout path: the transaction was cancelled. What it failed to do was resolve the
obligation created by placing the hold. The `InitiatedPayment` was a resource that
required explicit disposal. Nothing in the language named that obligation.

### 6.3 `slides/15-test-spine.typ` — REVISE

**Flow diagram** — replace `Order → assess → authorize → capture → ×(refund | invoice)`:

```
                    assessRisk
Order   ─────────────────────────► RiskDecision
                                        │
                                    initiate
                                        │
                               InitiatedPayment        ← hold placed
                                        │
                           ┌────────────┴──────────────┐
                    [3DS / review]                [3DS / review]
                     succeeded                  failed or timed out
                           │                           │
                       authorize*                   cancel
                           │                           │
                   AuthorizedPayment           CancelledPayment
                           │
                        capture
                           │
                  CaptureConfirmation
```

Footnote: "Refund: separate protocol (references CaptureId). Invoice: separate flow (no hold cycle)."

**Test items:** replace with Part 3's 9 items.

### 6.4 `slides/19-stage3.typ` — REVISE

Stage 3 is sealed types. The phantom typestate is already present from Stage 2 — Stage 3
enriches it by sealing the hierarchies.

IDE beats:
- Beat A: Sealed `Risk`. Add `SuspectedFraud`. Compiler rejects the non-exhaustive switch.
  Bob's story closes.
- Beat B (brief): Sealed `PaymentMethod` with `Invoice` arm. Exhaustiveness as completeness.
- Carry-forward note: phantom typestate's `PaymentState` is also sealed. Pattern matching
  on payment state is now exhaustive.
- Explicit: cancel on the timeout path is still convention, not obligation.

### 6.5 `slides/20-stage3-payoff.typ` — REWRITE

Headline: "Bob Closed — Three Stories Remain"

Story-strip: Bob ✓, Alice open, Charlie open, Danielle open.

test-list: item 4 `just-gone`; summary "3 invariants closed ✓ — Stages 1–2"; items 5–6
`[S·4]` active; items 7–9 `[S·5]` active.

Speaker notes: Sealed types close exhaustiveness. The cancel path on the timeout arm is
present and correct in the Stage 3 code — but as convention. Nothing at the type level
names `InitiatedPayment` as an obligation. That encoding is Stage 5.

### 6.6 `slides/25-stage4-payoff.typ` (renamed from `27-stage5-payoff.typ`)

Headline: "Alice and Danielle Closed — One Story Remains"

Story-strip: Alice ✓, Bob ✓ (carried from S3), Danielle ✓, Charlie open.

test-list: items 5–6 `just-gone`; summary "4 invariants closed ✓ — Stages 1–3";
items 7–9 `[S·5]` active.

STILL EXPRESSIBLE: the session channel has a runtime guard, not a compile-time
obligation. Charlie's bug — a `TIMEOUT` arm that drops the channel — compiles in Scala 3.
The guard fires at the other end of the connection, not at the point of the mistake.

### 6.7 `slides/28-stage5-payoff.typ` (renamed from `30-stage6-payoff.typ`)

The dark "All four incidents are unrepresentable" slide — content unchanged.
Verify all four chips are closed. Update stage number references.

### 6.8 `slides/29-the-climb.typ` (renamed from `31-the-climb.typ`)

Six rows (0–5). No phantom-typestate-only row.

| Row | Stage | Encodes |
|---|---|---|
| 0 | JS | Nothing |
| 1 | Java simple types | Ordering + primitive safety |
| 2 | Java generics | `Payment<Initiated>` lifecycle + `Authorized<R>` approval-risk link |
| 3 | Java sealed | Exhaustive dispatch — no missing cases |
| 4 | Scala 3 | Boundary validity + protocol contract |
| 5 | Idris 2 | Linear resources + runtime-derived protocol shape |

"What it prevents" column:
- Row 2: "Wrong mechanism for risk level. Wrong lifecycle phase."
- Row 3: "Missing risk tier. Unhandled payment method."
- Row 5: "Hold placed but never resolved. Protocol shape mismatched to runtime risk."

### 6.9 `slides/21-bridge.typ` — REWRITE

Transition slide from Java stages to Scala 3.

What the Java toolkit can say by Stage 3: steps require their predecessor's typed output;
the confirmation mechanism must match the risk level; every risk tier is handled; every
payment method is handled.

What it cannot say: no predicate types for boundaries; no shared protocol definition; no
compile-time obligation on placed holds. The ceiling slide develops these; this bridge
names them.

Eyebrow: `Bridge · Stage 3 → Stage 4`

### 6.10 Other slides

- `slides/17-stage1.typ`: Show `assessRisk → authorize → {capture | cancel}` as the
  service outline. Emphasize that the interface signatures are the outline of the module.
- `slides/18-stage2.typ`: Show `Payment<Initiated> → authorize* | cancel →
  Payment<Authorized<R>> | Payment<Cancelled>` as the state machine visible in the type.
- `slides/30-agentic.typ`: Correct "The compiler's type error IS the specification" →
  "the type error tells the agent exactly which part of the specification was violated and
  what shape of value would satisfy it."

---

## Part 7 — `touying/deck.typ`

Stage map header comment:

```typst
// Stage numbering (0–5, six stages):
//   Stage 0  JS untyped baseline                    S17
//   Stage 1  Java simple types                      S18
//   Stage 2  Java generics + phantom typestate       S19
//   Stage 3  Java sealed + exhaustiveness            S20
//   Stage 4  Scala 3                                 S23
//   Stage 5  Idris 2 / MLTT / QTT                   S26+
```

Include sequence:

```typst
#include "slides/19-stage3.typ"
#include "slides/20-stage3-payoff.typ"
#include "slides/21-bridge.typ"
#include "slides/22-java-ceiling.typ"
#include "slides/23-stage4.typ"
#include "slides/24-session-types.typ"
#include "slides/stage4-mechanisms.typ"
#include "slides/25-stage4-payoff.typ"
#include "slides/scala3-ceiling.typ"
#include "slides/26-stage5-bridge.typ"
#include "slides/27-mltt-running.typ"
#include "slides/28-stage5-payoff.typ"
#include "slides/29-the-climb.typ"
#include "slides/30-agentic.typ"
#include "slides/31-horizon.typ"
#include "slides/where-to-start.typ"
#include "slides/32-close.typ"
```

---

## Part 8 — `PRESENTATION_SLIDE_PLAN.md`

Update the slide plan to reflect this document in full:

1. **Charlie's story**: 3DS timeout drops `Payment<Initiated>` hold without calling
   `cancel` — closes at Stage 5 (Idris QTT). See Part 2.
2. **Stage 2**: primary new mechanism is phantom typestate — `Payment<S>` with `Initiated`
   and `Authorized<R>`, the `initiate`/`authorize*`/`cancel` split.
3. **Stage 3**: phantom typestate is carried and sealed; Bob is the only story closing here.
4. **Payoff slides**: Bob only at Stage 3; Alice + Danielle at Stage 4; Charlie at Stage 5.
   See Part 6 §6.5, §6.6, §6.7.
5. **"Types as outline" thread**: service interface at Stage 1 is the module outline;
   phantom typestate at Stage 2 makes the state machine visible in the type;
   `PaymentProtocol` at Stage 4 makes the chain a named, shared contract.
6. **Stage numbering**: six stages, 0–5. No standalone phantom-typestate stage.

---

## Part 9 — `README.md`

Stage table:

| Stage | Language | New mechanism | Invariant closed |
|---|---|---|---|
| 0 | JavaScript | None | — |
| 1 | Java | Nominal types, typed returns | Ordering, primitive safety |
| 2 | Java | Generics, phantom typestate | Approval-risk match, lifecycle as type |
| 3 | Java 21 | Sealed hierarchies | Exhaustive dispatch |
| 4 | Scala 3 | Refinement + session types | Boundary validity, protocol contract |
| 5 | Idris 2 | QTT + dependent types | Linear resources, runtime-derived protocol |

`03-java-typestate/` is the sealed-typestate variant of Stage 3, not a separate stage.

---

## Part 10 — Verification Checklist

### Code
- [ ] `01-java-simple-types/`: compiles, runs; `authorize(Order, RiskDecision, PaymentMethod)`;
      `cancel(Authorization)`; `CancelConfirmation`; `Demo` shows 3DS arms with cancel comment
- [ ] `02-java-generics/`: compiles, runs; `Payment<S>` with `Initiated` and `Authorized<R>`;
      `authorize3DS/Auto/Review` factory methods; `cancel(Payment<Initiated>)`;
      Demo shows 3DS scenario with typed `Cancelled` path
- [ ] `03-java-function-types-sealed/`: compiles, runs; `Risk`, `PaymentState`, `PaymentMethod`
      sealed; `Invoice` in `PaymentMethod` with delegation arm; `cancel` present;
      lifecycle types are `final class` not `record`
- [ ] `03-java-typestate/`: compiles, runs; sealed `PaymentState`; `Cancelled` present;
      `Refunded` absent; `cancel()` present; 3DS demo shows `Payment<Cancelled>`
- [ ] `04-scala3-payment/`: `sbt compile` + `sbt test` pass; `private[payment]` on all
      lifecycle case classes; `CancelledPayment` and `InitiatedPayment` present;
      `RefundedPayment` absent; session protocol uses capture/cancel
- [ ] `05-idris2-payment/`: type-checks; protocol is `capture | cancel`; `Timeout` arm
      without `cancel` is a compile error (shown and documented)

### Slides
- [ ] `04-charlie.typ`: 3DS timeout / phantom hold incident; narrative framing per Part 6.2
- [ ] `15-test-spine.typ`: 9 items per Part 3; flow shows `initiate → {capture | cancel}`
- [ ] `20-stage3-payoff.typ`: Bob ✓ only; three stories open; correct `[S·N]` labels
- [ ] `25-stage4-payoff.typ`: Alice ✓, Danielle ✓, Bob ✓ carried; Charlie open;
      items 5–6 `just-gone`
- [ ] `28-stage5-payoff.typ`: all four chips ✓; items 7–9 `just-gone`
- [ ] `29-the-climb.typ`: 6 rows (0–5); row 2 shows `Initiated` + `Authorized<R>`;
      no phantom-typestate-only row
- [ ] No `S·6` or `S·7` anywhere in main deck
- [ ] `where-to-start.typ`: three-rung ladder; Stage 4 is Scala 3
- [ ] `14-lambda-cube.typ`: footer "Stages 1–4 / first two axes; Stage 5 / third"
- [ ] `30-agentic.typ`: corrected "type error IS the specification" line

### Build
- [ ] `typst compile touying/deck.typ deck.pdf` succeeds
- [ ] `make talk.pdfpc` succeeds
- [ ] `MANIM_VIDEO_PLAN.md`: Stage 5→4, Stage 6→5

---

## Part 11 — Stage 3 Time Budget

Stage 3 IDE demo: (A) sealed `Risk` → exhaustive switch → Bob; (B) sealed `PaymentMethod`
with `Invoice` arm. Beat A is the dramatic moment. Beat B is brief.

If time is tight: cut beat B; the `Invoice` exhaustiveness point can be narrated without
a live demo. Beat A alone closes Bob and demonstrates the mechanism.
