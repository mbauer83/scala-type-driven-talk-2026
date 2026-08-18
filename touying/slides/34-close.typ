// A6-close · cap 0:50 · Act 6 beat 3 of 3 · REWORK of v1 34-close
//
// Closes the loop opened by A0-title and does nothing else. The promise, in MB's
// words: "writing a program that type-checks is, in a precise sense, the same
// thing as constructing a proof in formal logic — and you've been doing it all
// along." The first spoken sentence returns that sentence.
//
// It must NOT re-tell the four incidents. A5-payoff — the dark Unrepresentable
// slide — is three slides earlier and is the emotional peak; Part 3 cut
// 31-the-climb so the last four minutes carry two summaries, not three. v1's
// script opened with a sentence per incident, which was the third telling.
//
// v1's slide copy said "Some bugs aren't 'just part of engineering life' —
// they're artifacts of a language level that can't express the invariants we
// care about." That is R1, define-by-exclusion, made worse by scare quotes. The
// replacement says the same thing forwards.
//
// The zero-runtime-overhead footnote that ended v1 is now on A6-cost, where it
// is a cost fact. A talk should not end on a note about erasure.
#import "../theme.typ": *
#import "../components.typ": *

// The QR from the title slide, repeated: the moment people actually decide to
// take the link is the moment the talk ends. Same caption, so it reads as the
// same thing rather than a second, different link.
#close-slide(
  qr: qr-plate(
               [slides, and the code \
                for all six stages],
               fg: pal.fg-dim),
  [
  Every stage tonight made the same move: a rule that was only #text(fill: pal.fg-dim)[promised]
  — in a comment, in a test, in somebody's head — became a rule the type
  #text(fill: pal.accent)[states].

  #v(sz(28pt))

  A program that type-checks is a proof, and you have been writing them all along.

  #v(sz(28pt))
  #text(weight: 500)[Thank you.]

  #v(sz(26pt))
  #text(size: sz(24pt), font: mono-font, fill: pal.fg-faint)[github.com/mbauer83/type-driven-programming-talk-2026]
  ],
)

#speaker-note[
#read("../scripts/31-close.md")
]
