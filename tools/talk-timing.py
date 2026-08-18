#!/usr/bin/env python3
"""
talk-timing.py — measure the deck's speaker notes as actual speaking time.

Reads the #include order out of touying/deck.typ, extracts each slide's
#speaker-note[...] block, counts the words that will actually be spoken
(navigation cues starting with -> and // comments are excluded), and compares
against the per-slide word budget in tools/budget.tsv.

Why words and not minutes: a time estimate made by someone who is not speaking
is a guess. A word count is a fact, and words / rate = minutes is arithmetic.

CALIBRATION — three measurements of Act 0 by MB, 2026-08-17, ALL SOLO:

    run 1   547 words / 185 s = 177 wpm
    run 2   700 words / 227 s = 185 wpm
    run 3   701 words / 225 s = 187 wpm   (standing, projecting)

MB's solo delivery rate is 177-187 wpm and the instrument is stable across
sessions. **No comparison between conditions exists** — an earlier version of
this file labelled runs 1 and 2 as "seated" and drew a standing-vs-seated
conclusion from it. That labelling was assumed, not reported. There is no
seated baseline.

What none of these runs can measure, because all three were alone in a room:
nerves, recovery from a stumble (MB's first attempt at this talk overran badly
on exactly that), interruptions and questions, audience reaction and the pauses
it creates, and demo overhead beyond the scripted narration. Those are the whole
justification for the discount below.

The default is 140 — the measured ~180 minus 22%, covering nerves, recovery
from a stumble, questions from the floor, and the pauses audience reaction
creates. Sweep it:

    --wpm 180   what MB produces alone; a ceiling, never a plan
    --wpm 140   default
    --wpm 130   bad night

A NOTE ON WHAT A CAP MEANS, because getting this wrong caused churn: a cap is
the AIRTIME a slide gets on the night — a design decision about pacing. It does
not move when the planning rate moves. The rate converts a written script into
airtime so the tool can say whether that script fits its slot. Raise the rate
and more words fit in the same cap; it does not buy you a longer talk.

Overrunning is unrecoverable and finishing early is not, so the discount stays
deliberately pessimistic against a number that has now been measured three times. Sweep it if you want the range: --wpm 150 is the optimistic
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
# error. An absolute rate, NOT a ratio: an earlier version scaled 70/120 by
# whatever --wpm was passed, so sweeping the prose rate silently moved the demo
# rate with it.
DEMO_WPM = 70.0


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

    # A note that is bullets-plus-fragments has no full script to count, so it
    # declares its own estimate:  EST-WORDS: 210
    # An explicit estimate always wins — it is the author saying how much they
    # will actually say, which beats any inference from quoted fragments.
    est = re.search(r"^EST-WORDS:\s*(\d+)", note, flags=re.M)
    if est:
        return int(est.group(1))

    # Otherwise: what you actually say is inside double quotes; everything else
    # in the note is delivery guidance and is not counted.
    quoted = re.findall(r'"([^"]*)"', note)
    spoken = " ".join(quoted)
    if len(spoken.split()) >= 20:
        return len(spoken.split())
    return len(note.split())


SCRIPTS = os.path.join(ROOT, "touying", "scripts")

# A script header carries `cap m:ss` so the speaker can see it while rehearsing.
# budget.tsv is the single source of truth, so the two can disagree — and on
# 18 Aug they did, by 45 seconds across Act 0, which is a third of the whole
# talk's slack licensed by a stale comment. Cheap to check, so check it.
def header_cap_drift(caps, main_slides):
    out = []
    for stem in main_slides:
        path = os.path.join(SLIDES, stem + ".typ")
        if not os.path.exists(path):
            continue
        m = re.search(r'#read\(\s*"\.\./scripts/([^"]+)"\s*\)',
                      open(path, encoding="utf-8").read())
        if not m:
            continue
        script = os.path.join(SCRIPTS, m.group(1))
        if not os.path.exists(script):
            continue
        head = open(script, encoding="utf-8").readline()
        hm = re.search(r"\bcap\s+(\d+):(\d{2})", head)
        if not hm or stem not in caps:
            continue
        declared = int(hm.group(1)) * 60 + int(hm.group(2))
        real = caps[stem][0]
        if declared != real:
            out.append((m.group(1), declared, real))
    return out


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
    ap.add_argument("--wpm", type=float, default=140.0,
                    help="planning speaking rate (default 140 — see calibration above)")
    ap.add_argument("--slot", type=float, default=45.0, help="slot in minutes")
    ap.add_argument("--verbose", action="store_true",
                    help="also list appendix slides")
    args = ap.parse_args()

    caps = budget()
    main_slides, appendix = deck_order()

    drift = header_cap_drift(caps, main_slides)

    print(f"{'slide':<26}{'words':>6}{'spoken':>9}{'cap':>8}  ")
    print("-" * 55)

    total_words = total_spoken = total_cap = 0
    planned_unwritten = 0
    over = []
    # Any budgeted slide absent from deck.typ is still planned time — stubs AND
    # the four demo slides, which are 9:15 and were previously invisible.
    for stem, (cap_s, kind) in caps.items():
        if stem not in main_slides:
            total_cap += cap_s
            planned_unwritten += cap_s
            label = "live demo" if kind == "demo" else "not written yet"
            print(f"{stem:<26}{'—':>6}{'—':>9}{fmt(cap_s):>8}  {label}")
    for stem in main_slides:
        w = spoken_words(stem)
        if w is None:
            print(f"{stem:<26}{'MISSING':>6}")
            continue
        cap_s, kind = caps.get(stem, (None, "prose"))
        if kind == "stub":
            total_cap += cap_s
            planned_unwritten += cap_s
            print(f"{stem:<26}{w:>6}{'—':>9}{fmt(cap_s):>8}  stub (v1 note present)")
            continue
        rate = DEMO_WPM if kind == "demo" else args.wpm
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
          f"({DEMO_WPM:.0f} wpm on demo slides)")
    print(f"slot                  : {fmt(args.slot * 60)}")
    slack = args.slot * 60 - total_spoken
    verdict = "within slot" if slack >= 0 else "OVER SLOT"
    print(f"prose vs slot         : {fmt(abs(slack))} "
          f"{'of slack' if slack >= 0 else 'over'}  <- {verdict}")
    if planned_unwritten:
        print(f"unwritten (planned)   : {fmt(planned_unwritten)} of the cap total "
              f"is slides that do not exist yet")
    if total_cap:
        cap_slack = args.slot * 60 - total_cap
        print(f"PLANNED total (caps)  : {fmt(total_cap)}  -> "
              f"{fmt(abs(cap_slack))} {'spare' if cap_slack >= 0 else 'OVER SLOT'}")

    if drift:
        print()
        print("script headers disagreeing with budget.tsv "
              "(budget.tsv is the source of truth):")
        for name, declared, real in drift:
            print(f"  scripts/{name:<24} header says {fmt(declared)}, "
                  f"cap is {fmt(real)}")

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
