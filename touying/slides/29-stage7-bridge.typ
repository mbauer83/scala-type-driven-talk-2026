// Clock: 35:00–35:30
#import "../theme.typ": *
#import "../components.typ": *

// Inline-code panel for the protocol / linearity snippets — matches the
// .code-pane chrome but without the tab bar.
#let idris-block(body) = block(
  width: 100%,
  fill: pal.bg-dark-2,
  radius: sz(8pt),
  inset: (x: sz(32pt), y: sz(32pt)),
  stroke: 0.5pt + pal.rule-dark-strong,
)[
  #set par(leading: 0.7em)
  #set text(font: mono-font, size: sz(26pt), fill: pal.fg-dark)
  #body
]

#stage-opener-slide(
  [7],
  [Idris 2 · The Final Bridge],
  [idris 2 · dependent types + quantitative type theory],
  stack(
    dir: ttb,
    spacing: sz(44pt),                                // generous inter-section gap
    callout(
      [Scala's ceiling],
      [`ProtocolVariant` is a *closed* ADT — the set of possible protocols is fixed at compile time, and selection between them happens at runtime through handwritten dispatch code.],
      style: "bad",
    ),
    // ── Third lambda-cube axis (dependent types) ─────────────────────────
    stack(
      dir: ttb,
      spacing: sz(20pt),
      text(size: sz(26pt), weight: 500, font: mono-font, fill: pal.accent)[Third lambda-cube axis (Idris 2)],
      idris-block(raw(lang: "haskell",
        "protocolFromSnapshot : RiskSnapshot -> SessionType\n" +
        "openSession (protocolFromSnapshot snapshot n c)  -- indexed by runtime value"
      )),
      text(size: sz(24pt), fill: pal.fg-dark-dim)[The function _returns_ a `SessionType` computed from the runtime risk snapshot. `openSession` produces channel endpoints _indexed_ by that computed type.],
    ),
    // ── Linearity (QTT) ──────────────────────────────────────────────────
    stack(
      dir: ttb,
      spacing: sz(20pt),
      text(size: sz(26pt), weight: 500, font: mono-font, fill: pal.accent)[+ Linearity (Quantitative Type Theory)],
      idris-block(raw(lang: "haskell",
        "send : (1 _ : Session (Send a rest)) -> a -> ...\n" +
        "       ^ \"consume exactly once\"\n\n" +
        "0 = erased at runtime    1 = linear (use exactly once)    ω = unrestricted"
      )),
    ),
  ),
)

#speaker-note[
"Stage 7 adds the third lambda-cube axis: types whose shape depends on runtime values. The protocol isn't selected from a pre-declared menu — `protocolFromSnapshot` takes a runtime risk snapshot and returns a `SessionType` specific to that risk value. That session-type flows into `openSession`, which returns channel endpoints with the appropriate protocol. Every subsequent `send` and `receive` is type-checked against the protocol. Those are the kind of coherence-guarantees afforded by dependent types. Stage 7 also closes the linearity gap from Stage 6. Idris 2 gives every binding a multiplicity: the default is `ω` — unrestricted use as in every other language we've seen. `1` means use exactly once. `0` means erased at runtime. Since the session channel has multiplicity `1`, the linearity checker refuses any program that drops or re-uses it - or fails to call `finish`."
]
