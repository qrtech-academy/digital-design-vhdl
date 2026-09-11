# Build the book: vector figures from diagrams/, then two LuaLaTeX passes for the references.
#
#   make                   build digital-design-vhdl.pdf, dated today
#   make VERSION=v1.1.0    the same, with the release's version on the title page
#   make figures           render the figures only, into build/figures
#   make clean             remove everything the build writes
#
# The worked examples printed in full are typeset straight from their files under lectures/, and
# the figures straight from diagrams/, so a change to either is a change to the book on the next
# build.

ROOT    := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
BOOK    := $(ROOT)/book
BUILD   := $(BOOK)/build
PYTHON  ?= $(ROOT)/.venv/bin/python
VERSION ?=
LATEX   := lualatex -interaction=nonstopmode -halt-on-error -file-line-error \
           -output-directory=$(BUILD)
# The book, with its version defined before anything is read; -jobname keeps the output book.pdf.
BOOKTEX := $(LATEX) -jobname=book '\def\bookversion{$(VERSION)}\input{book.tex}'

SOURCES := book.tex vhdlbook.sty vhdlbook.lua \
           $(wildcard front/*.tex chapters/*/*.tex back/*.tex back/*/*.tex)
CODE    := $(shell cd $(ROOT) && git ls-files 'lectures/*.vhd' 'lectures/*.png' | sed 's|^|$(ROOT)/|')
# Every figure diagrams/build.py knows, in one run: forty-odd PDFs take a few seconds, and the
# builders import each other, so any change to diagrams/ redraws the lot.
FIGSTAMP := $(BUILD)/figures/.stamp

.PHONY: all figures clean FORCE

all: digital-design-vhdl.pdf

figures: $(FIGSTAMP)

$(FIGSTAMP): figures.py $(wildcard $(ROOT)/diagrams/*.py)
	@test -x $(PYTHON) || { \
	  echo "No Python environment at $(PYTHON). Create it once with:"; \
	  echo "  python3 -m venv .venv"; \
	  echo "  .venv/bin/pip install -r diagrams/requirements.txt"; \
	  exit 1; }
	$(PYTHON) figures.py $(BUILD)/figures
	@touch $@

# The version the last build was made for. The file is rewritten only when VERSION changes, so a
# new version, or none after one, rebuilds the title page and nothing else does.
$(BUILD)/version: FORCE
	@mkdir -p $(BUILD)
	@echo '$(VERSION)' | cmp -s - $@ || echo '$(VERSION)' > $@

digital-design-vhdl.pdf: $(SOURCES) $(CODE) $(FIGSTAMP) $(BUILD)/version
	@mkdir -p $(BUILD)
	cd $(BOOK) && $(BOOKTEX) >/dev/null || (tail -40 $(BUILD)/book.log; exit 1)
	cd $(BOOK) && $(BOOKTEX) >/dev/null || (tail -40 $(BUILD)/book.log; exit 1)
	@grep -E "^(Overfull|Underfull)|Warning" $(BUILD)/book.log | sort | uniq -c | sort -rn | head -20 || true
	@! grep -q "There were undefined references" $(BUILD)/book.log || \
	    (echo "error: undefined references; see $(BUILD)/book.log"; exit 1)
	cp $(BUILD)/book.pdf $@

clean:
	rm -rf $(BUILD) digital-design-vhdl.pdf
