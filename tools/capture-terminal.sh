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
