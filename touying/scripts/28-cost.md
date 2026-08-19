A6-cost · cap 1:20 · Act 6 beat 1 of 4

TALKING POINTS
1. What each of these costs to encode, where you actually are
2. Stage 3 — nothing. Java 17, no dependency, an afternoon. Worth it regardless
3. Stage 4 — one interface, a private constructor, a code-review conversation,
   generic noise. Earns it where there is a lifecycle. Not everywhere
4. Stage 5 — becomes a team decision. Build tooling, compile times, hiring,
   a real learning curve
4b. But the FIRST step is an afternoon on something small, not a team decision
5. Stage 6 — not a production proposal. It shows where the ceiling is, the ideas
   leak downwards, and an evening with it changes how you read a signature
6. None of the type-level machinery survives to runtime — what is left is one
   check at the boundary you would have written anyway
7. Is this invariant expensive enough to encode? That set keeps growing
8. — and there is a second reason it is growing. Hand over; do not start it here

VERBATIM

"So: what does each of these cost, where you actually are. The prices are on the
wall; what matters is their shape.

The first two are cheap enough that nobody has to approve them. Stage five is a
team decision eventually — build tooling, compile times in seconds rather than
milliseconds, hiring, a real learning curve — but the first step is not that
decision. It is one person spending an afternoon on something small, to find out
whether you have invariants worth the expressivity. And stage six is not a
production proposal at all: it shows where the ceiling is, the ideas keep leaking
down into languages you do ship, and an evening with it changes how you read a
type signature.

None of it costs anything at runtime. The type-level machinery is gone before the
program starts, and what is left is the one check at the boundary you would have
written by hand anyway.

So the question is never which language to move to. It is whether a particular
invariant is expensive enough to encode — and the tools keep making that
cheaper, which is why the set worth encoding keeps growing."

==========================================================================
PREPARATION — background, checks and citations. Not for the night.
==========================================================================

THIS SLIDE IS THE ONE `A3-ceiling` SET UP
`19-ceiling.md` records the framing decision: *whether a language that gives it
to you directly is worth the move* was the wrong question, because nobody changes
language for better types and asking it invites the room to write the talk off as
impractical. The question they actually face is **which of these you are already
paying for, and what each one costs to encode where you are** — and that is this
slide. The opening line is deliberately the same sentence, twenty minutes later.

THE PLAN'S LANDING LINE IS REPHRASED, AND THIS IS THE CHANGE TO REVIEW
Part 3 has: *The question was never »should I use dependent types for my CRUD
endpoints.« It's: is this invariant expensive enough to encode?* That is R1 —
define positively, never by exclusion — and the same shape appears twice in v1
(`33-horizon`: *the right question is not »is this fancy?«*). Naming the silly
reading plants it. The positive half loses nothing and is on the slide as well as
in the script. Flagged rather than done quietly (C11).

GRADUAL TYPING MOVED TO `A6-monday`, AND HERE IS WHY
Part 3 puts gradual typing on this slide, on the grounds that *how do I start
without a rewrite* is the question it exists to answer. That question is answered
better one slide later: `A6-monday` **is** the incremental ladder, so the gradual
-typing point is its frame rather than an aside here. It arrives as one sentence
in the room's own terms — a raw type talking to a generic one, `@Nullable` added
a file at a time — which is where it does work instead of taking twenty seconds
from the cost argument. Deviation from the plan, deliberate, and reversible.

THE ERASURE CLAIM, STATED CAREFULLY (C2)
The honest version is *the type-level machinery* is erased, not *everything*.
- Phantom type parameters: erased by Java's generics erasure. `Payment<Initiated>`
  and `Payment<Authorized>` are the same bytes — the fact `A3-stage4` already
  used.
- Iron refinements: `String :| MinLength[1]` is `IronType[String, MinLength[1]]`,
  an opaque type over `String`, so the *type* is gone at runtime. The predicate on
  a runtime value is still checked once, by `refineEither` in the smart
  constructor — which is exactly the check you would have hand-written, done once
  at the boundary instead of defensively downstream. Saying *free* about the
  predicate would be false; saying it about the type is true.
- Opaque types, path-dependent message types, match types: compile-time only.
- Idris 2 multiplicities: erased; the channel is an ordinary reference at runtime.
Sealed interfaces and records are ordinary runtime objects and are not part of
this claim — they are code you would write anyway.

WHAT THE AGENTIC HALF DOES AND DOES NOT CLAIM
It claims two things, both checkable: the floor holds regardless of author, and
the error names the type it wanted. It does **not** claim a type error is
categorically better than a test failure — a good test failure is informative
too. *More to go on than a red assertion* is the comparative that survives.

`Approval[LowRisk]` / `Approval[MediumRisk]` is the error the room watched come
out of `scalac` at Demo 3, so it is a memory rather than an example.

FOR Q&A — the proof-assistant tail, which v1 had in the script
Lean, Rocq, Agda and Idris go further than anything shown tonight: the proof
obligation becomes part of the type, and to call a function you supply an explicit
proof that its precondition holds. The machine checks that proof term, and modern
tactic libraries automate a growing fraction of writing it. Everything in this
talk is the other thing — the checker discharges the obligation itself and you
only declare the type. Good answer; no airtime.

Also for Q&A: regulated domains — avionics, medical devices, parts of finance —
crossed this threshold long ago, because a field incident costs more than the
encoding. v1 had it in the close. It is a supporting anecdote for the cost
argument, not the argument, and it is unverifiable from the stage.

WHY THE AGENTIC HALF IS NO LONGER ON THIS SLIDE (MB, 19 Aug)
MB: *I'm not quite sure that the immense value of types as hard constraints,
dense and clear signals of intent and fast feedback loops for iteration for AI
agents is made clear enough towards the end of the talk, where it should land
again forcefully.* It was sixty words at the end of a cost list, delivered while
the room read a four-row table. It is now `A6-now`, its own beat, with the three
claims separated. Part 3 merged v1's `32-agentic` into this slide; that merge is
partly undone, deliberately, and the reason is above.

JOIN
Backwards: `A5-payoff`, the dark *Unrepresentable* slide, which is the emotional
peak — let it land before starting this. Forwards: `A6-now`, the second reason
the set keeps growing.
