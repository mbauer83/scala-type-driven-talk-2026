A4-demo3 · cap 1:55 across three slides · Act 4 beat 2 of 5

RUNBOOK — the three slides, in order, with what you say on each

  SLIDE     dark card           »Let's try to approve a medium-risk order the
                                 automatic way.»
            → STOP TALKING, switch to the IDE.

  IDE       05-scala3-payment/src/main/scala/demos/PaymentDemo.scala  line 123
            in `serverMediumRisk`.  Navigation only:
            »the medium-risk server … the line that builds the approval …»
            swap `ThreeDSApproved(proof)` for `AutoApproved`
            »… and compile.»
            → SILENCE until the error appears. sbt is slower than javac; let it
              be slow, and do not fill the gap.

  SLIDE     recorded, the edit  Advance. »There is the swap.»

  SLIDE     recorded, scalac    Read it, unhurried:
                                »Found: AutoApproved. Required: an Approval of
                                 MediumRisk.»
                                Beat. Then the two sentences below.

  IDE       Put the proof back. Recompile. Green. Say nothing.

TALKING POINTS
1. Let's try to approve a medium-risk order the automatic way
2. (IDE) serverMediumRisk, line 123, swap the approval — then silence
3. Advance: there is the swap
4. Advance: read it — Found AutoApproved, Required an Approval of MediumRisk
5. Demo one made Bob write the medium case
6. This one makes the medium case do the medium thing
7. The whole mechanism is the one parameter on Approval

VERBATIM

"Let's try to approve a medium-risk order the automatic way."

... navigate, swap the approval, compile — then silence ...

"There is the swap.

Found: AutoApproved. Required: an Approval of MediumRisk.

The first demo made Bob write the medium-risk case. This one makes the medium-risk
case do the medium-risk thing, and the whole mechanism is that one parameter on
`Approval`."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE EDIT, EXACTLY — AND IT IS EXECUTED, NOT DESCRIBED
`05-scala3-payment/src/main/scala/demos/PaymentDemo.scala:123`, inside
`serverMediumRisk`:

    val authorized: AuthorizedPayment[MediumRisk] =
      authorize(order, ThreeDSApproved(proof))     ->  authorize(order, AutoApproved)

`tools/capture-demos.sh 3` and `tools/capture-terminal.sh` both apply exactly
this edit, run the real `sbt compile`, write `demos/3-edit.txt`,
`demos/3-term.txt` and `demos/3-risk-indexed-approval.txt`, and restore the
source. Re-run either after any change to the Scala code.

DO NOT REMOVE THE ASCRIPTION ON LINE 122
`val authorized: AuthorizedPayment[MediumRisk] =` is what makes this demo
readable. With it: one error, on the edited line, naming both types. Without it
the error surfaces a line later at `ch4.send(...)` as `Required: ?1.Msg`, with
the real type buried in a seven-line where-clause and two cascading not-found
errors behind it — about twenty lines of noise on a projector. This is recorded
in `tools/capture-demos.sh` as well, because it has been rediscovered once.

CAPTURED OUTPUT — verbatim, `demos/3-term.txt`

    $ sbt compile
    [error] -- [E007] Type Mismatch Error: …/PaymentDemo.scala:123:23
    [error] 123 |      authorize(order, AutoApproved)
    [error]     |                       ^^^^^^^^^^^^
    [error]     |                       Found:    payment.AutoApproved.type
    [error]     |                       Required: payment.Approval[payment.MediumRisk]

`payment.AutoApproved.type` is the singleton type of the object — `AutoApproved`
is a `case object`, so its type is written that way. Say »AutoApproved« and leave
`.type` unread; it is one more piece of Scala notation and it teaches nothing
here. If somebody asks: every object in Scala has a type of its own, inhabited by
that one object.

THE V1 FRAMING OF THIS DEMO IS WRONG, AND WAS WRONG IN THE PLAN TOO
v1's note said the swap itself type-checks and the error lands one line later at
`ch.send`, so »the protocol context is what catches Bob's mistake«. That was true
of an earlier shape of the file and is not true of this one — the ascription
moves the error onto the edited line, where it belongs. The protocol catching a
mismatch is a real and separate fact; it is `A4-sessions`, and it is Danielle's,
not Bob's.

WHY THIS DEMO AND NOT THE REFINEMENT ONE
`refineUnsafe[MinLength[1]]` on an empty literal failing at compile time is the more surprising
error, and it is one line with no story attached. This one closes a named
incident the room has been carrying since minute four, and it is the first item
on the list `A3-ceiling` just read out. `PaymentDemo.demo4()` has the refinement
version if the Q&A wants it.

WHAT TO DO IF IT FAILS
As Demos 1 and 2. Advance, say the same words, do not mention it. `sbt` is the
one real risk here — it is slow and it can decide to resolve dependencies. If it
has not compiled within about twenty seconds, advance to the recorded frames and
carry on talking.

JOIN
Backwards: `A4-opens`, sixty seconds old, put `Approval[R]` on the wall.
Forwards: `A4-sessions` takes the third thing on `A3-ceiling`'s list, which is
the one Java cannot reach at all.
