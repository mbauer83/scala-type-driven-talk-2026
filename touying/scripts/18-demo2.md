A3-demo2 · cap 1:45 across four slides · Act 3 beat 7 of 8

RUNBOOK — the four slides, in order, with what you say on each

  SLIDE 20  dark card          »Let's try to capture a payment that was never
                                authorized.»
            → STOP TALKING, switch to the IDE.

  IDE       Demo.java, line 170.  Navigation only:
            »line one seventy … the line that is commented out …»
            uncomment it
            »… and compile.»
            → SILENCE until the error appears.

  SLIDE 21  recorded, the edit  Advance. »The line is back.»

  SLIDE 22  recorded, javac     Read it VERBATIM, unhurried:
            »Incompatible types: Payment of Initiated cannot be converted to
             Payment of Authorized.»
            Beat. Then:
            »Nobody wrote a test for that, and nobody had to catch it in review.»

  IDE       Comment it out again. Recompile. Green. Say nothing.

  SLIDE 23  ceiling             Charlie closed, then what Java still accepts.

THIS ONE IS FASTER THAN DEMO 1, DELIBERATELY
Demo 1 establishes the pattern and cashes out Gentzen. This is a confirmation —
the room already knows what a live edit looks like here and what the error means.
Do not re-explain the mechanism. Part 6b's cut list has this as the fourth thing
to drop if the clock demands it: skip the IDE entirely, run slides 21 and 22, and
narrate over them. Nothing in the argument is lost.

WHAT TO DO IF IT FAILS
As Demo 1. Advance, say the same words, do not mention it.

TALKING POINTS
1. Let's try to capture a payment that was never authorized
2. (IDE) line 170, uncomment, compile — navigation only, then silence
3. Advance: the line is back
4. Advance: read VERBATIM — incompatible types, Initiated cannot be converted
   to Authorized
5. Nobody wrote a test for that, and nobody had to catch it in review
6. Re-comment, recompile, green. Say nothing

VERBATIM

"Let's try to capture a payment that was never authorized."

... navigate, uncomment, compile — narration then silence ...

"The line is back.

Incompatible types: Payment of Initiated cannot be converted to Payment of
Authorized.

Nobody wrote a test for that, and nobody had to catch it in review. Charlie's
transition is not a program any more."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE EDIT, EXACTLY
`04-java-advanced-generics-typestate/Demo.java:170` — uncomment the line marked
`← UNCOMMENT`:

    // Payment.capture(init);                                    // ← UNCOMMENT

`tools/capture-demos.sh` applies this edit, runs the real compiler, writes
`demos/2-typestate.txt` and restores the source.

CAPTURED OUTPUT — verbatim, `demos/2-typestate.txt`

    Demo.java:170: error: incompatible types: Payment<Initiated> cannot be converted to Payment<Authorized>
                Payment.capture(init);                                    // ← UNCOMMENT
                                ^
    Note: Some messages have been simplified; recompile with -Xdiags:verbose to get full output
    1 error

The `-Xdiags` note is real and is left off the slide; it adds nothing and costs a
line. Mention it only if someone asks why the message is short.

DELIVERY — same discipline as Demo 1
One sentence before, silence during, the error read verbatim after, then one
sentence tying it to the rule, then undo visibly. Do not narrate the typing.

WHY THIS ONE IS SHORTER THAN DEMO 1
Demo 1 had to establish the pattern and cash out Gentzen. This one is a
confirmation: the room already knows what a live edit looks like and what a
compile error means here. Part 6b's cut list has it as the fourth thing to go if
the clock demands it — narrate over the static pane and skip the IDE.

JOIN
Forwards: `A3-ceiling` closes Charlie, then names what Java still cannot reach.
