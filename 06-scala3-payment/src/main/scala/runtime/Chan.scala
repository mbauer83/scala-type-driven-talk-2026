package runtime

import protocol.{*, given}
import java.util.concurrent.{BlockingQueue, LinkedBlockingQueue}
import java.util.concurrent.atomic.AtomicBoolean

// Typed session channel — each operation:
//   1. Consumes `this` channel (affine discipline via AtomicBoolean).
//   2. Returns a new Channel[Next] for the continuation.
//
// Sending on a Receive channel or using a channel twice are runtime-guarded
// compile errors (type mismatch) or runtime exceptions (double-use guard).

final class Channel[P <: Protocol] private[runtime] (
  private val outbox: BlockingQueue[Any],
  private val inbox:  BlockingQueue[Any],
  private val label:  String,
):
  private val used = new AtomicBoolean(false)

  private def consume(): Unit =
    if !used.compareAndSet(false, true) then
      throw IllegalStateException(s"[$label] Channel used twice")

  def send(using s: CanSend[P])(value: s.Msg): Channel[s.Rest] =
    consume()
    Logger.action(label, "SEND", value)
    outbox.put(value)
    new Channel[s.Rest](outbox, inbox, label)

  def receive()(using r: CanReceive[P]): (r.Msg, Channel[r.Rest]) =
    consume()
    val value = inbox.take().asInstanceOf[r.Msg]
    Logger.action(label, "RECV", value)
    (value, new Channel[r.Rest](outbox, inbox, label))

  def selectLeft()(using c: CanChoose[P]): Channel[c.L] =
    consume()
    outbox.put(true)
    Logger.decision(label, "SELECT", "Left")
    new Channel[c.L](outbox, inbox, label)

  def selectRight()(using c: CanChoose[P]): Channel[c.R] =
    consume()
    outbox.put(false)
    Logger.decision(label, "SELECT", "Right")
    new Channel[c.R](outbox, inbox, label)

  def awaitChoice()(using o: CanOffer[P]): Either[Channel[o.L], Channel[o.R]] =
    consume()
    val isLeft = inbox.take().asInstanceOf[Boolean]
    Logger.decision(label, "OFFER", if isLeft then "Left" else "Right")
    if isLeft then Left(new Channel[o.L](outbox, inbox, label))
    else Right(new Channel[o.R](outbox, inbox, label))

  def finish()(using ev: P =:= End): Unit =
    consume()
    Logger.finished(label)

object Logger:
  private val width = 70

  def header(title: String): Unit =
    val bar = "─" * width
    println(s"\n$bar\n  $title\n$bar")

  def section(title: String): Unit =
    val bar = "═" * width
    println(s"\n$bar\n  $title\n$bar")

  def action(side: String, op: String, value: Any): Unit =
    val tag  = s"[$side/$op]"
    val name = value.getClass.getSimpleName.replace("$", "")
    println(f"  $tag%-20s $name: $value")

  def decision(side: String, op: String, branch: String): Unit =
    val tag = s"[$side/$op]"
    println(f"  $tag%-20s branch → $branch")

  def finished(side: String): Unit =
    println(s"  [$side/DONE]          session complete")

  def info(msg: String): Unit =
    println(s"  [INFO]               $msg")

  def outcome(msg: String): Unit =
    println(s"  ► $msg")
    println("═" * width)
