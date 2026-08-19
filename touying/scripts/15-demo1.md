A3-demo1 · cap 2:10 across four slides · Act 3 beat 4 of 8

FILE     03-java-function-types-sealed/Demo.java:123
DIR      ~/workspace/scala-type-driven-talk/03-java-function-types-sealed
COMMAND  javac -d /tmp/out *.java
EDIT     delete the `case RiskDecision.Medium m ->` arm, whole line
BEFORE   open the terminal in DIR and run COMMAND once. 0.6s warm.
IF IT FAILS  advance and say nothing about it. The next two slides are the
             same session, recorded, and the room cannot tell.

RUNBOOK — the four slides, in order, with what you say on each

  SLIDE 15  dark card          »Let's delete case Medium and watch what the compiler does.»
            → then STOP TALKING and switch to the IDE.

  IDE       Open FILE. Narrate the navigation only, never the meaning:
            »Demo dot java … line one two three … that is the medium case …»
            make the EDIT
            »… and compile.»
            → run COMMAND   (↑ Enter)
            → SILENCE from here until the error appears. Do not fill it.

  SLIDE 16  recorded, the edit  Advance. One second. »There is the line, gone.»
            (If the IDE never got there, this slide IS the edit. Same sentence.)

  SLIDE 17  recorded, javac     Read it off the screen, VERBATIM, unhurried:
            »The switch expression does not cover all possible input values.»
            Beat. Then the one connecting sentence, and no more:
            »That is the elimination rule from the Gentzen slide, coming out
             of javac.»

  IDE       Undo. Run COMMAND again — silence is green here. Let the room see
            it. Say nothing.

  SLIDE 18  payoff              Bob's bug is now a compile error.

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================


THE SCRIPT IN ONE PIECE — for rehearsal. On the night you do not need it: the
RUNBOOK above carries every line at the point where you say it, which is why
this sits below the fold and off the presenter view.

TALKING POINTS
1. Let's delete case Medium and watch what the compiler does
2. (IDE) narrate the navigation only — file, line, delete, compile
3. (IDE) silence from compile until the error lands
4. Advance: there is the line, gone
5. Advance: read the error VERBATIM off the screen
6. the switch expression does not cover all possible input values
7. That is the elimination rule from the Gentzen slide, out of javac
8. Undo, recompile, let it go green. Say nothing

VERBATIM

"Let's delete the medium case and watch what the compiler does."

... navigate, delete, compile — narrate the navigation, then silence ...

"There is the line, gone.

The switch expression does not cover all possible input values.

That is the elimination rule from the Gentzen slide, coming out of javac: you may
not use a disjunction without covering every side of it."


WHAT TO DO IF IT FAILS
Nothing. Do not apologise, do not debug, do not explain. Advance. Slides 16 and
17 are the same session, recorded, and the room cannot tell the difference. The
only tell would be you announcing it.

WHY THE NARRATION RULE IS SPLIT
D-D says »silence during», and that is right about the *result* and wrong about
the *navigation*. Thirty seconds of a stranger typing in silence is a long time
in a room, and the audience does not know whether something has gone wrong.
Narrating where you are — file, line, what you are about to delete — costs them
nothing to process and keeps them with you. The silence that matters is between
pressing compile and the error appearing. Do not talk over that.

THE EDIT, EXACTLY
`03-java-function-types-sealed/Demo.java:123` — delete the whole line:

    case RiskDecision.Medium m -> »medium-risk 3DS path«;   // Bob is forced to write this

Then recompile. `tools/capture-demos.sh` applies this same edit, runs the real
compiler, writes `demos/1-exhaustiveness.txt` and restores the source — it is the
authoritative description of what to type, because unlike prose it is executed
and cannot drift.

Note the two scripts use different output directories: `capture-demos.sh` writes
classes to `/tmp/demo1-out`, and `capture-terminal.sh` — the one that produced
the frame the room will see — uses `/tmp/out`. **Type `/tmp/out` on stage**, so
the live line and the fallback frame are the same line.

WHY THERE ARE TWO SLIDES (D-D)
Dark setup card, then the captured output. The fallback is on the **following**
slide rather than hidden on this one: a fallback you have to un-hide is one you
fumble under stress, and a fallback on the next slide is recovered by the forward
key you are already pressing. When the demo works, that slide is a freeze-frame
to read the error from — which is what D-D asks for anyway, *read the error
aloud verbatim*.

DELIVERY, and this is the whole discipline
- **Before:** one sentence. Nothing else. They cannot read code and listen.
- **During:** silence. The typing is the beat.
- **After:** read it verbatim, then one sentence connecting it to the rule.
- **Then undo, visibly**, and recompile. The room should see it go green.

Placement is deliberately before the payoff slide, not after, so `A3-payoff-bob`
lands on a fresh memory of the error rather than on a description of one.

CAPTURED OUTPUT — verbatim, `demos/1-exhaustiveness.txt`

    Demo.java:121: error: the switch expression does not cover all possible input values
            String label = switch (decision) {
                           ^
    1 error

The error points at line 121, the head of the switch, not at the deleted line —
worth knowing so you are not hunting for 123 on the screen.

(The failure drill is above, under WHAT TO DO IF IT FAILS.)
