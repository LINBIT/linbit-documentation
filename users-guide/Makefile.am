# Some useful wildcard expansions
TXT_FILES ?= $(wildcard *.txt)
MML_FILES ?= $(wildcard *.mml images/*.mml)
SVG_FILES ?= $(wildcard *.svg images/*.svg)

all: html pdf

# docbook requires a non-digit as first character of its "xml:id"s;
# remove the "_" that is needed eg. for "64K-striping".
html: $(TXT_FILES) $(MML_FILES:.mml=.svg) $(SVG_FILES:.svg=.png) drbd-users-guide.html
	perl -i.bak -pe 's/(<a id=")_(\d)/$$1$$2/g' output/re-drbdconf.html

pdf: $(TXT_FILES) $(MML_FILES:.mml=.svg) drbd-users-guide.pdf

%:
	@$(MAKE) -f $(top_srcdir)/Makefile $@
