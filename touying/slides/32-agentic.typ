// A6-cost · cap 1:45 · Act 6 beat 1 of 3 · NEW + MERGE of v1 32-agentic
//
// The slide `A3-ceiling` set up: its PREPARATION records that "is a language
// with better types worth moving to" is the wrong question, and that the one
// the room actually faces is what each of these costs to encode where they are.
//
// The price and the reason the price is worth paying now are one conversation,
// which is why Part 3 merges the agentic argument in here rather than giving it
// a slide. v1's 32-agentic was that slide, and most of its speaker note was a
// proof-assistant digression that is now Q&A material in the script.
//
// GRADUAL TYPING IS NOT HERE. Part 3 puts it on this slide; it does its work on
// A6-monday, which IS the incremental ladder. Flagged in the script, reversible.
//
// The landing line is rephrased from Part 3's: "the question was never 'should
// I use dependent types for my CRUD endpoints'" is R1, define-by-exclusion, and
// v1 had the same shape on 33-horizon. The positive half loses nothing.
//
// The erasure claim is about the TYPE-LEVEL MACHINERY only — sealed interfaces
// and records are ordinary runtime objects, and Iron still runs one predicate
// check on a runtime value. C2 discipline is in the script's PREPARATION.
#import "../theme.typ": *
#import "../components.typ": *

// Stacked, not two columns: at 25pt the stage labels wrap, and a wrapped label
// beside a top-aligned price column throws every row out of register.
#let cost(stage, price, verdict) = stack(
  dir: ttb,
  spacing: sz(5pt),
  text(size: sz(25pt), weight: 600, fill: pal.fg)[#stage],
  block[
    #set text(size: sz(23pt), fill: pal.fg-dim)
    #set par(leading: 0.42em)
    #price #text(fill: pal.fg)[#verdict]
  ],
)

#light-slide(
  eyebrow: eyebrow([What it costs · and why the calculation is moving]),
  body-gap: sz(24pt),
  [What each stage costs to encode],
  stack(
    dir: ttb,
    spacing: sz(24pt),
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(56pt),
      align: (left + top, left + top),

      stack(
        dir: ttb,
        spacing: sz(20pt),
        cost([Stage 3 · sealed ⊕ records],
             [Java 17, no dependency, an afternoon. ],
             [Do it regardless.]),
        cost([Stage 4 · phantom typestate],
             [An interface, a private constructor, a conversation in code
              review, and some generic noise in your signatures. ],
             [Where there is a lifecycle.]),
        cost([Stage 5 · Scala 3],
             [Build tooling, compile times in seconds rather than milliseconds,
              hiring, a real learning curve. ],
             [A team decision, when the invariants are expensive enough.]),
        cost([Stage 6 · Idris 2],
             [Not a production proposal. ],
             [It shows where the ceiling is — and the ideas leak downwards.]),
      ),

      stack(
        dir: ttb,
        spacing: sz(24pt),
        callout(
          [Free],
          [None of the type-level machinery survives to runtime. What is left is
           the one check at the boundary you would have written by hand anyway.],
          style: "accent",
        ),
        [
          #set text(size: sz(24pt), fill: pal.fg)
          #set par(leading: 0.45em)
          #text(weight: 600)[Code now arrives faster than anybody can read it.]
          #text(fill: pal.fg-dim)[ A type system that carries your invariants
          holds the same floor whoever wrote the line — and the error names the
          type it wanted, which is something to act on.]
        ],
        block(width: 100%, fill: pal.bg-warm, radius: sz(6pt),
              inset: (x: sz(20pt), y: sz(14pt)))[
          #set text(size: sz(20pt), font: mono-font, fill: pal.fg-dim)
          Found:    Approval[LowRisk] \
          Required: Approval[MediumRisk]
        ],
      ),
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    align(center)[
      #set text(size: sz(28pt), fill: pal.fg)
      The question is whether this invariant is expensive enough to encode.
      #text(fill: pal.fg-dim)[ The tools keep getting cheaper, so that set keeps
      getting bigger.]
    ],
  ),
)

#speaker-note[
#read("../scripts/28-cost.md")
]
