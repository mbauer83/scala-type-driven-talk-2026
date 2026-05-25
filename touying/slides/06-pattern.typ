// Clock: 5:15–5:30
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  [The Pattern],
  [
    In each case, a program was able to express something the business rules said was illegal.

    In this talk we'll look at how using increasingly expressive types let us shrink that gap —
    excluding increasingly larger classes of errors.

    By the end, following these business rules won't be "well tested" —
    the illegal scenarios simply won't compile anymore.
  ],
)

#speaker-note[
"In each case, a program was able to express something the business rules said was illegal. For the rest of the talk we'll walk through seven increasingly expressive type systems — from untyped JavaScript through Java and Scala 3 to Idris 2 — and at each stage we'll see one or more of these four incidents become impossible to express. For closing that gap, we have a toolkit built up over roughly two and a half thousand years. We'll spend a few minutes on that history and motivation, and then for the rest of the talk we'll look at how to cash it out in actual code."
]
