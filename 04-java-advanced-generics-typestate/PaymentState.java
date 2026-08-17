// Stage 05: Typestate encoding via phantom types.
//
// These marker interfaces carry no data — they only exist at the type level.
// Payment<Initiated> and Payment<Authorized> are different types to the compiler,
// even though they share the same runtime class.
//
// Key invariants now enforced by the type system:
//   - Payment.capture() only accepts Payment<Authorized>     — capture before auth = compile error
//   - Payment.refund() only accepts Payment<Captured>        — refund before capture = compile error
//   - Payment.authorizeAuto() only accepts Payment<Initiated> — double-auth = compile error
//
// What still goes wrong:
//   - The risk level is not encoded in the type of the payment.
//   - authorizeAuto() can be called even for a medium-risk order — the type
//     doesn't know that 3DS was required.
//   - The protocol structure (who sends what to whom) is still in documentation.

public sealed interface PaymentState permits
    PaymentState.Initiated,
    PaymentState.Authorized,
    PaymentState.Captured,
    PaymentState.Refunded {

    final class Initiated  implements PaymentState {}
    final class Authorized implements PaymentState {}
    final class Captured   implements PaymentState {}
    final class Refunded   implements PaymentState {}
}
