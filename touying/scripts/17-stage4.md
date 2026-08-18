A3-stage4 · cap 1:45 · Act 3 beat 6 of 8

TALKING POINTS
1. Bob's was a missing case. Charlie's is different, and harder
2. He loaded a refund out of the database and executed it
3. Nothing in those two lines asked whether it had been approved
4. And no type can know that — the row came from outside the program
5. So the type does the other thing: it makes the gateway unreachable
6. execute demands Refund<Approved>. The repository cannot produce one
7. The only way across is asApproved, which does the check, once
8. From then on the value carries its provenance — where it has been — in its type
8b. The boundary check is real and runs. Inside your own code there is none to run
9. Initiated and Authorized are the same bytes; the parameter only decides
   which methods accept it
10. This pattern has a name — phantom typestate

VERBATIM

"Bob's bug was a missing case, and a sum type closed it. Charlie's is a different
shape, and a harder one. He loaded a refund out of the database by its id and
handed it to the payment gateway. Nothing in those two lines asked whether it had
been approved, and nothing had to.

Now, no type system on earth knows what is in your database, because that row came
from outside the program — so the type does not try to check it, and does
something better instead: the gateway demands a refund that is approved, and the
repository cannot give you one. The only way across is a function that performs
the check and hands you back the evidence.

From then on the value carries its provenance — where it has been — in its own
type, and the compiler is what makes sure nobody skips the step that put it
there.

That one check at the boundary is a real one, running at runtime, because the row
came from outside the program. Inside your own code there is no check to run at
all: a payment of Initiated and a payment of Authorized are the same bytes, and
the parameter carries no data — only which methods will accept the value. Which
is why the pattern is called phantom typestate. Phantom because there is nothing
there."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

WHY THE HAPPY PATH IS GONE
v1 showed the three-line success sequence — initiate, authorize, capture — plus
the signature family. The happy path is the one thing on this slide that cannot
go wrong, so it demonstrates the mechanism and hides the argument. Charlie's
incident is the argument.

THE BRIDGE FROM BOB IS TWO SENTENCES, NOT A SLIDE
Part 4 deleted `21-bridge`, which spent 1:30 on a transition. The two sentences
that replace it open this script, and the distinction they draw is the one that
matters: **a missing case is a sum-type problem; a wrong order is not.** If that
lands, Stage 4 needs no other motivation.

THE PHANTOM PARAMETER — name it here, and only here
This is the beat that teaches the term, so it is where the word belongs
(Part 12/R8, introduce before use). `A2-values` used to say *phantom parameters*
two acts early and it was cut for exactly that. Say what it does first — a type
parameter that carries no data — and the name second, if at all.

Same-bytes is also the fact `a2-values` used to carry before that slide was cut;
it lives here now, where the code is on screen to back it up.

FACTS — grepped (C1)
- `public final class Payment<S extends PaymentState>` —
  `04-java-advanced-generics-typestate/Payment.java:20`. This is also the repo's
  only real bounded generic, which is why `A1-quantifiers` deliberately did not
  spend it.
- The signature family is verbatim in shape from `Payment.java`: `initiate`,
  `authorizeAuto`, `authorize3DS`, `capture`, `refund`. Only three are shown.
- Charlie's two lines are narrative, from `A0-incidents` — a card, not a pane
  (Part 12/R9).

JOIN
Forwards: Demo 2 uncomments `Payment.capture(init)` and lets javac say the same
thing in its own words. Do not describe the error here.
