#!/usr/bin/env python3
"""
talk-timing.py — measure the deck's speaker notes as actual speaking time.

Reads the #include order out of touying/deck.typ, extracts each slide's
#speaker-note[...] block, counts the words that will actually be spoken
(navigation cues starting with -> and // comments are excluded), and compares
against the per-slide word budget in tools/budget.tsv.

Why words and not minutes: a time estimate made by someone who is not speaking
is a guess. A word count is a fact, and words / rate = minutes is arithmetic.

CALIBRATION (measured 2026-08-17, MB reading Act 0 aloud from the deck):
    01-title    68 words /  20 s = 204 wpm
    02-alice   292 words / 100 s = 175 wpm
    06-pattern 187 words /  65 s = 173 wpm
    combined   547 words / 185 s = 177 wpm  (including slide navigation)

The default is 130, not 177. A quiet read-through is the fastest you will ever
deliver this; live you are nervous, projecting to the back of a room, breathing,
and pausing for the audience. 130 is the measured rate discounted by ~25%, which
is the usual gap. Sweep it if you want the range: --wpm 150 is the optimistic
case, --wpm 115 the bad-night case.

    make timing                 # default 120 wpm
    make timing WPM=95          # after calibrating against a real read-through
    python3 tools/talk-timing.py --wpm 95 --verbose
"""

import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECK = os.path.join(ROOT, "touying", "deck.typ")
SLIDES = os.path.join(ROOT, "touying", "slides")
BUDGET = os.path.join(ROOT, "tools", "budget.tsv")

# Demo slides are spoken more slowly — you pause, you type, the room reads the
# error. Empirically this lands nearer 70 wpm than 120.
DEMO_WPM_FACTOR = 70.0 / 120.0


def deck_order():
    """Slide stems in include order, split at the appendix pagebreak."""
    src = open(DECK, encoding="utf-8").read()
    main, appendix, seen_break = [], [], False
    for line in src.splitlines():
        if "#pagebreak()" in line:
            seen_break = True
        m = re.match(r'\s*#include\s+"slides/([^"]+)\.typ"', line)
        if m:
            (appendix if seen_break else main).append(m.group(1))
    return main, appendix


def _resolve_reads(note, slide_path):
    """Inline any #read("...") the note delegates to, so tools see real prose."""
    def sub(m):
        rel = m.group(1)
        target = os.path.normpath(os.path.join(os.path.dirname(slide_path), rel))
        try:
            return open(target, encoding="utf-8").read()
        except OSError:
            return ""
    return re.sub(r'#read\(\s*"([^"]+)"\s*\)', sub, note)


def spoken_words(stem):
    """Words in the slide's speaker note that will actually be said aloud."""
    path = os.path.join(SLIDES, stem + ".typ")
    if not os.path.exists(path):
        return None
    src = open(path, encoding="utf-8").read()
    i = src.find("#speaker-note[")
    if i < 0:
        return 0
    j = src.index("[", i)
    depth = 0
    for k in range(j, len(src)):
        if src[k] == "[":
            depth += 1
        elif src[k] == "]":
            depth -= 1
            if depth == 0:
                break
    note = _resolve_reads(src[j + 1:k], path)
    # Drop presenter navigation cues and authoring comments — not spoken.
    note = re.sub(r"^\s*(→|//).*$", "", note, flags=re.M)
    note = re.sub(r"[#*_\\`\[\]]", " ", note)

    # Convention: what you actually say is inside double quotes; everything
    # else in the note is delivery guidance and is not counted. Slides whose
    # notes predate the convention fall back to counting the whole note.
    quoted = re.findall(r'"([^"]*)"', note)
    spoken = " ".join(quoted)
    if len(spoken.split()) >= 20:
        return len(spoken.split())
    return len(note.split())


def budget():
    """stem -> (cap_seconds, kind). Missing file just disables comparison."""
    caps = {}
    if not os.path.exists(BUDGET):
        return caps
    for line in open(BUDGET, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        stem, mmss = parts[0], parts[1]
        kind = parts[2] if len(parts) > 2 else "prose"
        m, s = (mmss.split(":") + ["0"])[:2]
        caps[stem] = (int(m) * 60 + int(s), kind)
    return caps


def fmt(seconds):
    seconds = int(round(seconds))
    return f"{seconds // 60}:{seconds % 60:02d}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--wpm", type=float, default=130.0,
                    help="planning speaking rate (default 130 — see note above)")
    ap.add_argument("--slot", type=float, default=45.0, help="slot in minutes")
    ap.add_argument("--verbose", action="store_true",
                    help="also list appendix slides")
    args = ap.parse_args()

    caps = budget()
    main_slides, appendix = deck_order()

    print(f"{'slide':<26}{'words':>6}{'spoken':>9}{'cap':>8}  ")
    print("-" * 55)

    total_words = total_spoken = total_cap = 0
    over = []
    for stem in main_slides:
        w = spoken_words(stem)
        if w is None:
            print(f"{stem:<26}{'MISSING':>6}")
            continue
        cap_s, kind = caps.get(stem, (None, "prose"))
        rate = args.wpm * (DEMO_WPM_FACTOR if kind == "demo" else 1.0)
        spoken = w / rate * 60.0
        total_words += w
        total_spoken += spoken
        mark = ""
        if cap_s is not None:
            total_cap += cap_s
            if spoken > cap_s + 3:
                mark = f"  OVER by {fmt(spoken - cap_s)}"
                over.append((stem, spoken - cap_s))
        print(f"{stem:<26}{w:>6}{fmt(spoken):>9}"
              f"{(fmt(cap_s) if cap_s is not None else '—'):>8}{mark}")

    print("-" * 55)
    print(f"{'TOTAL (main deck)':<26}{total_words:>6}{fmt(total_spoken):>9}"
          f"{(fmt(total_cap) if total_cap else '—'):>8}")
    print()
    print(f"speaking rate assumed : {args.wpm:.0f} wpm "
          f"({args.wpm * DEMO_WPM_FACTOR:.0f} wpm on demo slides)")
    print(f"slot                  : {fmt(args.slot * 60)}")
    slack = args.slot * 60 - total_spoken
    verdict = "within slot" if slack >= 0 else "OVER SLOT"
    print(f"prose vs slot         : {fmt(abs(slack))} "
          f"{'of slack' if slack >= 0 else 'over'}  <- {verdict}")

    if over:
        print()
        print("slides over their word budget, worst first:")
        for stem, delta in sorted(over, key=lambda x: -x[1]):
            print(f"  {stem:<26} +{fmt(delta)}")

    if args.verbose and appendix:
        print()
        print("appendix (not counted):")
        for stem in appendix:
            w = spoken_words(stem)
            if w:
                print(f"  {stem:<26}{w:>6}{fmt(w / args.wpm * 60):>9}")

    return 1 if total_spoken > args.slot * 60 else 0


if __name__ == "__main__":
    sys.exit(main())
