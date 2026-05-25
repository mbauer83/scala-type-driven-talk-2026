// Clock: 7:00–8:30
#import "../theme.typ": *
#import "../components.typ": *

#theory-slide(
  [The Crisis and the Fix],
  [
    #grid(
      columns: (1fr, 1fr),
      gutter: sz(40pt),
      [
        #text(weight: 500)[Russell (1901)] \
        #v(4pt)
        "The set of all sets that do not contain themselves." \
        Self-reference destroys logical consistency. \
        Cantor's principle — proven inconsistent.

        #v(16pt)
        #line(length: 100%, stroke: 0.5pt + pal.rule-strong)
        #v(16pt)

        #text(weight: 500)[The fix: Types] \
        #v(4pt)
        A strict hierarchy. A predicate (a property of values)
        cannot operate on objects at its own level. Self-reference
        is blocked structurally.
      ],
      [
        #text(weight: 500)[Hilbert's requirements for a perfect proof system] \
        #text(size: sz(24pt), fill: pal.fg-dim)[(stated in parallel with this debate, not after it)]
        #v(12pt)
        #set text(font: mono-font, size: sz(26pt))
        Consistent #h(1em) — never derives ⊥ \
        Sound #h(2.8em) — ⊢ ⟹ ⊨ #h(1em) (provable ⟹ true) \
        Complete #h(1.7em) — ⊨ ⟹ ⊢ #h(1em) (true ⟹ provable)

        #v(16pt)
        #line(length: 100%, stroke: 0.5pt + pal.rule-strong)
        #v(16pt)

        #set text(font: body-font, size: sz(30pt))
        #text(weight: 500)[Gödel (1931):] For any consistent system strong enough
        to encode arithmetic — Completeness is impossible.

        #v(12pt)
        Pivot: drop global completeness. \
        #h(2em) Protect Soundness and Consistency.
      ],
    )
  ],
  footer: ["Types were invented to stop logic from consuming itself. Modern type checkers are descendants of that project: within a chosen calculus, they enforce specific structural guarantees."],
)

#speaker-note[
"Russell found a fatal flaw in the attempts to unify formal reasoning in mathematics and logic. The set of all sets that do not contain themselves — does it contain itself? If yes, it shouldn't. If no, it should. The contradiction lives inside any system that permits unrestricted self-reference. Types were invented as the fix: a strict hierarchy that makes this self-reference structurally impossible. Working in parallel with Russell, Hilbert wrote down three requirements he wanted of any formal system: consistent, sound, and complete. The slide defines them — 'sound' means you can only prove what's actually true; 'complete' means everything true is provable. Gödel proved in 1931 that for any system strong enough to express arithmetic, completeness in that strong sense is impossible — there will always be true arithmetic statements the system cannot prove. The response was to drop the universal-completeness target and concentrate effort on soundness and consistency within specific calculi. That is the family your compiler's type-checker belongs to: it verifies specific structural guarantees within the calculus the language defines."
]
