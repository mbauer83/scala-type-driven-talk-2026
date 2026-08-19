#import "../theme.typ": *
#import "../components.typ": *

#let mech(name, code, body) = stack(
  dir: ttb,
  spacing: sz(11pt),
  text(size: sz(27pt), weight: 600, fill: pal.fg)[#name],
  block[
    #show raw: set text(font: mono-font, size: sz(22pt), fill: pal.accent-deep)
    #code
  ],
  block[
    #set text(size: sz(23pt), fill: pal.fg-dim)
    #set par(leading: 0.4em)
    #body
  ],
)

#light-slide(
  eyebrow: eyebrow([Stage 5 · the mechanisms, and the family next door]),
  body-gap: sz(36pt),
  [What else a type can carry],
  grid(
    columns: (1fr, 0.95fr),
    column-gutter: sz(52pt),
    align: (left + top, left + top),

    stack(
      dir: ttb,
      spacing: sz(18pt),
      mech([Refined types], `String :| MinLength[1]`,
           [The predicate is part of the type. A macro decides it for a literal;
            a smart constructor decides it for everything else.]),
      mech([Opaque types], `opaque type AuthCode = String`,
           [`AuthCode` and `CaptureId` are both `String` at runtime, and the
            compiler refuses to swap them.]),
      mech([Path-dependent types], `def send(using s: CanSend[P])(value: s.Msg)`,
           [`P` is what is left of the protocol; `CanSend[P]` is a claim about it
            — that it starts with a send. Ask for the claim as evidence, and
            `s.Msg` — a type reached through the value `s` — is the message type
            that comes with it.]),
      mech([Evidence the compiler builds], `def finish()(using ev: P =:= End)`,
           [Evidence of a different claim — that `P` has reached the end. Mid-protocol
            there is none to be had, so you cannot hang up in the middle of the call.]),
      mech([Higher-kinded types], `def interpret[F[_]: Functor, A](algebra: F[A] => A)`,
           [`F[_]` is a type parameter that is itself generic — it stands, say,
            for `List`, not for a list of something, and Java has no way to write
            it.
            The payment rules are one tree: `interpret` walks it once, and what
            comes out is a parameter — an audit sentence, or a risk analysis.]),
    ),

    stack(
      dir: ttb,
            spacing: sz(32pt),
      [
        #set text(size: sz(25pt), fill: pal.fg)
        #set par(leading: 0.45em)
        Every one of those puts something about a value into the value's type.
        #text(fill: pal.fg-dim)[ Next door is a family that puts in what a value
        is allowed to #emph[do].]
      ],
      callout(
        [In production today · ZIO],
        stack(
          dir: ttb,
                    spacing: sz(14pt),
          text(font: mono-font, size: sz(20pt), fill: pal.fg)[
            def loadUser(id: UserId): ZIO\[Database, DbError, User\]
          ],
          [
            #set text(size: sz(21pt), fill: pal.fg-dim)
            #set par(leading: 0.4em)
            Needs a database · can fail this way · produces a user. All three in
            the signature, where the caller has to deal with them.
          ],
        ),
        style: "accent",
      ),
      callout(
        [Experimental · Scala 3 capture checking],
        stack(
          dir: ttb,
                    spacing: sz(14pt),
          text(font: mono-font, size: sz(20pt), fill: pal.fg)[
            val loadUser: UserId -\>\{db, canThrow\} User
          ],
          [
            #set text(size: sz(21pt), fill: pal.fg-dim)
            #set par(leading: 0.4em)
            All three on the arrow instead of in a wrapper: `db` is the database,
            `canThrow` is a `CanThrow[DbError]`, and the result is a plain `User`.
            Ordinary code, ordinary shape.
          ],
        ),
        style: "bad",
      ),
    ),
  ),
)

#speaker-note[
#read("../scripts/23-mechanisms.md")
]
