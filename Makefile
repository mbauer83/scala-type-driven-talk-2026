# Scripts are .md and are pulled in with #read(); if they are not dependencies,
# editing a script leaves talk.pdf and talk.pdfpc stale while `make check`
# still prints "build OK" — and talk.pdfpc is what pympress reads on stage.
TYPST_SOURCES := $(shell find touying \( -name '*.typ' -o -name '*.md' \))

# typst compile  — PDF, SVG, PNG, and watch (typst-native features: --input,
#                  page-pattern {0p}, --ppi, typst watch)
# touying compile — HTML and PPTX exports, and pdfpc sidecar generation.
#                   Output path uses --output (named flag), not a positional arg.

.PHONY: all talk-notes talk-svg talk-png talk-pptx talk-pptx-touying talk-html talk-presenter watch clean

all: talk.pdf talk.pdfpc

talk.pdf: $(TYPST_SOURCES)
	typst compile --root . touying/deck.typ talk.pdf

# talk.pdfpc: speaker-note sidecar read by pympress presenter view.
# Requires the pdfpc.pdfpc-file(here()) call at the end of deck.typ.
# `touying compile --format pdfpc` runs its own typst query WITHOUT --root, so
# it fails "access denied" on every slide that #read()s a file above touying/ —
# which is all six recorded demo frames. It had been failing silently since
# those landed, leaving talk.pdfpc at 0 bytes: the presenter view MB actually
# reads from, empty, and `make check` reporting build OK because the file
# existed. Use the query deck.typ has documented all along; it takes --root.
talk.pdfpc: $(TYPST_SOURCES)
	typst query --root . touying/deck.typ "<pdfpc-file>" --field value --one > talk.pdfpc

# talk-presenter: two-window browser presenter that survives this deck.
# One flat PNG per slide as <img>, no impress.js, no iframes; the audience and
# presenter windows are two real windows synced over postMessage (cross-origin
# safe, so it works from file:// too). Verified in Chromium to slide 33 with
# both windows painting and sync working in both directions — the point where
# touying's own console has been grey since about slide 13.
#   make talk-presenter  ->  open presenter/index.html, press P
talk-presenter: talk.pdfpc
	python3 tools/make-presenter.py

talk-notes: $(TYPST_SOURCES)
	typst compile --root . touying/deck.typ --input notes=true talk-with-notes.pdf

talk-svg: $(TYPST_SOURCES)
	mkdir -p slides/svg
	typst compile --root . touying/deck.typ "slides/svg/slide-{0p}.svg"

talk-png: $(TYPST_SOURCES)
	mkdir -p slides/png
	typst compile --root . touying/deck.typ "slides/png/slide-{0p}.png" --format png --ppi 144

# --root . for the same reason talk.pdfpc needs it: nine slides #read() files
# above touying/ (the recorded demo frames) and the title/close slides read the
# QR asset. Without it these fail "access denied" — which they had been doing
# silently since the demo frames landed.

# talk-pptx: PowerPoint with the speaker notes as REAL TEXT in the notes pane,
# which is what Windows presenter view needs. touying's own pptx export carries
# slide images and NO notes, so its presenter view has nothing to show — see
# tools/make-pptx.py for why the slides are images either way.
# Needs talk.pdfpc, so it depends on it.
talk-pptx: talk.pdfpc
	python3 tools/make-pptx.py

# The images-only export touying produces, kept for comparison. Not for use.
talk-pptx-touying: $(TYPST_SOURCES)
	touying compile --root . touying/deck.typ --format pptx --output talk-nonotes.pptx

talk-html: $(TYPST_SOURCES)
	touying compile --root . touying/deck.typ --format html --output talk.html

watch:
	typst watch --root . touying/deck.typ talk.pdf

# serve: view the HTML deck over http rather than as a file.
#
# It does NOT fix the presenter console. An earlier version of this comment
# blamed file:// opaque origins; that was wrong, and the failure was reproduced
# over http in headless Chromium on 19 Aug: at step 13 both console frames paint
# grey while the DOM underneath is correct (right step, SVG present) and the
# notes pane still updates. So it is a compositing failure, not a scripting one.
#
# The cause is the export meeting this deck. touying's html is impress.js: one
# 10.3 MB document with 49 inline SVGs, and the presenter holds THREE live
# copies (main + slideView + preView) on 3D-transformed containers — ~31 MB of
# composited DOM. Past ~a dozen steps the compositor drops the layers.
#
# Not fixable from here. Use talk.pptx in LibreOffice Impress or PowerPoint.
#   make serve   ->  http://localhost:8000/talk.html   (slides only; P is broken)
.PHONY: serve
serve: talk.html
	@echo "http://localhost:8000/talk.html   — press P for the presenter console"
	@python3 -m http.server 8000 --bind 127.0.0.1

clean:
	rm -f talk.pdf talk-with-notes.pdf talk.pdfpc talk.pptx talk-nonotes.pptx talk.html
	rm -rf presenter/
	rm -f slides/svg/*.svg slides/png/*.png

# talk-timing: measure speaker notes as speaking time against tools/budget.tsv.
# Calibrate WPM against a real read-through: read Act 0 aloud, time it, divide.
WPM ?= 140   # calibrated: ~180 wpm solo, minus 22% for nerves, interruptions, audience
.PHONY: timing
timing:
	python3 tools/talk-timing.py --wpm $(WPM)

# check: everything that can be verified without you reading aloud.
# Run this after editing any script in touying/scripts/.
.PHONY: check
# The timing number must always be reachable. Draft 5's version chained the
# lint in front of it, so 15 inherited v1 register errors made `make timing`
# unreachable through the documented command — the instrument that decides the
# budget, blocked by a complaint about sentence rhythm.
check: talk.pdf talk.pdfpc
	@echo "build      OK"
	@python3 tools/talk-timing.py --wpm $(WPM) || true
	@echo
	@python3 tools/prose-lint.py --all || echo "prose      advisory failures above (not blocking)"

# lint: blocking, for the slides that carry an authored script.
.PHONY: lint
lint:
	python3 tools/prose-lint.py --all
