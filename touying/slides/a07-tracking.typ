// Clock: Q&A — Reading list
#import "../theme.typ": *
#import "../components.typ": *

#let reading-section(header, entries) = stack(
  dir: ttb,
  spacing: sz(18pt),
  text(size: sz(20pt), weight: 500, font: mono-font, fill: pal.fg-dim, tracking: 0.05em)[#header],
  line(length: 100%, stroke: 0.5pt + pal.rule),
  grid(
    columns: (sz(180pt), 1fr),
    column-gutter: sz(20pt),
    row-gutter: sz(28pt),
    ..entries.map(((name, link-text, link-url, desc)) => (
      text(size: sz(22pt), weight: 600, fill: pal.accent)[#name],
      [
        #set par(leading: 0.4em)
        #if link-url != none {
          link(link-url, text(size: sz(22pt), fill: pal.fg, font: mono-font, link-text))
        } else {
          text(size: sz(22pt), fill: pal.fg)[#link-text]
        } \
        #text(size: sz(20pt), fill: pal.fg-dim)[#desc]
      ],
    )).flatten()
  ),
)

#light-slide(
  eyebrow: eyebrow([Appendix A7 · Reading], style: "accent"),
  [Curious? Start here.],
  grid(
    columns: (1fr, 1fr),
    gutter: sz(48pt),
    // ── Left column: practitioner path
    stack(
      dir: ttb,
      spacing: sz(48pt),
      reading-section(
        [FOR PRACTITIONERS],
        (
          ([Rock the JVM],     [rockthejvm.com],                                  "https://rockthejvm.com",          [Daniel Ciocîrlan — Scala 3 courses, free YouTube blog.]),
          ([Type-Driven Dev],  [manning.com/books/type-driven-development-with-idris], "https://www.manning.com/books/type-driven-development-with-idris", [Brady's hands-on path into dependent types.]),
          ([Category Theory],  [bartoszmilewski.com],                              "https://bartoszmilewski.com",     [Blog · free PDF · YouTube. Functors to math.]),
        ),
      ),
      reading-section(
        [FORMAL FOUNDATIONS],
        (
          ([Curry-Howard],    [Lectures on the Curry-Howard Isomorphism],          none,                              [Sørensen & Urzyczyn — propositions-as-types in depth.]),
          ([TAPL],            [Pierce, Types & Programming Languages],            none,                              [Canonical type-system textbook.]),
          ([Little Typer],    [Friedman & Christiansen],                          none,                              [Most accessible intro to dependent types.]),
        ),
      ),
    ),
    // ── Right column: language docs + verified proofs
    stack(
      dir: ttb,
      spacing: sz(48pt),
      reading-section(
        [LANGUAGE REFERENCE],
        (
          ([Scala 3],         [docs.scala-lang.org/scala3/reference/],            "https://docs.scala-lang.org/scala3/reference/", [Match types, opaque, given/using, captures.]),
          ([Idris 2],         [idris-lang.org/pages/documentation.html],          "https://www.idris-lang.org/pages/documentation.html", [Docs + Brady's QTT paper.]),
          ([Iron],            [iltotore.github.io/iron/],                          "https://iltotore.github.io/iron/", [Refined types — used in Stage 6.]),
          ([PLFA],            [plfa.github.io],                                    "https://plfa.github.io",          [Lambda calculus + type theory in Agda.]),
        ),
      ),
      reading-section(
        [PROOFS, IN PRACTICE],
        (
          ([Lean 4 Games],    [adam.math.hhu.de],                                  "https://adam.math.hhu.de",         [In-browser Lean proof puzzles — easiest start.]),
          ([Sw. Foundations], [softwarefoundations.cis.upenn.edu],                 "https://softwarefoundations.cis.upenn.edu", [Pierce et al. in Rocq — full course.]),
        ),
      ),
    ),
  ),
)

#speaker-note[
"Order matters here. For someone doing Scala at work, Rock the JVM is the most useful starting point — direct application to what's in your IDE today. From there Brady's Idris book is the cleanest on-ramp to dependent types. Milewski's category-theory series is the connective tissue between the practical patterns we used in Stage 6 and the mathematics underneath. TAPL and ATTPL are heavier — the canonical academic references. The Little Typer is the most accessible book-length introduction to dependent types. If you want to actually try writing proofs without setting up a toolchain first, the HHU Düsseldorf in-browser Lean 4 games are the easiest possible start. From there Software Foundations in Rocq and Mathlib in Lean are where the field actually is."
]
