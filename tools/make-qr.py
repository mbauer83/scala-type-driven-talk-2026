#!/usr/bin/env python3
"""Regenerate the title slide's repo QR.

The URL lives here and nowhere else. Error level Q (25% recovery) because a
projector loses contrast and people scan from the back of the room; the plate is
white because an inverted QR is not reliably scannable.

    pip install segno && python3 tools/make-qr.py
"""
import os
import segno

URL = "https://github.com/mbauer83/type-driven-programming-talk-2026"
OUT = os.path.join(os.path.dirname(__file__), "..", "touying", "assets", "repo-qr.svg")

q = segno.make(URL, error="q")
q.save(OUT, scale=10, border=3, dark="#12151c", light="#ffffff")
print(f"{URL}\n  -> {os.path.normpath(OUT)}  (version {q.version}, {q.symbol_size(scale=1)[0]} modules)")
