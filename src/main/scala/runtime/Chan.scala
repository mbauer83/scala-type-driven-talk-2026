package runtime

import protocol.{*, given}
import java.util.concurrent.{BlockingQueue, LinkedBlockingQueue}
import java.util.concurrent.atomic.AtomicBoolean

/**
 * LAYER 4 — Typed channel with affine usage discipline
 *
 * Channel[P <: Protocol] represents one end of a communication channel that is
 * currently in protocol state P.  Every operation:
 *
 *   1. Consumes `this` channel (affine: used at most once).
 *   2. Returns a new Channel[Next] representing the *next* protocol state.
 *
 * This makes it impossible to:
 *   • Send when you should receive  (type error: evidence missing)
 *   • Receive when you should send  (same)
 *   • Use a channel after it has been consumed  (runtime guard + convention)
 *   • Finish without closing        (End forces an explicit finish() call)
 *
 * ─── Affine discipline ───────────────────────────────────────────────────────
 * Scala lacks linear types.  We simulate the "at most once" rule with:
 *   • An AtomicBoolean `used` flag that throws on double-use.
 *   • By-convention: always rebind to the returned Channel (not `this`).
 *
 * ─── Type-state pattern ──────────────────────────────────────────────────────
 * The protocol type P is a phantom type; it only exists at the type level.
 * Each operation uses evidence constraints to restrict which operations are
 * valid in state P.  Calling `send` on a `Channel[Receive[...]]` is a
 * compile error.
 */
final class Channel[P <: Protocol] private[runtime] (
  private val outbox: BlockingQueue[Any],
  private val inbox:  BlockingQueue[Any],
  private val label:  String,
):
  private val used = new AtomicBoolean(false)

  private def consume(op: String): Unit =
    if !used.compareAndSet(false, true) then
      throw IllegalStateException(
        s"[$label] Channel already consumed!  Did you use this Channel after an operation?"
      )

  // ─── Protocol operations ────────────────────────────────────────────────────

  /**
   * Send a value on this channel, advancing to the next protocol state.
   * Only valid when P = Send[Msg, Rest]; Msg and Rest are inferred from P.
   * The `using` clause comes first so that `s.Msg` is in scope for `value`.
   */
  def send(using s: CanSend[P])(value: s.Msg): Channel[s.Rest] =
    consume("send")
    Logger.action(label, "SEND", value)
    outbox.put(value)
    new Channel[s.Rest](outbox, inbox, label)

  /**
   * Receive a value from this channel, advancing to the next protocol state.
   * Only valid when P = Receive[Msg, Rest]; Msg and Rest are inferred from P.
   */
  def receive()(using r: CanReceive[P]): (r.Msg, Channel[r.Rest]) =
    consume("receive")
    val value = inbox.take().asInstanceOf[r.Msg]
    Logger.action(label, "RECEIVE", value)
    (value, new Channel[r.Rest](outbox, inbox, label))

  /**
   * Select the left branch of an internal choice.
   * Only valid when P = Choose[L, R]; L and R are inferred from P.
   */
  def selectLeft()(using c: CanChoose[P]): Channel[c.L] =
    consume("selectLeft")
    outbox.put(true)
    Logger.decision(label, "SELECT", "Left")
    new Channel[c.L](outbox, inbox, label)

  /**
   * Select the right branch of an internal choice.
   * Only valid when P = Choose[L, R]; L and R are inferred from P.
   */
  def selectRight()(using c: CanChoose[P]): Channel[c.R] =
    consume("selectRight")
    outbox.put(false)
    Logger.decision(label, "SELECT", "Right")
    new Channel[c.R](outbox, inbox, label)

  /**
   * Wait for the other end's choice, then return the chosen branch.
   * Only valid when P = Offer[L, R]; L and R are inferred from P.
   */
  def awaitChoice()(using o: CanOffer[P]): Either[Channel[o.L], Channel[o.R]] =
    consume("awaitChoice")
    val isLeft = inbox.take().asInstanceOf[Boolean]
    Logger.decision(label, "AWAIT", if isLeft then "Left" else "Right")
    if isLeft then Left(new Channel[o.L](outbox, inbox, label))
    else Right(new Channel[o.R](outbox, inbox, label))

  /**
   * Close the channel.  Only valid when P =:= End.
   * Calling finish() on a non-End channel is a compile error.
   */
  def finish()(using ev: P =:= End): Unit =
    consume("finish")
    Logger.finished(label)

// ─── Structured logger ────────────────────────────────────────────────────────

object Logger:
  private val width = 70

  def header(title: String): Unit =
    val bar = "─" * width
    println(s"\n$bar")
    println(s"  $title")
    println(bar)

  def action(side: String, op: String, value: Any): Unit =
    val tag  = s"[$side/$op]"
    val name = value.getClass.getSimpleName.replace("$", "")
    println(f"  $tag%-20s $name: $value")

  def decision(side: String, op: String, branch: String): Unit =
    val tag = s"[$side/$op]"
    println(f"  $tag%-20s branch → $branch")

  def finished(side: String): Unit =
    println(s"  [$side/DONE]          session complete")

  def error(side: String, msg: String): Unit =
    println(s"  [$side/ERROR]         $msg")

  def info(msg: String): Unit =
    println(s"  [INFO]               $msg")

  def footer(result: String): Unit =
    println(s"  ► $result")
    println("─" * width)
