// APPENDIX · what the talk leaves out.
//
// MB, 19 Aug: an appendix slide for important points not covered, so a question
// from the room lands on a prepared answer instead of an improvised one. Six
// entries, each a topic he can talk to for a minute; the gloss on the slide is
// the hook, and the argument is in the speaker note.
//
// Path-dependent types are here for a second reason. They DO appear in the main
// deck — `A4-mechanisms` names them next to `def send(using s: CanSend[P])
// (value: s.Msg)` — but that row explains the evidence pattern, not the
// path-dependent part. This slide carries the part the main deck has no time
// for, and A4-mechanisms now says the one thing that makes the name earn itself.
//
// Every factual claim was checked on 19 Aug; citations are in the note.
#import "../theme.typ": *
#import "../components.typ": *

#let topic(name, gloss) = stack(
  dir: ttb,
  spacing: sz(10pt),
  text(size: sz(26pt), weight: 600, fill: pal.fg)[#name],
  block[
    #set text(size: sz(22pt), fill: pal.fg-dim)
    #set par(leading: 0.42em)
    #gloss
  ],
)

#light-slide(
  eyebrow: eyebrow([Appendix · not covered], style: "accent"),
  body-gap: sz(28pt),
  [What this talk leaves out],
  stack(
    dir: ttb,
    spacing: sz(46pt),
    [
      #set text(size: sz(24pt), fill: pal.fg-dim)
      Six parts of the subject that forty-five minutes had no room for. Ask about
      any of them.
    ],
    grid(
      columns: (1fr, 1fr),
      column-gutter: sz(52pt),
      row-gutter: sz(46pt),

      topic([Bounds vs. type classes],
            [`<T extends Comparable<T>>` constrains through the hierarchy, so the
             type must have been declared to fit. `[T: Ordering]` constrains
             through evidence supplied from outside, long after the type was
             written. Scala carries both, and their interaction is where its
             hardest inference lives.]),

      topic([What the type says about the reference],
            [TypeScript says nothing. Java and Scala split boxed from unboxed —
             `int` from `Integer`, `AnyVal` from `AnyRef` — and still say nothing
             about who else holds the value. Rust puts that in the type: `T`,
             `&T`, `&mut T`. Idris 2 has no such axis; its multiplicities count
             uses, not aliases.]),

      topic([Erasure, branding, reflection],
            [`AuthCode` is a `String` at runtime and the JVM cannot tell them
             apart, so reflection and deserialization walk straight past the
             guarantee. Dependent languages erase too — an Idris index at
             multiplicity `0` is gone by runtime. Compile-time precision is not a
             runtime tag.]),

      topic([Path-dependent types],
            [`s.Msg` is a type reached through the term `s`, so two different
             instances have two different `Msg` types and the compiler will not
             confuse them. It is as close as Scala gets to a type that depends on
             a value, and it is how `send` knows what it accepts.]),

      topic([Gradual typing, and inference as a language],
            [`any` is unsoundness by design, and at the boundary somebody pays —
             in Typed Racket, in contracts at runtime. Meanwhile `infer` and
             `extends` make TypeScript's type level Turing-complete, which is why
             it answers deep instantiations with a depth limit rather than a
             type.]),

      topic([Multiparty sessions, and failure],
            [Two roles is the easy case. The general theory projects one global
             protocol onto a local type per role. Failure came later and is the
             harder half — exceptions in 2019, crash-stop failures after that,
             and toolchains that generate Scala from a protocol description.]),
    ),
  ),
)

#speaker-note[
Q&A only. Nothing here is spoken in the talk. Checked 19 Aug 2026.

BOUNDS VS. TYPE CLASSES
The real distinction is where the constraint is attached. A subtype bound is
declaration-site: `String` implements `Comparable<String>` because its author
said so, and you cannot add it afterwards. A type class or `given` is use-site
evidence: `Ordering[LegacyId]` can be supplied by someone who does not own
`LegacyId`. That is why type classes retrofit and bounds do not — and why type
classes raise coherence questions (two instances in scope) that bounds cannot.
Bounds also give the compiler a lattice — least upper bounds, variance — which
Scala's inference uses constantly, and which is one reason Scala's inference is
harder than Haskell's.

REFERENCES AND VALUES — MB's characterization, checked
Mostly right, with one distinction worth keeping separate. Two different
questions get run together:
  (a) boxed or unboxed — `int` vs `Integer`, `AnyVal` vs `AnyRef`
  (b) who else can see this, and can it change under me
Java and Scala answer (a) in the type system and say nothing about (b): every
object variable is a reference and nothing in the type distinguishes a unique
one from a shared one. TypeScript answers neither — JavaScript semantics, no
marker. Rust is the one that puts (b) in the type: ownership, `&T` shared, `&mut
T` unique, aliasing XOR mutation, enforced by the borrow checker.
Idris 2 does not have this axis at all. It is pure, so value semantics is the
default; mutable state is an explicit type — `IORef`, `STRef`, `Data.Ref` — and
QTT multiplicities (`0`, `1`, unrestricted) count how many times a binding is
used, not how many aliases exist. `Data.Linear.Array` uses that: a mutable array
is safe because linearity stops it being shared, which reaches Rust's guarantee
from the other direction.

ERASURE, BRANDING, REFLECTION
Java erases generics; there is no `List<String>` at runtime. Scala erases too,
with `ClassTag` and `TypeTag` as the reified escape hatch. So every branding
technique in the talk — opaque types, phantom parameters, `AuthCode` vs
`CaptureId` — is a compile-time discipline, and reflection, Jackson, or a cast
can put a `String` where an `AuthCode` is expected. The point worth making if
this comes up: this is not a weakness the dependent languages fix. Idris 2 erases
aggressively — that is what multiplicity `0` means — so a length index usually
does not exist in the compiled program either. What you get is a guarantee about
programs the compiler accepted, not a runtime tag on the data.

PATH-DEPENDENT TYPES — the part A4-mechanisms has no room for
`s.Msg` is a type member selected through a *term*: the type depends on which
`s` you are holding. `a.Msg` and `b.Msg` are unrelated types even when `a` and
`b` have the same class. That is the mechanism behind the cake pattern, and it
is the closest thing on the JVM to a type that depends on a value — bounded,
because the dependency is on a stable path, not on an arbitrary expression.

GRADUAL TYPING
`any` in TypeScript is documented unsoundness, chosen so that a typed island can
sit inside untyped code. The research question is who pays at the boundary:
Typed Racket inserts contracts and the cost is real and measurable. TypeScript
does not — it erases and hopes, which is why a wrong type assertion is a runtime
surprise rather than a type error.

TYPESCRIPT'S TYPE LEVEL IS TURING-COMPLETE
microsoft/TypeScript issue #14833 (March 2017) demonstrated it, and the team
declined to restrict the language over it. Conditional types with `infer`, plus
recursive type aliases, are enough. In practice the compiler bounds it —
instantiation depth and tail-recursion limits, surfacing as *type instantiation
is excessively deep and possibly infinite*. Do not say TypeScript can compute
anything at the type level: it can express it, and the compiler refuses to run
past its own budget.

MULTIPARTY SESSION TYPES, AND FAILURE
Binary session types are two roles, which is what Stage 6 shows. Multiparty
session types (Honda, Yoshida, Carbone, POPL 2008) write one global protocol and
project it to a local type per role, which is what makes the theory usable for
anything larger than a channel. Failure is the harder half and arrived later:
- Fowler, Lindley, Morris, Decova, "Exceptional Asynchronous Session Types:
  Session Types without Tiers", POPL 2019 (PACMPL 3) — the first formal
  integration of asynchronous session types with exception handling.
- Barwell, Scalas, Yoshida, Zhou, "Generalised Multiparty Session Types with
  Crash-Stop Failures", CONCUR 2022; extended as Barwell, Hou, Yoshida, Zhou,
  "Crash-Stop Failures in Asynchronous Multiparty Session Types", LMCS 2025.
- Teatrino (Barwell, Hou, Yoshida, Zhou, ECOOP 2023) extends Scribble with
  crash-stop failures and generates protocol-conforming Scala.
The honest summary if asked: the theory handles failure now; the tooling that
handles failure is research tooling. That matches `A11-production`, which says
there is no production deployment of session types to point at.
]
