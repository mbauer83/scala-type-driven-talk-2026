package runtime

import protocol.*
import java.util.concurrent.LinkedBlockingQueue

/**
 * LAYER 4 — In-memory transport
 *
 * A Transport is a pair of blocking queues connecting two ends of a session.
 * It creates a dual pair of channels:
 *
 *   (Channel[P], Channel[Dual[P]])
 *
 * — one for each side.  The compiler guarantees the pair is always dual,
 *   so mismatched client/server protocols are a compile error.
 */
final class Transport:
  // Two directional queues; each end sends on one, receives on the other.
  private[runtime] val aToB = new LinkedBlockingQueue[Any](128)
  private[runtime] val bToA = new LinkedBlockingQueue[Any](128)

object Transport:
  /**
   * Open a transport and return the two dual channel ends.
   *
   * `client` has protocol P.
   * `server` has protocol Dual[P] — enforced by the return type.
   */
  def open[P <: Protocol]: (Channel[P], Channel[Dual[P]]) =
    val t = new Transport
    val client = new Channel[P](outbox = t.aToB, inbox = t.bToA, label = "CLIENT")
    val server = new Channel[Dual[P]](outbox = t.bToA, inbox = t.aToB, label = "SERVER")
    (client, server)
