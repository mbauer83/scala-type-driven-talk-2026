TYPST_SOURCES := $(shell find touying -name '*.typ')

# typst compile  — PDF, SVG, PNG, and watch (typst-native features: --input,
#                  page-pattern {0p}, --ppi, typst watch)
# touying compile — HTML and PPTX exports, and pdfpc sidecar generation.
#                   Output path uses --output (named flag), not a positional arg.

.PHONY: all talk-notes talk-svg talk-png watch clean

all: talk.pdf talk.pdfpc

talk.pdf: $(TYPST_SOURCES)
	typst compile touying/deck.typ talk.pdf

# talk.pdfpc: speaker-note sidecar read by pympress presenter view.
# Requires the pdfpc.pdfpc-file(here()) call at the end of deck.typ.
talk.pdfpc: $(TYPST_SOURCES)
	touying compile touying/deck.typ --format pdfpc --output talk.pdfpc

talk-notes: $(TYPST_SOURCES)
	typst compile touying/deck.typ --input notes=true talk-with-notes.pdf

talk-svg: $(TYPST_SOURCES)
	mkdir -p slides/svg
	typst compile touying/deck.typ "slides/svg/slide-{0p}.svg"

talk-png: $(TYPST_SOURCES)
	mkdir -p slides/png
	typst compile touying/deck.typ "slides/png/slide-{0p}.png" --format png --ppi 144

talk-pptx: $(TYPST_SOURCES)
	touying compile touying/deck.typ --format pptx --output talk.pptx

talk-html: $(TYPST_SOURCES)
	touying compile touying/deck.typ --format html --output talk.html

watch:
	typst watch touying/deck.typ talk.pdf

clean:
	rm -f talk.pdf talk-with-notes.pdf talk.pdfpc
	rm -f slides/svg/*.svg slides/png/*.png

# talk-timing: measure speaker notes as speaking time against tools/budget.tsv.
# Calibrate WPM against a real read-through: read Act 0 aloud, time it, divide.
WPM ?= 130   # calibrated: MB reads at 177-185; 130 is that minus ~28% for live delivery
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
