// Clock: 5:15–5:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  [The Pattern],
  block(width: 100%, height: 100%)[
    #v(.2fr)
    // ── Anchor statement — large, centred
    #align(center)[
      #set text(size: sz(56pt), weight: 300, fill: pal.fg)
      #set par(leading: 0.85em, justify: false)
      In each case, a program was able to express\
      something the business rules said was illegal.
    ]
    #v(sz(120pt))
    // ── Two-step arc
    #grid(
      columns: (sz(56pt), 1fr),
      gutter: sz(24pt),
      row-gutter: sz(48pt),
      align: (right + top, left + top),
      text(font: mono-font, size: sz(40pt), weight: 600, fill: pal.accent)[•],
      [
        #set text(size: sz(34pt), fill: pal.fg)
        #set par(leading: 0.45em)
        At each stage, *increasingly expressive types* shrink that gap —
        excluding increasingly larger classes of errors.
      ],
      text(font: mono-font, size: sz(40pt), weight: 600, fill: pal.accent)[•],
      [
        #set text(size: sz(34pt), fill: pal.fg)
        #set par(leading: 0.45em)
        By the end, following these business rules won't be "well tested" —
        #text(weight: 600, fill: pal.accent)[the illegal scenarios simply won't compile anymore.]
      ],
    )
    #v(1fr)
  ],
)

#speaker-note[
"In each case, a program was able to express something the business rules said was illegal. For the rest of the talk we'll walk through seven increasingly expressive type systems — from untyped JavaScript through Java and Scala 3 to Idris 2 — and at each stage we'll see one or more of these four incidents become impossible to express. For closing that gap, we have a toolkit built up over roughly two and a half thousand years. We'll spend a few minutes on that history and motivation, and then for the rest of the talk we'll look at how to cash it out in actual code."
]
