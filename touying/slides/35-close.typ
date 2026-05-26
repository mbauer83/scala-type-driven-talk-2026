// Clock: 43:30–45:00
#import "../theme.typ": *
#import "../components.typ": *

#close-slide([
  Some production incidents aren't "just part of engineering life" — they're artifacts of a language level that can't express the invariants we care about.

  With the right type-level encoding, specific bug classes #text(fill: pal.accent)[stop being expressible in our code] — and the runtime incidents disappear with them.

  #v(sz(20pt))
  #text(weight: 500)[Thank you.]
])

#speaker-note[
"Alice tracked down an invoice that came out wrong because the type system couldn't tell a string from a number at a boundary. Bob's checkout silently took the wrong path because the type system didn't require every branch to be handled when a third was added. Charlie traced an out-of-order state transition through logs because the lifecycle existed in comments, not in the type. Danielle hit a protocol drift because two services had no shared type-level definition of their contract.

These came from a mismatch between what the business required and what the design level could enforce.

We showed today that the gap can be closed — incrementally, with existing tools, without discarding what works. Modern Java goes a fair distance on its own; Scala 3 goes considerably further; Idris 2 shows the horizon.

In aviation, medical devices, and regulated finance, the regulatory threshold has already made the cost-benefit calculation: the cost of encoding the invariant is lower than the cost of a field incident. In commercial software, that threshold is moving too — partly because the tooling is maturing, and partly because generation speed is outpacing the review capacity that used to catch these things.

The question isn't 'should I use dependent types for my CRUD endpoints'. The question is: is this invariant expensive enough to encode? The tools are getting cheaper. The set of invariants worth encoding gets bigger every year.

Thank you."
]
