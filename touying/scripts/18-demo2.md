A3-demo2 · cap 1:45 across both slides · Act 3 beat 7 of 8

TALKING POINTS
1. One sentence: I capture a payment that was never authorized
2. Switch to the IDE. Uncomment line 170. Say nothing
3. Compile. Let it land
4. Advance. Read it aloud: incompatible types, Initiated cannot be converted to
   Authorized
5. Nobody wrote a test and nobody reviewed it — the transition is not a program
6. Undo, visibly, recompile

VERBATIM

"I am going to capture a payment that was never authorized."

... uncomment, compile, silence ...

"Incompatible types: Payment of Initiated cannot be converted to Payment of
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
