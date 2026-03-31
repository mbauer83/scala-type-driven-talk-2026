import munit.FunSuite
import rules.{Policy, PolicyF, Fix, interpret, Interpretations, given}
import Interpretations.*

class RuleTests extends FunSuite:

  // ── Sample policies ────────────────────────────────────────────────────────

  val simpleRefundable: Policy =
    Policy.refundable(Policy.noConstraint)

  val simpleNonRefundable: Policy =
    Policy.nonRefundable(Policy.noConstraint)

  val complexPolicy: Policy =
    Policy.both(
      Policy.refundable(Policy.minStay(3)(Policy.noConstraint)),
      Policy.requiresIdentification(Policy.noConstraint)
    )

  val strictPolicy: Policy =
    Policy.nonRefundable(Policy.minStay(7)(Policy.requiresIdentification(Policy.noConstraint)))

  // ── describe ───────────────────────────────────────────────────────────────

  test("describe simple refundable policy"):
    val text = describe(simpleRefundable)
    assert(text.contains("Refundable"), text)

  test("describe complex policy contains all layers"):
    val text = describe(complexPolicy)
    assert(text.contains("Refundable"), text)
    assert(text.contains("Min stay"), text)
    assert(text.contains("identification"), text)

  // ── permitsCancellation ────────────────────────────────────────────────────

  test("permitsCancellation is true for refundable policy"):
    assertEquals(permitsCancellation(simpleRefundable), true)

  test("permitsCancellation is false for non-refundable policy"):
    assertEquals(permitsCancellation(simpleNonRefundable), false)

  test("permitsCancellation respects Both: both sub-policies must allow it"):
    val policy = Policy.both(Policy.refundable(Policy.noConstraint), Policy.nonRefundable(Policy.noConstraint))
    assertEquals(permitsCancellation(policy), false)

  test("permitsCancellation: noConstraint defaults to true (no restriction)"):
    assertEquals(permitsCancellation(Policy.noConstraint), true)

  // ── minimumNights ──────────────────────────────────────────────────────────

  test("minimumNights is 0 when no MinStay clause"):
    assertEquals(minimumNights(simpleRefundable), 0)

  test("minimumNights returns the configured days"):
    val policy = Policy.minStay(5)(Policy.noConstraint)
    assertEquals(minimumNights(policy), 5)

  test("minimumNights takes the stricter of two branches"):
    val policy = Policy.both(Policy.minStay(3)(Policy.noConstraint), Policy.minStay(7)(Policy.noConstraint))
    assertEquals(minimumNights(policy), 7)

  // ── analyze (combined single-pass) ────────────────────────────────────────

  test("analyze combines results in one traversal"):
    val a = analyze(complexPolicy)
    assertEquals(a.cancellationPermitted, true)
    assertEquals(a.minimumNights, 3)
    assertEquals(a.identificationRequired, true)

  test("analyze strict policy: no cancellation, long stay, identification required"):
    val a = analyze(strictPolicy)
    assertEquals(a.cancellationPermitted, false)
    assertEquals(a.minimumNights, 7)
    assertEquals(a.identificationRequired, true)

  // ── interpret is compositional ─────────────────────────────────────────────

  test("interpret with count algebra counts nodes"):
    val countNodes: PolicyF[Int] => Int =
      case PolicyF.Refundable(n)             => 1 + n
      case PolicyF.NonRefundable(n)          => 1 + n
      case PolicyF.MinStay(_, n)             => 1 + n
      case PolicyF.RequiresIdentification(n) => 1 + n
      case PolicyF.Both(l, r)                => 1 + l + r
      case PolicyF.NoConstraint              => 1

    // complexPolicy = Both( Refundable(MinStay(3, NoConstraint)), RequiresIdentification(NoConstraint) )
    // nodes: Both, Refundable, MinStay, NoConstraint, RequiresIdentification, NoConstraint = 6
    assertEquals(interpret(countNodes)(Policy.noConstraint),                    1)
    assertEquals(interpret(countNodes)(Policy.refundable(Policy.noConstraint)), 2)
    assertEquals(interpret(countNodes)(complexPolicy),                          6)
