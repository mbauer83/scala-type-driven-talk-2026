A4-demo5 · cap 1:35 across three slides · Act 4 beat 4 of 6

TERMINAL — the exact directory, the exact command. Same project and the same
sbt session as Demo 3, so if Demo 3 compiled, this one will.

    cd ~/workspace/scala-type-driven-talk/05-scala3-payment
    sbt

and on stage, at the prompt that is already open:

    sbt:payment> compile

Measured 8s. Do not start sbt here — it has been running since before Demo 3.

RUNBOOK — the three slides, in order, with what you say on each

  SLIDE     dark card           »Let's make the payment side wait for a message
                                 the other side is never going to send.»
            → STOP TALKING, switch to the IDE.

  IDE       05-scala3-payment/src/main/scala/demos/PaymentDemo.scala  line 141,
            the LAST line of `serverHighRisk`.  Navigation only:
            »the high-risk server … its very last step, where it sends the
             captured payment … and this side now wants to wait for the client
             to confirm it …»
            replace `ch5.send(captured)` with two lines:
                `val (ack, done)       = ch5.receive()`
                `done`
            »… and compile.»
            → TERMINAL, at the sbt prompt already running: `compile`
            → SILENCE until the error appears.

  SLIDE     recorded, the edit  Advance. »There it is — this side now waits
                                 for a confirmation.»

  SLIDE     recorded, scalac    Read the one line, unhurried:
                                »No given instance of CanReceive, for Send of
                                 CapturedPayment, End.»
                                Beat. Then the two sentences below.

  IDE       Put `ch5.send(captured)` back — one line replacing two. `compile`.
            Green. Say nothing.

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
   collective version (MB, 19 Aug)

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

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHY THIS DEMO EXISTS AT ALL (MB, 19 Aug)
Four incidents open the talk and, before this, three of them ended in a compiler
error the room watched arrive. Bob got two — Demo 1 and Demo 3. Charlie got Demo
2. Danielle got a sentence: *a server that sends where it should receive does not
compile.* She is the incident that motivates the most distinctive idea in the
deck, and she was the one the room had to take on trust.

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

THE BUG CLASS HAS TO BE LEGIBLE, EVEN WHEN THE EDIT IS ARTIFICE (MB, 19 Aug)
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
this edit, run the real `sbt -batch -warn compile`, write `demos/5-edit.txt`,
`demos/5-term.txt` and `demos/5-protocol-state.txt`, and restore the source.

CAPTURED OUTPUT — verbatim, `demos/5-term.txt`

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
As Demos 1 to 4. Advance, say the same words, do not mention it. sbt is the risk,
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
