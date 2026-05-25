// Clock: 5:30–7:00
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  eyebrow: eyebrow([LOGIC & PROOF · 4TH C. BCE → TODAY], style: "accent"),
  [A Toolkit Built Over Two and a Half Thousand Years],
  beat-grid((
    ([4th c. BCE], [Aristotle], [Valid inference from structural form alone. Replace content with variables; the form holds or it doesn't.]),
    ([17th c.], [Leibniz], [If valid inference is purely structural, in principle it could be performed by a machine. Sketches a universal formal notation and a "calculus of reasoning" — mechanised inference, two centuries early.]),
    ([1847], [Boole / DeMorgan], [Logic as algebra: AND, OR, NOT with strict laws. Relations composed as first-class objects.]),
    ([1879–1910], [Frege · Peano · Russell + Whitehead], [Principia Mathematica: an attempt to ground all of mathematics in a single formal system. Syntax (token manipulation) clearly separated from semantics (meaning).]),
  )),
  footer: ["Formal structure restricts what can be said — so that what #emph[can] be said can be trusted."],
)

#speaker-note[
"The thread we'll follow is one specific question: what does it take to make valid inference explicit — the question of whether a conclusion really does follow from its premises? Aristotle gave the first clean answer: validity comes from the structural form of an argument, not its content. Replace the words with variables; the form holds or it doesn't. Leibniz, two thousand years later, pushed this further — if valid inference is purely structural, then in principle it could be reduced to calculation, performed by a machine. He sketched both the notation and the calculus he thought would do it. The programme failed in his lifetime, but the idea is the line we're still walking. Boole and DeMorgan turned propositional logic into algebra. And at the turn of the 20th century, Frege, Peano, Russell and Whitehead tried to put all of mathematics inside a single formal system. At every step, the move is the same: tighten what counts as a valid step, so more kinds of invalid judgements can be identified and excluded."
]
