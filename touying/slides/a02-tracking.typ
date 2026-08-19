// Clock: Q&A — Linearity
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Appendix A2 · Linearity], style: "accent"),
  [Linearity across languages],
  stack(
    dir: ttb,
    spacing: sz(28pt),
    [
      #set text(size: sz(28pt), weight: 300)
      The "use exactly once" idea isn't unique to Idris 2:
    ],
    grid(
      columns: (1fr, 1fr),
      gutter: sz(24pt),
      callout(
        [Idris 2 (QTT)],
        stack(
          dir: ttb,
          spacing: sz(10pt),
          raw(lang: "haskell", "(1 ch : Session p) -> ..."),
          [
            #set text(size: sz(24pt), fill: pal.fg-dim)
            Multiplicities `0` / `1` / `ω` on bindings. We used this in Stage 6 for the channel. The channel must be consumed exactly once — `finish` or chain to the next step.
          ],
        ),
        style: "accent",
      ),
      callout(
        [Haskell (GHC ≥ 9)],
        stack(
          dir: ttb,
          spacing: sz(10pt),
          raw(lang: "haskell", "ch %1 -> rest"),
          [
            #set text(size: sz(24pt), fill: pal.fg-dim)
            Linear arrow syntax. Same semantics; surface difference is the annotation on the function arrow rather than the binding. Opt-in — existing code is unaffected.
          ],
        ),
        style: "accent",
      ),
      callout(
        [Rust (since 1.0)],
        stack(
          dir: ttb,
          spacing: sz(10pt),
          raw(lang: "rust", "fn close(c: Channel) { ... }"),
          [
            #set text(size: sz(24pt), fill: pal.fg-dim)
            Move semantics + borrow checker. Owning a value means "you have it"; passing it moves it. Affine rather than linear — drops are permitted, double-use is not. The entire language is designed around it.
          ],
        ),
        style: "accent",
      ),
      callout(
        [Clean (1987–)],
        [
          #set text(size: sz(24pt), fill: pal.fg-dim)
          Uniqueness types — historically first. A unique type guarantees there is exactly one reference at any point. The conceptual ancestor of all the above.
        ],
        style: "accent",
      ),
    ),
    [
      #set text(size: sz(26pt), fill: pal.fg-dim, weight: 300)
      The trade you pick depends on whether you want linearity-as-default (Rust — pervasive, mandatory) or linearity-as-tool (Idris, Haskell — opt in for resources that benefit, unrestricted elsewhere).
    ],
  ),
)

#speaker-note[
"Idris 2's QTT is one point in a family of approaches. Haskell with the linear-types extension uses a different surface syntax — `%1 ->` on the arrow rather than on the binding — but the semantics are very similar: a value passed at multiplicity 1 must be consumed exactly once. Rust takes a different formal route — its system is affine rather than linear, meaning dropping values without consuming them is allowed but using them twice is not — and bakes the entire mechanism into the language as ownership and the borrow checker. The engineering outcome for resource safety is similar: file handles, channels, database connections can't be leaked or double-closed by accident. The cost differs: Rust forces every developer to think about ownership all the time; Idris and Haskell let you opt in for resources that benefit, while keeping ordinary code at unrestricted multiplicity. There's no single right point — it depends on whether you want linearity as the default or as a precision tool."
]
