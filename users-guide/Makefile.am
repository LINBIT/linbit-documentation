# Some useful wildcard expansions
TXT_FILES ?= $(wildcard *.txt)
MML_FILES ?= $(wildcard *.mml images/*.mml)
SVG_FILES ?= $(wildcard *.svg images/*.svg)

all: html pdf

html: $(TXT_FILES) $(MML_FILES:.mml=.svg) $(SVG_FILES:.svg=.png) drbd-users-guide.html

pdf: $(TXT_FILES) $(MML_FILES:.mml=.svg) drbd-users-guide.pdf

%:
	@$(MAKE) -f $(top_srcdir)/Makefile $@
