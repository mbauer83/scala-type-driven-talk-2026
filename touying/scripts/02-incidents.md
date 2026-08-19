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

WHAT CHARLIE'S SHORTCUT IS FOR (MB, 19 Aug)
Fair question, and the old wording had no answer: *»an operator shortcut … which
executes it without reading its state«* leaves the room asking what the shortcut
is for, and if it is supposed to check the state, in what sense it is a shortcut.

The scenario that makes it a real bug rather than a careless one: **it skips the
queue, not the review.** An approved refund goes out with the next batch; urgent
cases — a customer on the phone, a chargeback deadline — need one pushed now, so
ops gets an action that takes a refund and sends it immediately. The state check
was never inside that action, because in the admin screen the button only appears
on refunds that are already approved. The invariant lived in the path that
normally reaches the operation. Then somebody drives the same operation from a
runbook, with ids out of a spreadsheet, and one of them was still in review.

Every operations team recognises that shape: a rule enforced by the caller, and
then a second caller. It is also exactly what Stage 4 fixes — the parameter type
becomes `Refund<Approved>` instead of `Refund`, so the check happens once, at
approval, and it reaches every call site including the one nobody thought about.

**MB's to rewrite in his own register** — the mechanism is what has to survive,
not this phrasing.

NO DURATION ON ALICE'S BUG (MB, 19 Aug)
It said *»survived for months«* on the slide and in the spoken line. MB: a bit
ridiculous — it asks the room to believe that nobody wrote a two-line fixture for
months, and the first person who doubts that stops listening to the other three.
The claim that does the work is the mechanism, not the calendar: almost every
fixture used a single-line order, so summing was never actually tested. The slide
card reads *passed every test it had*, which is true, is the point, and puts no
number on it.

Checked facts and the traps, in case you want to rework any of it:

ALICE — the boundary between untyped input and typed code.
  fact: a CSV export carries order-line amounts in cents; the Node job reads them
        as JS strings and never coerces them.
  fact: `+` on two strings concatenates and throws nothing, so the job exits clean.
  fact: THE REASON IT SURVIVES — `[x].reduce((a,b) => a+b)` returns `x` unchanged,
        so any single-line order looks correct. The bug needs two or more lines,
        which is exactly what the fixtures did not have. This is the load-bearing
        detail; without it the story reads as implausible.
  fact: found in test, not in production. Do not upgrade it to an issued invoice.
  beat: the type system had no way to distinguish a string that looks like a number
        from a number.
  closes: Stage 1. `int` instead of `String` is enough — the cheapest rung on the
        whole ladder, which is the point.

BOB — a branch that was correct when it was written.
  fact: risk tiers were Low and High; the code read `if (risk != HIGH) fastPath()`.
  fact: a Medium tier was added later, and satisfied `!= HIGH`, so it took fastPath.
  fact: Medium-risk card orders are the ones that require 3-D Secure.
  fact: CORRECTION on the v1 note — completing 3DS shifts chargeback liability TO
        THE ISSUER. Skipping it means no shift happens and the MERCHANT keeps the
        liability. The v1 note had this backwards.
  beat: nothing in the language required anyone to revisit that branch.
  closes: Stage 3, sealed types + exhaustive switch.

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
  (Was KYC onboarding in v1. Moved inside the payment frame: KYC is jargon not
   everyone in the room shares, it was the only story outside the domain spine, and
   the Scala session-type code models the payment protocol anyway — so v1 had the
   story and the code that closes it describing different systems.)
  (Do NOT rank this one as the-hardest-to-see. Unverifiable, and it reads as filler.)

CLOSING BEAT: all four passed their compiler. That is the hinge into the next slide.
