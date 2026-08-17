// Clock: 2:45–3:45 · cap 1:00 · VERBATIM SCRIPT
//
// v2: "the turn". The single most important minute in the talk — it converts
// four war stories into the thesis. Delivered verbatim, over-rehearsed.
#import "../theme.typ": *
#import "../components.typ": *

// No headline: this slide's job is one statement, and a meta-title like
// "The Turn" would spend its most valuable line telling the audience nothing.
#slide-page[
  #slide-pad[
    #v(1fr)
    #align(center)[
      #set text(size: sz(52pt), weight: 300, fill: pal.fg)
      #set par(leading: 0.8em, justify: false)
      None of these is a testing failure.\
      In each one, the language let someone write down\
      something the business had already declared #text(fill: pal.bad)[illegal].
    ]
    #v(sz(96pt))
    #align(center)[
      #set text(size: sz(36pt), weight: 300, fill: pal.fg-dim)
      #set par(leading: 0.7em, justify: false)
      What we are doing when we specify programs and types\
      has a history of about #text(fill: pal.fg, weight: 500)[two and a half thousand years.]
    ]
    #v(sz(28pt))
    #align(center)[
      #set text(font: mono-font, size: sz(28pt), fill: pal.fg-faint)
      philosophy #h(sz(20pt)) → #h(sz(20pt)) logic #h(sz(20pt)) → #h(sz(20pt)) mathematics
      #h(sz(20pt)) → #h(sz(20pt)) #text(fill: pal.accent)[your compiler]
    ]
    #v(1fr)
  ]
]

#speaker-note[
VERBATIM · budget 1:20 · 168 words. This minute turns four war stories into the
thesis, and it is the second place you are most likely to stumble. Over-rehearse it.

"None of those four was a testing failure. In every case the language accepted a
program that the business had already ruled out, and more test coverage would not
have changed that.

What would change it is being able to say, in the language itself, which programs
are allowed at all. That question is much older than programming.

The history of what we are doing when we specify programs and types stretches back
about two and a half thousand years, across philosophy, logic, mathematics, and
computer science. That is the thread I want to follow tonight, because a good part
of what everyone in this room does already sits at the end of it.

When you write a sealed interface and the compiler makes you handle every case, you
are applying a rule that Gerhard Gentzen wrote down in 1935. When you write a
generic method, you are making a claim about every possible type. That is a
universally quantified statement.

I want to give you the vocabulary for that, and some sense of how far it goes. Once
you can see the structure, you can encode much more of what your system actually
requires. The compiler will check it for you — and for the agents now writing code
next to you."

NOTES ON THE WORDING
- Sentence two is yours, lightly restructured so the verb arrives sooner: the
  original subject ran fourteen words before the verb. Your version reads fine
  on paper and is harder to say. Revert if you prefer it.
- 2,500 vs 2,400: Aristotle's Prior Analytics is roughly 350 BCE, so the literal
  figure is about 2,376 years. About-two-and-a-half-thousand is a fair round
  number; two-thousand-five-hundred states more precision than the date supports.
- Gentzen 1935 is the Untersuchungen über das logische Schließen, which introduces
  natural deduction and the introduction/elimination rules. Slide 13 shows them.
- The claim is deliberately sits-at-the-end-of-it rather than is-proof-theory.
  A sealed interface instantiates a structure proof theory studies; saying it IS
  proof theory overclaims and loses anyone who knows the difference.
- The agents clause is one clause on purpose. Slide 29 carries that argument.
]
