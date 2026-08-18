A3-stage4 · cap 1:45 · Act 3 beat 6 of 8

TALKING POINTS
1. Bridge from Bob in two sentences: his was a missing CASE
2. Charlie's is a wrong ORDER, and no sum type catches that
3. Charlie's shortcut: fetch the refund by id, execute it. Nothing asks the state
4. The fix: put the state in the type as a parameter that carries no data
5. Every transition demands its input state and returns the next one
6. Payment<Initiated> and Payment<Authorized> are the same bytes
7. What the parameter carries is which methods will accept the value
8. There is no way to reach Captured without going through Authorized

VERBATIM

"Bob's bug was a missing case, and a sum type closed it. Charlie's is a different
shape: everything he called existed, and he called it in the wrong order. No sum
type in the world catches that.

Here is his shortcut. Fetch the refund by its id, hand it to the gateway. Nothing
in those two lines asks what state the refund was in, and nothing had to.

So we put the state into the type. Payment takes a type parameter — Initiated,
Authorized, Captured — and that parameter carries no data whatsoever. At runtime
these are the same bytes. What it carries is which methods will accept the value:
capture demands a Payment of Authorized and gives you back a Payment of Captured,
so there is no path to Captured that does not go through Authorized first.

The lifecycle stopped being a diagram on a wiki. It is the set of signatures."

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
