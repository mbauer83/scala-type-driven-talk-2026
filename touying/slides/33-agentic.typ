// Clock: 42:00–43:00
#import "../theme.typ": *
#import "../components.typ": *

#light-slide(
  eyebrow: eyebrow([Agentic Development]),
  [Expressive Types in the Age of Agentic Development],
  stack(
    dir: ttb,
    spacing: sz(20pt),
    [
      #set text(size: sz(30pt), weight: 300)
      Code is now being generated faster than humans can review it.
      Agents propose changes; teams ship them.

      When the type system can carry the invariants we care about,
      every generated line passes the same structural checks every hand-written line does.
      *The compiler does not care who wrote it.*
    ],
    callout(
      [Unwritable — regardless of author],
      grid(
        columns: (1fr, 1fr),
        gutter: sz(12pt),
        [
          #set text(size: sz(26pt), font: mono-font, fill: pal.fg-dim)
          Incomplete protocol step #h(1fr) → does not compile.\
          Skipped lifecycle transition #h(1fr) → does not compile.
        ],
        [
          #set text(size: sz(26pt), font: mono-font, fill: pal.fg-dim)
          Empty identifier at the boundary #h(1fr) → does not compile.\
          Dropped channel without finish #h(1fr) → does not compile.
        ],
      ),
      style: "accent",
    ),
    stack(
      dir: ttb,
      spacing: sz(12pt),
      [
        #set text(size: sz(28pt), weight: 300)
        For agentic workflows specifically: the compiler gives the agent a stable, mechanical
        signal to iterate against. Compile errors are actionable without a human in the loop
        on every step.
      ],
      [
        #set text(size: sz(28pt), weight: 300)
        Proof assistants — Lean, Rocq, Agda, Idris itself — go further: the proof obligation
        becomes a first-class part of the type. The proof still has to be written, but the
        assistant checks it mechanically, and modern tactic libraries automate growing fractions
        of the work.
      ],
      [
        #set text(size: sz(26pt), fill: pal.fg-dim)
        When generation speed exceeds review capacity, an expressive type system raises the
        share of correctness that is enforced before merge rather than spotted by a reviewer.
      ],
    ),
  ),
)

#speaker-note[
"There's another concrete reason this story matters now. AI agents can produce a working PR faster than a human can read it carefully. An expressive type system raises the floor of correctness that holds regardless of the author: incomplete protocol steps, skipped lifecycle transitions, empty identifiers, dropped channels — none of those compile, whether a person or a model wrote them. For agentic workflows specifically, the compiler gives the agent a stable, mechanical signal to iterate against; compile errors are actionable without a human in the loop on every step. Proof assistants like Lean, Rocq, Agda, and Idris itself go further: the proof obligation becomes a first-class part of the type. To be precise, these are interactive proof assistants — the proof still has to be written, but the machine checks it mechanically and modern tactic libraries automate increasing portions of it."
]
