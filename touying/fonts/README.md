# Vendored fonts

Every face the deck renders with, committed so a build does not depend on what
happens to be installed on the machine that runs it.

The build passes `--font-path touying/fonts --ignore-system-fonts` — see
`TYPST_FONTS` in the `Makefile` and `FONT_ARGS` in `tools/make-pptx.py` and
`tools/make-presenter.py`. Keep those three in step.

| family | role | upstream |
|---|---|---|
| IBM Plex Sans | body | github.com/IBM/plex |
| JetBrains Mono | code and labels | github.com/JetBrains/JetBrainsMono |
| Inter | body fallback | github.com/rsms/inter |
| Libertinus Sans | body fallback | github.com/alerque/libertinus |

DejaVu Sans Mono and the New Computer Modern maths faces ship inside typst
itself, so they are not vendored.

All four families are licensed under the SIL Open Font License 1.1, which
permits redistribution; the licence texts are in this directory.
