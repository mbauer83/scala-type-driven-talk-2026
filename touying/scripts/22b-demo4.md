A4-demo4 · cap 1:35 across three slides · Act 4 beat 4 of 6

FILE     05-scala3-payment/src/main/scala/demos/PaymentDemo.scala:141
         the LAST line of `serverHighRisk`
DIR      ~/workspace/scala-type-driven-talk/05-scala3-payment
COMMAND  compile     at the same `sbt:scala3-payment>` prompt as Demo 3
EDIT     `ch5.send(captured)`
           -> `val (ack, done)       = ch5.receive()`
              `done`
BEFORE   nothing — that window has been open since before Demo 3. If it was
         closed: `cd` to DIR and run `sbt` again. 8s.
IF IT FAILS  advance and say nothing about it. The next two slides are the
             same session, recorded, and the room cannot tell.

RUNBOOK — the three slides, in order, with what you say on each

  SLIDE     dark card           »Let's make the payment side wait for a message
                                 the other side is never going to send.»
            → STOP TALKING, switch to the IDE.

  IDE       Open FILE. Navigation only:
            »the high-risk server … its very last step, where it sends the
             captured payment … and this side now wants to wait for the client
             to confirm it …»
            make the EDIT
            »… and compile.»
            → run COMMAND
            → SILENCE until the error appears.

  SLIDE     recorded, the edit  Advance. »There it is — this side now waits
                                 for a confirmation.»

  SLIDE     recorded, scalac    Read the one line, unhurried:
                                »No given instance of CanReceive, for Send of
                                 CapturedPayment, End.»
                                Beat. Then:
                                »There is no evidence that you may receive here,
                                 because what is left of this conversation begins
                                 with a send. Untyped, that is not an exception
                                 anybody catches — it is two services waiting for
                                 each other. The drift Danielle found three weeks
                                 in has nowhere left to happen.»

  IDE       Put `ch5.send(captured)` back — one line replacing two. Run
            COMMAND. Green. Say nothing.

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================


THE SCRIPT IN ONE PIECE — for rehearsal. On the night you do not need it: the
RUNBOOK above carries every line at the point where you say it, which is why
this sits below the fold and off the presenter view.

TALKING POINTS
1. Let's make the payment side wait for a message the other side never sends
2. (IDE) serverHighRisk, line 141, its last step — instead of sending the
   capture, wait for the client to acknowledge it
3. Advance: there it is — this side now waits for a confirmation
4. Advance: read it — no given instance of CanReceive, for Send of
   CapturedPayment, End
5. No evidence that you may receive here: what is left of the conversation
   begins with a send
6. Untyped, this is not an exception anybody catches — it is two services
   waiting for each other
7. The drift Danielle found three weeks in has nowhere left to happen — that
   clause belongs HERE now, not on A4-sessions
8. Do NOT say "nobody wrote a test" — Demo 2 has it, A5-payoff has the
   collective version

VERBATIM

"Let's make the payment side wait for a message the other side is never going to
send."

... navigate, `send` becomes `receive`, compile — then silence ...

"There it is — this side now waits for a confirmation.

No given instance of CanReceive, for Send of CapturedPayment, End.

There is no evidence that you may receive here, because what is left of this
conversation begins with a send. Untyped, that is not an exception anybody
catches — it is two services waiting for each other. The drift Danielle found
three weeks in has nowhere left to happen."


THE POSITION OF THE EDIT IS THE WHOLE TRICK
Five edits produce this class of error and four of them cannot be read from a
stage. Measured, all in `05-scala3-payment`:

  send a message the protocol has no room for   15 lines, `Required: ?1.Msg`
  hand a server the wrong channel               ~35 lines, both protocols expanded
  pass the wrong client channel                  2 clean lines — but nominal only,
                                                 a phantom parameter in Java prints
                                                 the same thing
  skip or swap a step mid-protocol              12 lines plus two cascading
                                                 "not found" errors
  THIS ONE — the last operation                  one error, one line, all concrete

Nothing downstream inherits the error type, because there is no downstream, and
the protocol remaining at that point is `Send[CapturedPayment, End]` — two
constructors, so it prints inline instead of as a nested block. **If this edit
ever has to move, keep it on the last operation of whichever server it moves to.**

THE EDIT, EXACTLY — AND IT IS EXECUTED, NOT DESCRIBED
`05-scala3-payment/src/main/scala/demos/PaymentDemo.scala:141`, the last line of
`serverHighRisk`:

    ch5.send(captured)   ->   val (ack, done)       = ch5.receive()
                              done

THE BUG CLASS HAS TO BE LEGIBLE, EVEN WHEN THE EDIT IS ARTIFICE
The first version of this edit was the one-liner `ch5.receive()._2`, which
produces the identical error and is not a mistake anybody has ever made — `._2`
on a receive is a shape chosen to satisfy a return type, and a room that notices
that stops believing the demo. What is on stage now is a change somebody writes
on a Tuesday: the payment side decides the high-risk flow should end with the
client confirming the capture, so it waits for an acknowledgement. The client's
contract has no such message in it. That is Danielle's incident exactly — each
side correct against its own picture of the conversation — and untyped it is not
an exception anybody catches, it is two services waiting for each other.

Every demo in the deck is arranged; the arrangement is allowed. What is not
allowed is a bug class the room cannot recognise from its own work.

`tools/capture-demos.sh 5` and `tools/capture-terminal.sh` both apply exactly
this edit, run the real `sbt -batch -warn compile`, write `demos/4-edit.txt`,
`demos/4-term.txt` and `demos/4-protocol-state.txt`, and restore the source.

CAPTURED OUTPUT — verbatim, `demos/4-term.txt`

    $ sbt compile
    [error] -- [E172] Type Error: …/PaymentDemo.scala:141:41
    [error] 141 |    val (ack, done)       = ch5.receive()
    [error]     |                                         ^
    [error]     |No given instance of type protocol.CanReceive[protocol.Send[
    [error]     |payment.CapturedPayment, protocol.End]] was found for parameter
    [error]     |r of method receive in class Channel

Say »no given instance of CanReceive« and read the type as *Send of
CapturedPayment, End*. Leave `for parameter r of method receive in class
Channel` unread — it is the compiler naming its own plumbing, and the room has
the point by then.

`serverHighRisk` IS CODE THE DECK NEVER SHOWS, AND THAT IS FINE HERE
`A4-sessions` puts `LowRiskProtocol` on the wall, not the high-risk one. It costs
nothing: the error names the protocol that is left, so the room reads what the
conversation owed without having seen the whole of it. The dark card says which
conversation it is in one clause. The alternative — the same edit inside the
low-risk server's refund branch — was tried and degrades to `?1.L`, because
there the channel type comes through the `awaitChoice` evidence.

WHAT TO DO IF IT FAILS
As Demos 1 to 3. Advance, say the same words, do not mention it. sbt is the risk,
and it is the same sbt session Demo 3 already used — if that one answered, this
one will. If nothing has appeared in about twenty seconds, advance to the
recorded frames and carry on.

JOIN
Backwards: `A4-sessions` states the property — *a server that sends where it
should be receiving does not compile* — and this is the property being checked
in front of the room rather than asserted at it. Say the demo line as the natural
next breath after that sentence; do not re-explain `Dual`.
Forwards: `A4-mechanisms` names the machinery, and `CanSend[P]` on that slide is
the twin of the `CanReceive` the compiler has just failed to find. The row will
land harder for having been watched fail. Nothing in the mechanisms script needs
to change for that; it is a join the room makes on its own.
