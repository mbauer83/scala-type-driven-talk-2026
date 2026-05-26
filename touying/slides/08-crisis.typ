// Clock: 7:00–8:30
#import "../theme.typ": *
#import "../components.typ": *

#let q-heading(body) = text(size: sz(34pt), weight: 600, fill: pal.fg)[#body]

// Per-column quadrant — keeps the divider local to its column so reading order
// stays top→bottom within each column rather than reading across.
#let quadrant(top-body, bottom-body) = stack(
  dir: ttb,
  spacing: 0pt,
  block(width: 100%, inset: (bottom: sz(56pt)), top-body),
  block(width: 100%, stroke: (top: 0.5pt + pal.rule-strong),
        inset: (top: sz(56pt)), bottom-body),
)

#theory-slide(
  [The Crisis and the Fix],
  [
    #v(1fr)
    #grid(
      columns: (1fr, 1fr),
      gutter: sz(96pt),
      // ── Left column — Russell / The fix: Types
      quadrant(
        [
          #q-heading[Russell (1901)]
          #v(sz(14pt))
          "The set of all sets that do not contain themselves." \
          Self-reference destroys logical consistency. \
          Cantor's principle — proven inconsistent.
        ],
        [
          #q-heading[The fix: Types]
          #v(sz(14pt))
          A strict hierarchy. A predicate (a property of values)
          cannot operate on objects at its own level. Self-reference
          is blocked structurally.
        ],
      ),
      // ── Right column — Hilbert / Gödel
      quadrant(
        [
          #q-heading[Hilbert's requirements for a perfect proof system]
          #text(size: sz(22pt), fill: pal.fg-dim)[ (stated in parallel with this debate, not after it)]
          #v(sz(18pt))
          #set text(font: mono-font, size: sz(26pt))
          #grid(
            columns: (auto, auto, auto, 1fr),
            gutter: sz(10pt),
            row-gutter: sz(6pt),
            [Consistent], [—], [#h(0pt)],          [never derives ⊥],
            [Sound],      [—], [⊢ ⟹ ⊨],            [(provable ⟹ true)],
            [Complete],   [—], [⊨ ⟹ ⊢],            [(true ⟹ provable)],
          )
        ],
        [
          #q-heading[Gödel (1931)]
          #v(sz(14pt))
          For any consistent system strong enough to encode arithmetic —
          Completeness is impossible.
          #v(sz(12pt))
          Pivot: drop global completeness. \
          #h(2em) Protect Soundness and Consistency.
        ],
      ),
    )
    #v(1fr)
  ],
  footer: ["Types were invented to stop logic from consuming itself. Modern type checkers are descendants of that project: within a chosen calculus, they enforce specific structural guarantees."],
)

#speaker-note[
"Russell found a fatal flaw in the attempts to unify formal reasoning in mathematics and logic. The set of all sets that do not contain themselves — does it contain itself? If yes, it shouldn't. If no, it should. The contradiction lives inside any system that permits unrestricted self-reference. Types were invented as the fix: a strict hierarchy that makes this self-reference structurally impossible. Working in parallel with Russell, Hilbert wrote down three requirements he wanted of any formal system: consistent, sound, and complete. The slide defines them — 'sound' means you can only prove what's actually true; 'complete' means everything true is provable. Gödel proved in 1931 that for any system strong enough to express arithmetic, completeness in that strong sense is impossible — there will always be true arithmetic statements the system cannot prove. The response was to drop the universal-completeness target and concentrate effort on soundness and consistency within specific calculi. That is the family your compiler's type-checker belongs to: it verifies specific structural guarantees within the calculus the language defines."
]
