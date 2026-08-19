A4-demo3 · cap 1:45 across three slides · Act 4 beat 2 of 6

FILE     05-scala3-payment/src/main/scala/demos/PaymentDemo.scala:123
         in `serverMediumRisk`
DIR      ~/workspace/scala-type-driven-talk/05-scala3-payment
COMMAND  compile     typed at the sbt prompt — NOT `sbt compile` in the shell
RUN      run         same prompt; mainClass is demos.PaymentDemo
EDIT     `authorize(order, ThreeDSApproved(proof))`
           -> `authorize(order, AutoApproved)`
BEFORE   in a terminal, before the act starts:
             cd ~/workspace/scala-type-driven-talk/05-scala3-payment
             sbt
         it loads for a few seconds and settles on `sbt:scala3-payment>`. Leave
         that window open — Demo 4 uses the same session, so do not exit it.
         From there `compile` answers in 8s. Starting sbt cold in front of the
         room is 30s and up, and the largest time risk in the talk.
IF IT FAILS  advance and say nothing about it. The next two slides are the
             same session, recorded, and the room cannot tell.

RUNBOOK — the three slides, in order, with what you say on each

  SLIDE     dark card           »Let's try to approve a medium-risk order the
                                 automatic way.»
            → STOP TALKING, switch to the IDE.

  IDE       Open FILE. Navigation only:
            »the medium-risk server … the line that builds the approval …»
            make the EDIT
            »… and compile.»
            → run COMMAND
            → SILENCE until the error appears. sbt is slower than javac; let it
              be slow, and do not fill the gap.

  SLIDE     recorded, the edit  Advance. »There is the swap.»

  SLIDE     recorded, scalac    Read it, unhurried:
                                »Found: AutoApproved. Required: an Approval of
                                 MediumRisk.»
                                Beat. Then:
                                »The first demo made Bob write the medium-risk
                                 case. This one makes the medium-risk case do
                                 the medium-risk thing, and the whole mechanism
                                 is that one parameter on Approval.»

  IDE       Put the proof back. Run COMMAND. Green. Say nothing.

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================


THE SCRIPT IN ONE PIECE — for rehearsal. On the night you do not need it: the
RUNBOOK above carries every line at the point where you say it, which is why
this sits below the fold and off the presenter view.

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


THE EDIT, EXACTLY — AND IT IS EXECUTED, NOT DESCRIBED
`05-scala3-payment/src/main/scala/demos/PaymentDemo.scala:123`, inside
`serverMediumRisk`:

    val authorized: AuthorizedPayment[MediumRisk] =
      authorize(order, ThreeDSApproved(proof))     ->  authorize(order, AutoApproved)

`tools/capture-demos.sh 3` and `tools/capture-terminal.sh` both apply exactly
this edit, run the real `sbt -batch -warn compile`, write `demos/3-edit.txt`,
`demos/3-term.txt` and `demos/3-risk-indexed-approval.txt`, and restore the
source. Re-run either after any change to the Scala code.

THE PROMPT IS `sbt:scala3-payment>`, CHECKED
the `name` setting in `05-scala3-payment/build.sbt:6` is scala3-payment, and sbt
announces
*set current project to scala3-payment* on load. An earlier draft of this script
wrote `sbt:payment>` from memory, which is the project the DIRECTORY is named
after, not the one the build declares.

Also seen on that run: *sbt server could not start because there's another
instance of sbt running on this build.* It is a warning, not a failure — it comes
from a Metals/Bloop sbt server already holding the build, and the session works
anyway. If it appears on the night, ignore it.

ONE MISMATCH TO KNOW ABOUT, AND IT IS A DELIBERATE TRADE
The recorded fallback frame's first line reads `$ sbt compile`, because the
capture runs non-interactively. If you take the advice above and keep an sbt
session open, what the room watches you type is `compile` at the
`sbt:scala3-payment>`
prompt — and the fallback frame, if you ever need it, says `$ sbt compile`.
Nobody will notice, and the twenty-plus seconds a cold `sbt compile` can cost in
front of an audience is a real risk against a cosmetic one. If you would rather
they match exactly, the line is written by `echo` in `tools/capture-terminal.sh`
(`frame3`) and can say whatever you decide to type.

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
