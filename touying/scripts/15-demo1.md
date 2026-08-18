A3-demo1 · cap 2:10 across both slides · Act 3 beat 4 of 8

TALKING POINTS
1. One sentence, then stop talking: I delete case Medium, watch the compiler
2. Switch to the IDE. Delete line 123. Say nothing while you type
3. Compile. Let the error land before you speak
4. Advance. Read the error aloud, verbatim, from the slide
5. the switch expression does not cover all possible input values
6. That is ∨E — you may not use a disjunction without covering every side
7. Undo, visibly, and recompile so the room sees it green again

VERBATIM

"I am going to delete the medium case. Watch what the compiler does."

... edit, compile, silence ...

"The switch expression does not cover all possible input values.

That is Gentzen's elimination rule, sixty seconds old, coming out of javac. You
may not use a disjunction without covering every side of it — and notice what
the compiler did not say. It did not say a test failed. It said this is not a
program."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE EDIT, EXACTLY
`03-java-function-types-sealed/Demo.java:123` — delete the whole line:

    case RiskDecision.Medium m -> "medium-risk 3DS path";   // Bob is forced to write this

Then recompile. `tools/capture-demos.sh` applies this same edit, runs the real
compiler, writes `demos/1-exhaustiveness.txt` and restores the source — it is the
authoritative description of what to type, because unlike prose it is executed
and cannot drift.

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

IF THE DEMO FAILS
Say nothing about it. Advance. The next slide is the same error, and the room
cannot tell the difference.
