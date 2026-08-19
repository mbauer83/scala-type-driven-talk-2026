// A4-ceiling · cap 1:20 · Act 4 beat 6 of 6 · MERGE of v1 27-stage5-payoff +
// scala3-ceiling
//
// Same two-part shape as A3-ceiling, deliberately: the claim that closed, then
// what the language still accepts, so the two ceiling slides rhyme and the room
// knows what an act ending looks like.
//
// BOTH SCOREBOARDS ARE GONE. v1 carried a nine-row test-list with a CLOSES
// column AND a four-chip story-strip — the furniture P5 removed everywhere else
// and Part 2 replaced with Device 1. The collective view happens once, on the
// dark Unrepresentable slide.
//
// NO COUNT OF INCIDENTS. A3-ceiling says "two of the four" at the end of Act 3
// and Alice's closed silently at Stage 1, so any tally stated here relitigates
// Act 3's bookkeeping on stage. Name what closed instead.
//
// NO CUBE REVEAL, and no third axis in words either: the deck has never named
// an axis out loud. A1-above issues only "there is a map of this territory".
// v1's script talked about the third axis twice — Part 9/L18.
//
// C2 discipline on the two limits, checked one at a time in the script's
// PREPARATION: the protocol menu is real and is stated as "written out in
// advance" rather than "impossible"; use-exactly-once is genuinely absent.
// Dropped from v1: the dual(dual(P)) involution (a proof-assistant point, Q&A)
// and "open-ended protocol vocabulary" (limit 1 said twice).
#import "../theme.typ": *
#import "../components.typ": *

#let limit(head, body) = stack(
  dir: ttb,
  spacing: sz(16pt),
  text(size: sz(27pt), weight: 600, fill: pal.fg)[#head],
  block[
    #set text(size: sz(25pt), fill: pal.fg-dim)
    #set par(leading: 0.52em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Stage 5 payoff · and the Scala 3 ceiling]),
  body-gap: sz(32pt),
  [Danielle's bug is a compile error now],
  stack(
    dir: ttb,
        spacing: sz(54pt),
    block(width: 100%, fill: pal.good-bg, inset: (x: sz(26pt), y: sz(18pt)), radius: sz(4pt))[
      #set text(size: sz(26pt), fill: pal.fg)
      Two services that were each correct against their own contract now have a
      #text(weight: 500)[third thing] to be correct against. And the demo's
      mistake went with it: the approval carries its risk level in its type, so
      the medium case cannot take an automatic one.
    ],
    line(length: 100%, stroke: 0.5pt + pal.rule),
    [
      #set text(size: sz(26pt), weight: 500, fill: pal.fg)
      Two things you can still write, and Scala will still take:
    ],
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(52pt),
      limit([Every protocol is hardcoded.],
            [`ProtocolVariant` spells all four out in the source —
             `LowRefund`, `LowNoRefund`, `MediumRefund`, `HighNoRefund` — and the
             risk assessment picks one of them at runtime. Each is checked fully. #text(fill: pal.fg)[What the compiler cannot
             do] is build the protocol out of the order in front of it — that
             needs a type that depends on a value.]),
      limit([Nothing makes you finish the channel.],
            [`finish` will not let you hang up early — mid-protocol there is no
             proof of `P =:= End` to summon. #text(fill: pal.fg)[Drop the
             channel halfway] and walk away, and nothing objects. What is
             missing is a way to write #emph[used exactly once].]),
    ),
    align(center)[
      #set text(size: sz(24pt), fill: pal.fg-dim)
      One of them wants a type computed from a value. The other wants the
      compiler to count.
    ],
  ),
)

#speaker-note[
#read("../scripts/24-ceiling.md")
]
