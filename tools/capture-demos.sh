#!/usr/bin/env bash
# capture-demos.sh — apply each live-demo edit, run the real compiler, capture
# the real output to demos/N-*.txt, then restore the source.
#
# This script IS the authoritative description of what to type on stage: it is
# executed, so it cannot drift from the deck the way a prose description can.
# An earlier plan described Demo 3's edit as producing an error it does not
# produce, and Demo 5's edit as "comment out the line", which yields a
# different error entirely. Both were only caught by running them.
#
#   ./tools/capture-demos.sh          # capture all five
#   ./tools/capture-demos.sh 3        # just one
#
# Restores every file it touches, including on failure.

set -uo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
OUT="$ROOT/demos"
mkdir -p "$OUT"

WANT="${1:-all}"
BACKUPS=()
# Restore runs after EVERY demo, not once at the end. Demos 3 and 4 both edit
# PaymentDemo.scala; with a single restore at the end they shared one
# `.demobak` path, so demo 4's backup was a copy of the file with demo 3's edit
# already in it — demo 4 then compiled the wrong source AND the tree was left
# dirty.. The
# EXIT trap stays as the safety net for a failure mid-block.
restore() {
  for (( i=${#BACKUPS[@]}-1; i>=0; i-- )); do
    b="${BACKUPS[$i]}"
    [ -n "$b" ] && cp "$b" "${b%.demobak}" && rm -f "$b"
  done
  BACKUPS=()
}
trap restore EXIT
edit_file() {                       # edit_file <path> <sed-expr>
  cp "$1" "$1.demobak"; BACKUPS+=("$1.demobak"); sed -i "$2" "$1"
}
want() { [ "$WANT" = all ] || [ "$WANT" = "$1" ]; }

# ── Demo 1 — Stage 3, sealed exhaustiveness (Gentzen's ∨E) ───────────────────
# EDIT: delete the `case RiskDecision.Medium m ->` arm in demo4().
if want 1; then
  echo "demo 1: deleting the Medium arm from the switch…"
  d=03-java-function-types-sealed
  edit_file "$d/Demo.java" '/case RiskDecision.Medium m ->/d'
  ( cd "$d" && javac -d /tmp/demo1-out *.java ) 2>&1 | sed "s|$ROOT/||g" > "$OUT/1-exhaustiveness.txt"
  echo "  -> demos/1-exhaustiveness.txt"
  restore
fi

# ── Demo 2 — Stage 4, phantom typestate ─────────────────────────────────────
# EDIT: uncomment `Payment.capture(init);` (the line marked ← UNCOMMENT).
if want 2; then
  echo "demo 2: uncommenting Payment.capture(init)…"
  d=04-java-advanced-generics-typestate
  edit_file "$d/Demo.java" 's|// *Payment\.capture(init);|Payment.capture(init);|'
  ( cd "$d" && javac -d /tmp/demo2-out *.java ) 2>&1 | sed "s|$ROOT/||g" > "$OUT/2-typestate.txt"
  echo "  -> demos/2-typestate.txt"
  restore
fi

# ── Demo 3 — Stage 5, approval indexed by risk ──────────────────────────────
# EDIT: in serverMediumRisk, ThreeDSApproved(proof) -> AutoApproved.
#
# The explicit `: AuthorizedPayment[MediumRisk]` ascription on that val is what
# makes this demo work. Without it the error surfaces one line later at
# ch4.send(...) as `Required: ?1.Msg` with the real type buried in a seven-line
# where-clause, followed by two cascading not-found errors — twenty lines of
# noise on a projector. With it: one error, on the edited line, naming both
# types. Do not remove the ascription.
if want 3; then
  echo "demo 3: swapping ThreeDSApproved for AutoApproved…"
  d=05-scala3-payment
  edit_file "$d/src/main/scala/demos/PaymentDemo.scala" \
            's|      authorize(order, ThreeDSApproved(proof))|      authorize(order, AutoApproved)|'
  ( cd "$d" && sbt -batch -warn compile ) 2>&1 | grep -v '^\[info\]' \
    | sed "s|$ROOT/||g" > "$OUT/3-risk-indexed-approval.txt"
  echo "  -> demos/3-risk-indexed-approval.txt"
  restore
fi

# ── Demo 4 — Stage 5, the protocol refuses the operation ────────────────────
# EDIT: serverHighRisk's last step becomes a wait for an acknowledgement that
# the other side's contract never mentions:
#
#     ch5.send(captured)   ->   val (ack, done) = ch5.receive()
#                               done
#
# It has to be the LAST operation in the protocol. Anywhere earlier and every
# binding below inherits the error type, so one honest error arrives with two or
# three cascading "not found" complaints behind it. Here the remainder of the
# protocol is `Send[CapturedPayment, End]`, which prints inline, and the whole
# thing is one line the room can read.
#
# An earlier version of this edit was `ch5.receive()._2` — one line, same error,
# and nobody has ever written that by accident. This one is a mistake a person
# makes: the payment side decides it should wait for the client to confirm the
# capture. Untyped, both ends then wait and the call hangs.
if want 4; then
  echo "demo 4: serverHighRisk waits for an acknowledgement nobody sends…"
  d=05-scala3-payment
  edit_file "$d/src/main/scala/demos/PaymentDemo.scala" \
            's|^    ch5.send(captured)$|    val (ack, done)       = ch5.receive()\n    done|'
  ( cd "$d" && sbt -batch -warn compile ) 2>&1 | grep -v '^\[info\]' \
    | sed "s|$ROOT/||g" > "$OUT/4-protocol-state.txt"
  echo "  -> demos/4-protocol-state.txt"
  restore
fi

# ── Demo 5 — Stage 6, QTT linearity ─────────────────────────────────────────
# EDIT: replace `finish done` with `pure ()`.
#
# NOT "comment out the line": `finish done` is the last statement of its do
# block, so removing it yields "Last statement in do block must be an
# expression" — a syntax complaint, not the linearity error the slide promises.
# Replacing it keeps the block well-formed so the linearity checker is what
# speaks.
if want 5; then
  echo "demo 5: replacing 'finish done' with 'pure ()'…"
  d=06-idris2-payment
  edit_file "$d/src/Main.idr" '0,/finish done/{s|finish done|pure ()|}'
  ( cd "$d" && idris2 --build payment.ipkg ) 2>&1 | sed "s|$ROOT/||g" > "$OUT/5-linearity.txt"
  echo "  -> demos/5-linearity.txt"
  restore
fi

restore; BACKUPS=()
echo
echo "captured:"; ls -1 "$OUT"/*.txt 2>/dev/null | sed 's|.*/|  |'
echo "sources restored."

# ── Guard ───────────────────────────────────────────────────────────────────
# A capture run must leave the demo sources exactly as it found them. It did
# not, once: demos 3 and 4 both edit PaymentDemo.scala and shared one .demobak
# path, so the "restore" wrote back a copy that already had demo 3's edit in it.
# The tree was left dirty, the next capture compiled the wrong source, and the
# broken file reached a commit before anybody noticed. Fail loudly instead.
dirty=$(git -C "$ROOT" status --porcelain -- \
          03-java-function-types-sealed 04-java-advanced-generics-typestate \
          05-scala3-payment 06-idris2-payment)
if [ -n "$dirty" ]; then
  echo
  echo "ERROR: demo sources were not restored. Run 'git checkout --' on:" >&2
  echo "$dirty" >&2
  exit 1
fi

