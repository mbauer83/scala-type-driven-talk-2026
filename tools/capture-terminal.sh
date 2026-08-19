#!/usr/bin/env bash
# capture-terminal.sh — record each live demo as terminal FRAMES the deck can
# contain, so a failed demo costs nothing but a keypress.
#
# capture-demos.sh records the compiler's error text. This records the session:
# the edit that was made, and the transcript of the compile that followed. The
# deck renders each frame as a slide, so pressing forward replays what the room
# would have seen. No video, no codec, no player — it works on any projector
# and any PDF viewer, which is the point.
#
#   ./tools/capture-terminal.sh
#
# Writes demos/N-edit.txt and demos/N-term.txt. Restores every file it touches.
set -uo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd); OUT="$ROOT/demos"; mkdir -p "$OUT"

frame () {                       # frame <n> <dir> <file> <sed-expr> <label>
  local n=$1 dir=$2 file=$3 expr=$4
  local src="$ROOT/$dir/$file" bak; bak=$(mktemp)
  cp "$src" "$bak"
  {
    echo "\$ sed -i '$expr' $file"
    echo "\$ git diff --stat -- $file"
  } > "$OUT/$n-edit.txt"
  sed -i "$expr" "$src"
  diff -u "$bak" "$src" | sed -n '3,$p' | sed 's|^|  |' >> "$OUT/$n-edit.txt"
  {
    echo "\$ javac -d /tmp/out *.java"
    ( cd "$ROOT/$dir" && javac -d /tmp/out ./*.java 2>&1 | head -8 )
  } > "$OUT/$n-term.txt"
  cp "$bak" "$src"; rm -f "$bak"
  echo "captured $n: $(wc -l < "$OUT/$n-edit.txt") + $(wc -l < "$OUT/$n-term.txt") lines"
}

frame 1 03-java-function-types-sealed Demo.java \
      '/case RiskDecision.Medium m -> "medium-risk 3DS path"/d'
frame 2 04-java-advanced-generics-typestate Demo.java \
      's|^            // Payment.capture(init);|            Payment.capture(init);|'

# ── Demo 3 — Stage 5, approval indexed by risk (sbt, not javac) ──────────────
# The `frame` helper above is javac-shaped; Scala needs its own command and a
# longer error, so demo 3 is written out rather than squeezed through it.
# The edit is the one capture-demos.sh applies — keep the two in step.
frame3 () {
  local dir=05-scala3-payment file=src/main/scala/demos/PaymentDemo.scala
  local expr='s|      authorize(order, ThreeDSApproved(proof))|      authorize(order, AutoApproved)|'
  local src="$ROOT/$dir/$file" bak; bak=$(mktemp)
  cp "$src" "$bak"
  {
    echo "\$ sed -i '…ThreeDSApproved(proof) → AutoApproved…' PaymentDemo.scala"
    echo "\$ git diff -- PaymentDemo.scala"
  } > "$OUT/3-edit.txt"
  sed -i "$expr" "$src"
  diff -u "$bak" "$src" | sed -n '3,$p' | sed 's|^|  |' >> "$OUT/3-edit.txt"
  {
    echo "\$ sbt compile"
    ( cd "$ROOT/$dir" && sbt -batch -warn compile 2>&1 \
        | grep -v '^\[info\]' | sed "s|$ROOT/||g" | head -8 )
  } > "$OUT/3-term.txt"
  cp "$bak" "$src"; rm -f "$bak"
  echo "captured 3: $(wc -l < "$OUT/3-edit.txt") + $(wc -l < "$OUT/3-term.txt") lines"
}

frame3

# ── Demo 5 — Stage 5, the protocol refuses the operation (sbt) ───────────────
# EDIT: serverHighRisk's LAST line, `ch5.send(captured)` -> `ch5.receive()._2`.
#
# The position is the whole trick. Four other edits produce the same class of
# error and none of them is readable on a projector: sending a message the
# protocol has no room for prints `Required: ?1.Msg`; handing a server the wrong
# channel prints both protocols expanded, about thirty-five lines; skipping a
# step mid-protocol cascades into every binding below it. This one is the last
# operation in the protocol, so nothing downstream inherits the error type and
# the remainder is two constructors deep — one error, one line, all concrete:
#
#   No given instance of type CanReceive[Send[CapturedPayment, End]] was found
#   for parameter r of method receive in class Channel
#
# Keep the edit on the LAST operation if this ever has to move to another
# server; that is what keeps it to one error.
frame5 () {
  local dir=05-scala3-payment file=src/main/scala/demos/PaymentDemo.scala
  local expr='s|^    ch5.send(captured)$|    ch5.receive()._2|'
  local src="$ROOT/$dir/$file" bak; bak=$(mktemp)
  cp "$src" "$bak"
  {
    echo "\$ sed -i '…ch5.send(captured) → ch5.receive()._2…' PaymentDemo.scala"
    echo "\$ git diff -- PaymentDemo.scala"
  } > "$OUT/5-edit.txt"
  sed -i "$expr" "$src"
  diff -u "$bak" "$src" | sed -n '3,$p' | sed 's|^|  |' >> "$OUT/5-edit.txt"
  {
    echo "\$ sbt compile"
    ( cd "$ROOT/$dir" && sbt -batch -warn compile 2>&1 \
        | grep -v '^\[info\]' | sed "s|$ROOT/||g" | head -8 )
  } > "$OUT/5-term.txt"
  cp "$bak" "$src"; rm -f "$bak"
  echo "captured 5: $(wc -l < "$OUT/5-edit.txt") + $(wc -l < "$OUT/5-term.txt") lines"
}

frame5

# ── Demo 4 — Stage 6, QTT linearity (idris2) ─────────────────────────────────
# Same edit capture-demos.sh applies. NOT "comment the line out": `finish done`
# is the last statement of its do block, so deleting it yields a syntax
# complaint instead of the linearity error the slide promises.
frame4 () {
  local dir=06-idris2-payment file=src/Main.idr
  local expr='0,/finish done/{s|finish done|pure ()|}'
  local src="$ROOT/$dir/$file" bak; bak=$(mktemp)
  cp "$src" "$bak"
  {
    echo "\$ sed -i '…first finish done → pure ()…' src/Main.idr"
    echo "\$ git diff -- src/Main.idr"
  } > "$OUT/4-edit.txt"
  sed -i "$expr" "$src"
  diff -u "$bak" "$src" | sed -n '3,$p' | sed 's|^|  |' >> "$OUT/4-edit.txt"
  {
    echo "\$ idris2 --build payment.ipkg"
    ( cd "$ROOT/$dir" && idris2 --build payment.ipkg 2>&1 | sed "s|$ROOT/||g" | head -12 )
  } > "$OUT/4-term.txt"
  cp "$bak" "$src"; rm -f "$bak"
  echo "captured 4: $(wc -l < "$OUT/4-edit.txt") + $(wc -l < "$OUT/4-term.txt") lines"
}

frame4
