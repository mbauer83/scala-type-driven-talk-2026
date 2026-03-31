package demos

import protocol.*
import domain.*

/**
 * The full flight-booking session type, parameterised by passenger count N.
 *
 * Reading the type from left to right tells you exactly what will happen:
 *
 *   CLIENT                              SERVER
 *   ──────────────────────────────────────────────────────────────
 *   Send SearchCriteria          →
 *                                ←   Receive SearchResult
 *   Send Passengers[N]           →
 *                                ←   Receive Quote[N]        (for N pax)
 *                                ←   Receive HoldConfirmation
 *   ─── internal choice ───────────────────────────────────────────
 *   selectLeft  ─────────────── →   (server: awaitChoice → Left)
 *     Send PaymentFor[N]         →      (amount must match Quote[N])
 *                                ←   Receive Tickets[N]      (N tickets)
 *   End                                                       End
 *
 *   selectRight ─────────────── →   (server: awaitChoice → Right)
 *                                ←   Receive CancellationConfirmation
 *   End                                                       End
 *   ────────────────────────────────────────────────────────────────
 *
 * The type parameter N is a singleton literal Int (e.g. 2).
 * The compiler enforces that PaymentFor[N] and Tickets[N] carry the same N
 * as the Passengers[N] sent earlier.  A payment for 3 pax on a 2-pax booking
 * is a *type error*.
 */
object BookingProtocol:

  /** Full refundable protocol — client may cancel after hold. */
  type Refundable[N <: Int] =
    Send[SearchCriteria,
    Receive[SearchResult,
    Send[Passengers[N],
    Receive[Quote[N],
    Receive[HoldConfirmation,
    Choose[
      Send[PaymentFor[N],       // left:  pay
      Receive[Tickets[N],
      End]],
      Receive[CancellationConfirmation,  // right: cancel
      End]
    ]]]]]]

  /** Non-refundable protocol — no cancel branch, pay only. */
  type NonRefundable[N <: Int] =
    Send[SearchCriteria,
    Receive[SearchResult,
    Send[Passengers[N],
    Receive[Quote[N],
    Receive[HoldConfirmation,
    Send[PaymentFor[N],
    Receive[Tickets[N],
    End]]]]]]]

  /** Fast path when there are no available flights. */
  type NoAvailability =
    Send[SearchCriteria,
    Receive[SearchResult,
    End]]

  // ── Compile-time duality verification ────────────────────────────────────
  // The server's type must be the exact dual of the client's.
  // These summon calls are verified by the compiler.

  private object DualityVerification:
    import protocol.Dual
    // Dual of the client Refundable[2] is the server Refundable[2]
    summon[Dual[Refundable[2]] =:=
      Receive[SearchCriteria,
      Send[SearchResult,
      Receive[Passengers[2],
      Send[Quote[2],
      Send[HoldConfirmation,
      Offer[
        Receive[PaymentFor[2],
        Send[Tickets[2],
        End]],
        Send[CancellationConfirmation,
        End]
      ]]]]]]]
