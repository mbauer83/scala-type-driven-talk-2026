// Clock: Q&A — Reading list
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Appendix A7 · Reading], style: "accent"),
  [Where to Read Next],
  grid(
    columns: (1fr, 1fr),
    gutter: sz(20pt),
    stack(
      dir: ttb,
      spacing: sz(10pt),
      text(size: sz(18pt), weight: 500, font: mono-font, fill: pal.fg-dim)[FOR JAVA/SCALA PRACTITIONERS],
      beat-grid((
        ([Rock the JVM],   [Daniel Ciocîrlan], [Scala 3 courses on YouTube and blog. Best on-ramp for practitioners.]),
        ([Type-Driven Dev], [Edwin Brady — Manning], [Hands-on Idris from the author. Best path to dependent types.]),
        ([Category Theory], [Bartosz Milewski], [Blog, book (free PDF), YouTube. Connects functors to the mathematics.]),
      )),
      text(size: sz(18pt), weight: 500, font: mono-font, fill: pal.fg-dim)[FOR FORMAL-METHODS STUDY],
      beat-grid((
        ([TAPL],       [Pierce — Types and Programming Languages],    [Canonical textbook for type-system implementers.]),
        ([Little Typer], [Friedman & Christiansen],                  [Dependent types via Pie. Most accessible book-length introduction.]),
      )),
    ),
    stack(
      dir: ttb,
      spacing: sz(10pt),
      text(size: sz(18pt), weight: 500, font: mono-font, fill: pal.fg-dim)[LANGUAGE-SPECIFIC REFERENCE],
      beat-grid((
        ([Scala 3],   [docs.scala-lang.org/scala3/reference/],   [Match types, opaque types, given/using, capture checking.]),
        ([Idris 2],   [idris-lang.org/pages/documentation.html], [Official docs + Brady's QTT paper.]),
        ([Iron],      [iltotore.github.io/iron/],                 [Refined-types library from Stage 6.]),
        ([PLFA],      [Programming Language Foundations in Agda], [Lambda calculus and type theory in Agda. Free online at plfa.github.io.]),
      )),
      text(size: sz(18pt), weight: 500, font: mono-font, fill: pal.fg-dim)[VERIFIED PROOFS IN PRACTICE],
      beat-grid((
        ([Lean 4 Games],    [adam.math.hhu.de], [In-browser proof puzzles in real Lean 4. Easiest on-ramp.]),
        ([Sw. Foundations], [Pierce et al. — Rocq], [Lambda calculus, type systems, Hoare logic. Free online.]),
      )),
    ),
  ),
)

#speaker-note[
"Order matters here. For someone doing Scala at work, Rock the JVM is the most useful starting point — direct application to what's in your IDE today. From there Brady's Idris book is the cleanest on-ramp to dependent types. Milewski's category-theory series is the connective tissue between the practical patterns we used in Stage 6 and the mathematics underneath. TAPL and ATTPL are heavier — the canonical academic references. The Little Typer is the most accessible book-length introduction to dependent types. If you want to actually try writing proofs without setting up a toolchain first, the HHU Düsseldorf in-browser Lean 4 games are the easiest possible start. From there Software Foundations in Rocq and Mathlib in Lean are where the field actually is."
]
