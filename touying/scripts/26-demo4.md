A5-demo4 · cap 2:10 across three slides · Act 5 beat 2 of 3

RUNBOOK — the three slides, in order, with what you say on each

  SLIDE     dark card           »Let's drop the channel without closing it.»
            → STOP TALKING, switch to the editor.

  EDITOR    06-idris2-payment/src/Main.idr  line 115
            in `settleServer`.  Navigation only:
            »the refund branch … the last thing it does is close the session …»
            replace `finish done` with `pure ()`
            »… and build.»
            → SILENCE. idris2 rebuilds five modules; let it.

  SLIDE     recorded, the edit  Advance. »The close is gone.»

  SLIDE     recorded, idris2    Read it, unhurried, both lines:
                                »There are zero uses of linear name done.»
                                »Linearly bounded variables must be used exactly
                                 once.»
                                Beat. Then the two sentences below.

  EDITOR    Put `finish done` back. Rebuild. Green. Say nothing.

TALKING POINTS
1. Let's drop the channel without closing it
2. (Editor) settleServer, line 115, finish done becomes pure () — then silence
3. Advance: the close is gone
4. Advance: read both lines — zero uses of linear name done; linearly bounded
   variables must be used exactly once
5. The compiler counted the uses of one variable, got zero, and refused
6. Do NOT say "nobody wrote a test" here — Demo 2 has it, A5-payoff has the
   collective version, and a third telling is one too many (MB, 19 Aug)
7. That is the last of the four accounted for

VERBATIM

"Let's drop the channel without closing it."

... navigate, replace `finish done` with `pure ()`, build — then silence ...

"The close is gone.

There are zero uses of linear name `done`. Linearly bounded variables must be
used exactly once.

The compiler counted the uses of one variable, got zero, and refused to build
the program — and that is the last of the four accounted for."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THE EDIT, EXACTLY — AND IT IS EXECUTED, NOT DESCRIBED
`06-idris2-payment/src/Main.idr:115`, in `settleServer`'s refund branch:

    done <- sendLogged refunding (refund captured)
    finish done          ->   pure ()

**Replace it. Do not comment it out.** `finish done` is the last statement of its
`do` block, so deleting it yields *Last statement in do block must be an
expression* — a syntax complaint, not the linearity error the slide promises.
This is recorded in `tools/capture-demos.sh` because the plan described the edit
wrongly once and only running it caught that.

`tools/capture-demos.sh 4` and `tools/capture-terminal.sh` both apply this edit,
run the real `idris2 --build payment.ipkg`, write `demos/4-edit.txt`,
`demos/4-term.txt` and `demos/4-linearity.txt`, and restore the source.

CAPTURED OUTPUT — verbatim, `demos/4-term.txt`

    $ idris2 --build payment.ipkg
    5/5: Building Main (src/Main.idr)
    Error: While processing right hand side of settleServer. There are 0 uses of
    linear name done.

    Main:115:7--115:11
     115 |       done <- sendLogged refunding (refund captured)
                 ^^^^

    Suggestion: linearly bounded variables must be used exactly once.

Two things make this the best error in the deck. It points at the **binding**,
not at the missing call — the compiler is not looking for a `finish`, it is
counting a variable. And the suggestion line is the rule stated in plain English
by the compiler itself, which is worth reading out as the second line rather than
paraphrasing.

Say »zero uses« for `0 uses`. Everything else is read as written.

WHY THIS DEMO CLOSES THE ACT AND NOT THE Π ONE
`protocolFromSnapshot` flowing into `openSession` is the bigger idea, and it has
no failure to show: it either compiles or you have written a different program.
Linearity has a one-line failure that the room has been told about twice — once
in the primer as *a binding that must be used exactly once*, and once at
`A4-ceiling` as the thing Scala cannot state. This is the payoff for both.

WHAT TO DO IF IT FAILS
As Demos 1 to 3. Advance, say the same words, do not mention it. `idris2 --build`
rebuilds five modules and is the slowest of the four demos; if nothing has
appeared in about twenty-five seconds, advance to the recorded frames and keep
talking.

JOIN
Backwards: `A5-mltt` set up the `1` and did not fire it. Forwards: `A5-payoff`,
the dark slide — let the error sit for a beat before advancing into it.
