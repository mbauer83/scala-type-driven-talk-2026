TYPST_SOURCES := $(shell find touying -name '*.typ')

.PHONY: all talk-notes talk-svg talk-png watch clean

all: talk.pdf

talk.pdf: $(TYPST_SOURCES)
	typst compile touying/deck.typ talk.pdf

talk-notes: $(TYPST_SOURCES)
	typst compile touying/deck.typ --input notes=true talk-with-notes.pdf

talk-svg: $(TYPST_SOURCES)
	mkdir -p slides/svg
	typst compile touying/deck.typ "slides/svg/slide-{0p}.svg"

talk-png: $(TYPST_SOURCES)
	mkdir -p slides/png
	typst compile touying/deck.typ "slides/png/slide-{0p}.png" --format png --ppi 144

watch:
	typst watch touying/deck.typ talk.pdf

clean:
	rm -f talk.pdf talk-with-notes.pdf
	rm -f slides/svg/*.svg slides/png/*.png
