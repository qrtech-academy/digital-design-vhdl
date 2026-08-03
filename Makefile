SHELL := /bin/bash

# Absolute path to this Makefile's directory, so the targets work from anywhere.
ROOT := $(dir $(firstword $(MAKEFILE_LIST)))

PYTHON := $(ROOT).venv/bin/python

.DEFAULT_GOAL := help
.PHONY: help build test lint links duplicates diagrams format-vhdl format-vhdl-check clean

help: ## Show this help.
	@echo "Targets:"
	@grep -hE '^[a-z-]+:.*##' $(MAKEFILE_LIST) \
	  | sed -e 's/:.*## / /' -e 's/^/  /' \
	  | awk '{ printf "  %-18s %s\n", $$1, substr($$0, index($$0, $$2)) }'
	@echo
	@echo "Build one example instead of all of them:"
	@echo "  make build MODULE=fsm_led"

build: ## Analyze, elaborate, and simulate every example. Optional: MODULE=<name>
	$(ROOT)ci/build.sh $(MODULE)

test: build ## Alias for build: building an example also runs its testbench.

# Mirrors the CI lint job exactly, so a green "make lint" locally means a green lint in CI.
lint: duplicates links format-vhdl-check ## Run every non-simulation check.

duplicates: ## Check that vendored copies of shared modules are still identical.
	$(ROOT)ci/duplicates.sh

links: ## Check that every relative link in the Markdown resolves.
	$(ROOT)ci/links.sh

# Deliberately not part of build or lint: the generated PNGs are committed, and redrawing them
# needs a Python environment this repo does not otherwise require. CI has its own, in a separate
# job that redraws every figure and diffs it. See diagrams/README.md for the one-time venv setup.
diagrams: ## Redraw the generated lecture figures. Optional: FIGURE=<name>
	@test -x $(PYTHON) || { \
	  echo "No Python environment at $(PYTHON). Create it once with:"; \
	  echo "  python3 -m venv .venv"; \
	  echo "  .venv/bin/pip install -r diagrams/requirements.txt"; \
	  exit 1; }
	$(PYTHON) $(ROOT)diagrams/build.py $(FIGURE)

format-vhdl: ## Strip trailing whitespace from the VHDL sources in place.
	$(ROOT)ci/format_vhdl.sh

format-vhdl-check: ## Fail if any VHDL source has trailing whitespace.
	$(ROOT)ci/format_vhdl.sh --check

clean: ## Remove GHDL work libraries, waveforms, and other generated files.
	$(ROOT)ci/clean.sh
