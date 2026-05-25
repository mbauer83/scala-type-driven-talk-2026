// Clock: Q&A — Singleton bridge
#import "../theme.typ": *
#import "../components.typ": *
#import "../code-pane.typ": code-pane

#light-slide(
  eyebrow: eyebrow([Appendix A8 · Match Types], style: "accent"),
  [The Singleton Bridge: Mimicking Dependent Types Without Paying for Them],
  stack(
    dir: ttb,
    spacing: sz(14pt),
    grid(
      columns: (1fr, 1fr),
      gutter: sz(16pt),
      callout(
        [Step 1 · ι-reduction (match types)],
        stack(
          dir: ttb,
          spacing: sz(10pt),
          [
            #set text(size: sz(22pt), fill: pal.fg-dim)
            Stay on the type-operators axis (Fω), but let type-level functions pattern-match and recurse. This IS the `Dual` from Stage 6:
          ],
          raw(lang: "scala",
            "type Dual[P <: Protocol] <: Protocol = P match\n" +
            "  case End           => End\n" +
            "  case Send[a, n]    => Receive[a, Dual[n]]\n" +
            "  case Receive[a, n] => Send[a, Dual[n]]\n" +
            "  case Choose[l, r]  => Offer[Dual[l], Dual[r]]"
          ),
          [
            #set text(size: sz(22pt), fill: pal.fg-dim)
            The type checker runs a compile-time _algorithm_ to compute a type. Still types-in, types-out — it cannot see runtime values.
          ],
        ),
        style: "accent",
      ),
      callout(
        [Step 2 · singleton types (the value→type bridge)],
        stack(
          dir: ttb,
          spacing: sz(10pt),
          [
            #set text(size: sz(22pt), fill: pal.fg-dim)
            Give a literal a razor-thin type containing only itself:
          ],
          raw(lang: "scala",
            "def openGate(code: 1234.type): OpenGate\n" +
            "def openGate(code: Int):       ClosedGate"
          ),
          [
            #set text(size: sz(22pt), fill: pal.fg-dim)
            `1234.type` is inhabited by exactly one value. Pairing it with match types lets a runtime literal steer a type-level computation — dependent-type _behaviour_, at compile time only.
          ],
        ),
        style: "accent",
      ),
    ),
    callout(
      [Why not climb to the actual summit (CIC / λΠ)?],
      [
        #set text(size: sz(24pt))
        Full dependent types erase the compile/runtime boundary: a type may depend on ANY term, so the compiler must be able to EVALUATE arbitrary programs while type-checking.

        #v(sz(6pt))
        *That requires totality checking* — every function proven to terminate, or the compiler can loop forever — which puts a proof burden on ordinary, messy code.

        #v(sz(6pt))
        Scala / TypeScript take the cheap detour and keep partial, Turing-complete term-level code. Idris / Agda / Lean / Rocq pay the totality price to get the real thing — which is why Stage 7's `believe_me` casts matter: even there, the transport layer steps outside what's proven.
      ],
      style: "bad",
    ),
  ),
)

#speaker-note[
"Great question — and the answer is a nice piece of language design. Scala doesn't reach the top of the lambda cube, but it gets close by a detour. Step one: match types. Stay on the type-operators axis — Fω — but let type-level functions pattern-match and recurse. `Dual` is exactly this: a compile-time algorithm that walks a protocol type and flips every send to a receive. The technical name is ι-reduction. It's real computation, but it only sees types, never runtime values. Step two: singleton types. You give the literal `1234` a type, `1234.type`, that contains only that one value. Now you can feed a runtime literal into a match type — and a runtime value steers a type-level result. That's dependent-type behaviour, achieved entirely at compile time. So why not just go to the summit — Idris, Agda, Lean? Because true dependent types erase the boundary between compile time and runtime: a type can depend on any term, so the compiler has to be able to evaluate any program while type-checking. If that program loops, the compiler loops. So you need totality checking — every function proven to terminate — and that pushes a proof burden onto ordinary code. Scala and TypeScript decline that bargain and keep partial, Turing-complete value-level code. Idris and friends pay the price to get the genuine article. It's the same boundary you saw in Stage 7 with the `believe_me` casts."
]
