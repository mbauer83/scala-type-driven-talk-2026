VERBATIM · cap 0:50 · word count is computed by `make timing`, not stated here.

TALKING POINTS
1. Who I am — architect, a dozen years
2. Tonight starts with four bugs
3. Everyone makes them; I have made them
4. Better tools keep arriving — follow that thread back
5. The promise: type-checking IS constructing a proof, and you already do it
6. Thanks to the organisers

VERBATIM

"Good evening. My name is Michael Bauer, and I've spent the last dozen or so years working
as a software and solution architect. Tonight I would like to start with four bugs.
Programmers have made these kinds of mistakes for as long as there has been software, and
I've certainly been one of them. We have also been given steadily better tools to prevent such bugs
- and following that thread leads somewhere a great deal older than any of us. By the end
I think you'll see that writing a program that type-checks is, in a precise sense, the same
thing as constructing a proof in formal logic, and that you've been doing it all along.
Thanks to the organisers for having me."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

The framing deliberately promises the size of the real talk. An earlier draft
opened on a-specific-kind-of-bug, which sets up something much smaller than what
follows; the audience feels that mismatch by minute ten. The bugs are the way in,
not the subject.

This slide is now load-bearing. It carries the thesis of the whole talk, and
slide 3 no longer restates it — everything after this is demonstration rather
than repetition. If the promise does not land here, there is no second attempt
before slide 8.

»In a precise sense« is not a hedge. It points at where the rigour lives: the
Curry-Howard correspondence is an isomorphism, not an analogy. The caveat it
promises is discharged on `A1-curry-howard` — see the note there about total pure calculi
versus Java's null, exceptions and non-termination.

Do not say production-incidents. Alice's was caught in staging, and whether any
of the four escaped to production is a matter of process and luck rather than
anything about the bug. Claiming production overstates three of them and is simply
wrong about one.

Budget note: 1:00 at the 130 wpm planning rate, 0:41 at MB's measured read rate.
The cap was raised rather than the text cut — an opening that carries the thesis
is worth the seconds, and the overage is taken from Act 4, which measured 10:36
in v1 against a 6:30 target.
