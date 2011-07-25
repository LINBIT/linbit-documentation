# Some useful wildcard expansions
TXT_FILES ?= $(wildcard *.txt)
MML_FILES ?= $(wildcard *.mml)
SVG_FILES ?= $(wildcard *.svg)

all: html pdf

html: $(TXT_FILES) $(MML_FILES:.mml=.svg) $(SVG_FILES:.svg=.png)

pdf: $(TXT_FILES) $(MML_FILES:.mml=.svg)

force: ;

%: force
	@$(MAKE) -f $(top_srcdir)/Makefile $@
