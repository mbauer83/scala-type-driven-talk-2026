#!/usr/bin/env python3
"""Build talk.pptx with the speaker notes as REAL TEXT in the notes pane.

Why this exists
---------------
pympress and pdfpc live in WSL2 and are not usable for presenting on Windows.
`touying compile --format pptx` produces slide images and **no notes at all**,
so PowerPoint's presenter view has nothing to show — which is the whole point of
using it. This script renders the same pages and puts each slide's script into
the PPTX notes field, so on Windows you get presenter view, notes, timer and the
next-slide thumbnail with no WSL involved.

Why the slides are still images
-------------------------------
There is no lossless Typst-to-OOXML path. Typst has no vector export to the
PowerPoint shape model, and PDF-to-PPTX converters reconstruct text as hundreds
of positioned boxes — which loses the two custom fonts, the code-pane tints and
the absolute layout, and would need all 49 slides re-checked by eye. The slides
are not meant to be edited in PowerPoint; the Typst source is the truth. What
has to survive the trip is the NOTES, and those are real text here.

Rendered at 192 ppi (2560x1440) so a 4K projector still gets clean type.

    python3 tools/make-pptx.py [--ppi 192] [--full-notes] [--output talk.pptx]

--full-notes keeps the PREPARATION block. The default drops it: every script
marks that block "not for the night", and PowerPoint's notes pane is small
enough that it would bury the script under its own commentary.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
DECK = os.path.join("touying", "deck.typ")
PDFPC = os.path.join(ROOT, "talk.pdfpc")

# Scripts are TALKING POINTS -> VERBATIM -> PREPARATION, separated by a rule of
# '=' characters. PREPARATION is explicitly not for the night.
PREP_RULE = re.compile(r"^={20,}\s*$", re.M)


def notes_for_pages():
    """Speaker notes, one per page, from the pdfpc sidecar — one source of truth."""
    if not os.path.exists(PDFPC):
        sys.exit("talk.pdfpc not found — run `make all` first.")
    with open(PDFPC, encoding="utf-8") as fh:
        return [p.get("note") or "" for p in json.load(fh)["pages"]]


def trim(note, keep_prep):
    if keep_prep:
        return note.strip()
    return PREP_RULE.split(note, maxsplit=1)[0].strip()


def render(ppi, outdir):
    """One PNG per page. --root . because slides #read() files above touying/."""
    pattern = os.path.join(outdir, "slide-{0p}.png")
    subprocess.run(
        ["typst", "compile", "--root", ".", DECK, pattern, "--format", "png", "--ppi", str(ppi)],
        cwd=ROOT, check=True,
    )
    return sorted(
        os.path.join(outdir, f) for f in os.listdir(outdir) if f.endswith(".png")
    )


def build(images, notes, output):
    from pptx import Presentation
    from pptx.util import Inches

    prs = Presentation()
    prs.slide_width = Inches(13.333)          # 16:9, the deck's aspect
    prs.slide_height = Inches(7.5)
    blank = prs.slide_layouts[6]              # no placeholders to fight with

    for i, image in enumerate(images):
        slide = prs.slides.add_slide(blank)
        slide.shapes.add_picture(image, 0, 0, prs.slide_width, prs.slide_height)
        note = notes[i] if i < len(notes) else ""
        if note:
            slide.notes_slide.notes_text_frame.text = note

    prs.save(output)
    return len(images)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ppi", type=int, default=192)
    ap.add_argument("--full-notes", action="store_true")
    ap.add_argument("--output", default=os.path.join(ROOT, "talk.pptx"))
    args = ap.parse_args()

    notes = [trim(n, args.full_notes) for n in notes_for_pages()]
    tmp = tempfile.mkdtemp(prefix="talk-pptx-")
    try:
        images = render(args.ppi, tmp)
        if len(images) != len(notes):
            print(f"warning: {len(images)} pages rendered, {len(notes)} notes in talk.pdfpc",
                  file=sys.stderr)
        n = build(images, notes, args.output)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    with_notes = sum(1 for x in notes if x)
    size = os.path.getsize(args.output) / 1e6
    print(f"{args.output}: {n} slides, {with_notes} with notes, {size:.0f} MB, {args.ppi} ppi")


if __name__ == "__main__":
    main()
