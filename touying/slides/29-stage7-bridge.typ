// Clock: 35:00–35:30
#import "../theme.typ": *
#import "../components.typ": *

#stage-opener-slide(
  [7],
  [Idris 2 · The Final Bridge],
  [idris 2 · dependent types + quantitative type theory],
  stack(
    dir: ttb,
    spacing: sz(20pt),
    callout(
      [Scala's ceiling],
      [`ProtocolVariant` is a *closed* ADT — the set of possible protocols is fixed at compile time, and selection between them happens at runtime through handwritten dispatch code.],
      style: "bad",
    ),
    stack(
      dir: ttb,
      spacing: sz(16pt),
      text(size: sz(26pt), weight: 500, font: mono-font, fill: pal.accent)[Third lambda-cube axis (Idris 2)],
      raw(lang: "haskell",
        "protocolFromSnapshot : RiskSnapshot -> SessionType\n" +
        "openSession (protocolFromSnapshot snapshot n c)  -- indexed by runtime value"
      ),
      text(size: sz(24pt), fill: pal.fg-dim)[The function _returns_ a `SessionType` value computed from the runtime risk snapshot. `openSession` returns channel endpoints _indexed_ by that computed type.],
    ),
    stack(
      dir: ttb,
      spacing: sz(16pt),
      text(size: sz(26pt), weight: 500, font: mono-font, fill: pal.accent)[+ Linearity (Quantitative Type Theory)],
      raw(lang: "haskell",
        "send : (1 _ : Session (Send a rest)) -> a -> ...\n" +
        "       ^\n" +
        "       \"consume exactly once\"\n\n" +
        "0 = erased at runtime   1 = linear (use exactly once)   ω = unrestricted"
      ),
    ),
  ),
)

#speaker-note[
"In Stages 1 through 6 we moved along the generics axis and the type-operators axis. Stage 7 adds the third: types whose shape depends on runtime values. The protocol value for an order isn't selected from a pre-declared menu — it's computed by `protocolFromSnapshot`, which takes the risk snapshot produced by assessing the order and returns a SessionType value. That value then flows into `openSession`, which returns channel endpoints indexed by it. From that point on, every `send` and `receive` on those endpoints is type-checked against the specific protocol the runtime computation selected. That is the third lambda-cube axis firing in practice. On top of that, Stage 7 closes the linearity gap I named in Stage 6. The mechanism is Idris 2's Quantitative Type Theory: every binding has a multiplicity. The default — what every Java and Scala parameter is — is ω: use as many times as you want, including zero. Idris 2 also lets you mark a parameter 1 for use exactly once, or 0 for exists only at compile time. When the session is bound at 1, the linearity checker refuses to accept a program that drops it. No path through any handler can skip `finish`."
]
