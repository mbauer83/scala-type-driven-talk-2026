package runtime

import protocol.*
import java.util.concurrent.LinkedBlockingQueue

// In-memory transport: creates a dual pair of channels.
// (Channel[P], Channel[Dual[P]]) — the compiler enforces duality.

final class Transport:
  private[runtime] val aToB = new LinkedBlockingQueue[Any](128)
  private[runtime] val bToA = new LinkedBlockingQueue[Any](128)

object Transport:
  def open[P <: Protocol]: (Channel[P], Channel[Dual[P]]) =
    val t = new Transport
    val client = new Channel[P](outbox = t.aToB, inbox = t.bToA, label = "CLIENT")
    val server  = new Channel[Dual[P]](outbox = t.bToA, inbox = t.aToB, label = "SERVER")
    (client, server)
