// Clock: ~33:30–34:00 (inserted after session-types demo, before stage5-payoff)
// §2.5: Stage 5 mechanisms reference slide — the six mechanisms the audience
// just saw in the demo, now named and anchored as vocabulary.
#import "../theme.typ": *
#import "../components.typ": *

#let mech-row(name, detail, sub) = grid(
  columns: (sz(280pt), sz(280pt), 1fr),
  gutter: sz(16pt),
  align: (left + top, left + top, left + top),
  text(size: sz(26pt), weight: 600, fill: pal.accent)[#name],
  text(size: sz(24pt), fill: pal.fg-dim, font: mono-font)[#detail],
  text(size: sz(24pt), fill: pal.fg-dim)[#sub],
)

#light-slide(
  eyebrow: eyebrow([Stage 5 · Mechanisms], style: "accent"),
  body-gap: sz(28pt),
  [Six Type-Level Tools at Work],
  stack(
    dir: ttb,
    spacing: sz(22pt),
    mech-row(
      [Refined types],
      `NonEmptyString = String :| MinLength[1]`,
      [Predicate carried in the type — smart constructor at runtime, macro proof at compile time.],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    mech-row(
      [Opaque + refined IDs],
      `OrderId, CustomerId`,
      [Distinct types at compile time; plain strings at runtime. Zero overhead.],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    mech-row(
      [Path-dependent types],
      `CanSend[P]#Msg`,
      [Message type derived from the protocol position. Wrong type or wrong step → compile error.],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    mech-row(
      [Compiler-derived evidence],
      `P =:= End`,
      [`finish()` requires proof that the protocol has reached `End`. The compiler supplies it.],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    mech-row(
      [Match types + duality],
      `Dual[P] computed by compiler`,
      [Server and client protocol types derived from one definition. Cannot drift.],
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    mech-row(
      [Higher-kinded types],
      `interpret[F[_]: Functor, A]`,
      [Protocol interpreter parameterised over the effect type.],
    ),
  ),
)

#speaker-note[
"Those six mechanisms just ran in the demo. Let me name them so the vocabulary is clear. Refined types carry a predicate in the type itself — not a runtime check you might forget, but a constraint the compiler enforces. Opaque types give you distinct compile-time identities that are erased to plain strings at runtime — zero overhead. Path-dependent types give you a message type that depends on the protocol position — the wrong message type at the wrong position is a compile error, not a test. Compiler-derived evidence: `finish()` requires a proof value of type `P =:= End`; when the protocol has consumed all steps, the compiler can summon that proof automatically; if it can't, the program doesn't compile. Match types + duality: the server and client protocol types are derived from one protocol definition by structural induction; they cannot drift because they share one source. Higher-kinded types: the protocol interpreter is parameterised over the effect type, so you can run it in `IO`, in `Future`, or in a test `Id` monad."
]
