VERBATIM · cap 2:00 · word count is computed by `make timing`, not stated here. Checked facts follow the script.

TALKING POINTS
1. The flow: order → assess risk → authorize → capture (→ refund)
2. Alice — CSV strings summed with +; single-line fixtures hid it
3. Bob — third risk tier; if (risk != HIGH) was right for two
4. Charlie — an operator action that skips the QUEUE, and skipped the review
   too, because only the screen checked the state
5. Danielle — payment side adds a step, checkout never updated
6. All four compiled without complaint

VERBATIM

"Everything tonight will be framed in terms of one scenario, and it is one every 
person here has used, even if you haven't built it: order processing with payment. 
An order is placed, its risk is assessed, the payment is authorized, and later captured 
or refunded. All four of these bugs sit somewhere in that domain.

Alice's team owns the job that reconciles the day's order lines, and the amounts
arrive from a CSV export - as strings, with nothing converting them. JavaScript's
plus, given two strings, concatenates. It survived because almost every fixture used a
single-line order - and so summing wasn't actually tested. The
first two-line order in the test data produced a daily total with twelve digits instead of two.

Bob's team added a medium risk tier to their fraud engine. The branch that handled
risk had been written when there were only two tiers, and it said: if risk is not
high, take the fast path. Well - medium isn't high... so off to the fast path we go.
... skipping 3-D Secure, which means the liability for those chargebacks stays with
the merchant instead of moving to the issuer.

Charlie owns the refund approval workflow. A refund goes from requested through
review to approved, and only then out to the payment rail with the next batch.
Urgent cases get an operator action that sends one immediately, to skip that
queue. Only the screen offering the button checked the state — driven from a
runbook, it paid out a refund nobody had reviewed. Charlie spent about three
hours in the logs working out how.

Danielle owns the integration between checkout and the payment service. The payment
side added a challenge step for orders above a value threshold, and the checkout
client was never updated to read the extra message. Each side was correct against
its own contract. The tests covered the common path, and the new branch only fires
above the threshold, so it ran for three weeks before anyone hit it.

Every one of those compiled without complaint."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

CHARLIE — a lifecycle that lived in documentation.
  fact: refunds go Requested → UnderReview → Approved → Executed.
  fact: an operator-tooling shortcut fetches by id and executes, without reading state.
  fact: a Requested refund reached the payment rail and posted back to a card.
  fact: ~3 hours of log reading to reconstruct what happened.
  beat: the state machine existed in the wiki and in three developers' heads.
  closes: Stage 4, phantom typestate.

DANIELLE — two correct programs that disagree.
  fact: the integration between checkout and the payment service, in Scala.
  fact: the payment side added a challenge step above a value threshold; the
        checkout client was never updated to read the extra message.
  fact: each side satisfies its own contract; neither is individually wrong.
  fact: tests covered the common path, the branch only fires above the threshold,
        so it ran ~3 weeks before anyone hit it.
  beat: no shared, checkable definition of the conversation existed.
  closes: Stage 5, session types and duality.
  (Moved inside the payment frame: KYC is jargon not
   everyone in the room shares, it was the only story outside the domain spine, and
   the Scala session-type code models the payment protocol anyway — so an earlier cut had the
   story and the code that closes it describing different systems.)
  (Do NOT rank this one as the-hardest-to-see. Unverifiable, and it reads as filler.)

CLOSING BEAT: all four passed their compiler. That is the hinge into the next slide.
