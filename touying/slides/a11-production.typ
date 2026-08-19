// APPENDIX · where these features actually run.
//
// MB, 19 Aug: for dependent types and session types, name real productive use
// cases with the best-known solutions, and make them VERIFIABLE. Every row
// below was checked against a primary source on 19 Aug; the citations are in
// the speaker note. Claims are deliberately narrow — the value of this slide is
// that every line survives a sceptic with a laptop.
//
// It is a separate slide rather than an addition to a07 (MB's suggestion)
// because a07 is already four sections across two columns, and "what to read"
// and "where it ships" are different questions. Flagged, not done quietly.
//
// The session-types row is the important one: there is NO production deployment
// to point at, and saying so is what makes the rest of the slide credible.
#import "../theme.typ": *
#import "../components.typ": *

#let row(what, tool, where) = (
  text(size: sz(23pt), weight: 600, fill: pal.fg)[#what],
  text(size: sz(21pt), font: mono-font, fill: pal.accent-deep)[#tool],
  block[
    #set text(size: sz(21pt), fill: pal.fg-dim)
    #set par(leading: 0.4em)
    #where
  ],
)

#light-slide(
  eyebrow: eyebrow([Appendix · in production], style: "accent"),
  body-gap: sz(24pt),
  [Where these features actually run],
  stack(
    dir: ttb,
    spacing: sz(26pt),
    grid(
      columns: (sz(300pt), sz(210pt), 1fr),
      column-gutter: sz(24pt),
      row-gutter: sz(20pt),
      ..row([HACL\* / EverCrypt], [F\*], [Verified crypto shipping in Firefox's NSS, the Linux kernel,
             mbedTLS, WireGuard, Tezos and ElectionGuard. Curve25519 landed in Firefox 57.]),
      ..row([Fiat-Crypto], [Rocq (Coq)], [Generates the elliptic-curve field arithmetic in BoringSSL —
             which is Chrome and Android.]),
      ..row([CompCert], [Rocq (Coq)], [A C compiler whose optimiser is proved correct. Sold by AbsInt;
             qualified in 2026 for ATR 42/72 avionics with DO-178C and DO-330 credit.]),
      ..row([Cedar], [Dafny], [AWS's authorization language. The Dafny implementation is proved
             against its spec and used as the correctness oracle for the production Rust.]),
      ..row([Ownership / borrow check], [Rust], [Substructural typing at industrial scale — the same
             family as Stage 6's use-once binding, shipped to millions of developers.]),
    ),
    line(length: 100%, stroke: 0.5pt + pal.rule),
    [
      #set text(size: sz(23pt), fill: pal.fg)
      #set par(leading: 0.45em)
      #text(weight: 600)[Session types are the exception, and it is worth saying so.]
      #text(fill: pal.fg-dim)[ There is no deployment of this size to point at.
      Scribble is the reference toolchain — one global protocol, projected to a
      local type per role, generating endpoint APIs and runtime monitors — and
      its case studies are HTTP, SMTP and WebSocket. What did reach production is
      the weaker cousin: typestate APIs, and protocol-driven code generation.]
    ],
  ),
)

#speaker-note[
Q&A only. Every claim here was checked against a primary source on 19 Aug 2026.

SOURCES
- HACL* / EverCrypt — Mozilla Security Blog, "Verified cryptography for Firefox
  57" (2017) and "Performance Improvements via Formally-Verified Cryptography in
  Firefox" (2020); hacl-star.github.io lists NSS, the Linux kernel, mbedTLS,
  WireGuard, Tezos and ElectionGuard as deployments. F* is dependently typed,
  which is why this is the strongest single row on the slide.
- Fiat-Crypto — boringssl.googlesource.com/boringssl/+/master/third_party/fiat;
  MIT CSAIL and the IEEE S&P 2019 paper "Simple High-Level Code For
  Cryptographic Arithmetic". Reported coverage is around 90% of secure Chrome
  connections; the slide says "Chrome and Android" instead, because that is the
  part that needs no qualification.
- CompCert — absint.com/compcert; AbsInt press release, March 2026, CompCert
  qualified for the MFC generation of ATR 42/72. AbsInt's toolchain has a longer
  avionics history than CompCert alone, so the slide cites only the ATR
  qualification, which is CompCert-specific and dated.
- Cedar — "Formally Verified Cloud-Scale Authorization" (ICSE 2025); AWS Open
  Source Blog; the Dafny model is the oracle for differential testing of the
  production Rust implementation. Dafny is verification-aware rather than
  dependently typed — say "proof-carrying", not "dependent types", if pressed.
- Rust — ownership and borrowing are affine typing. Not dependent types; it is
  on the slide because it is the substructural cousin of Stage 6's `1`, and it
  is the one row everybody in the room has already used.
- Session types — Scribble's published case studies are HTTP, SMTP and, more
  recently, WebSocket for JavaScript; Scribble-Java generates endpoint APIs
  checked statically with runtime linearity checks. No production deployment at
  the scale of the rows above was found. Do not invent one.

WHAT NOT TO CLAIM
seL4 is a verified microkernel but the proof is in Isabelle/HOL, which is not
dependent type theory — mention it as adjacent if asked, not as an example here.
And CompCert's guarantee is about the compiler, not about the C you feed it.
]
