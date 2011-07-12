# Some useful wildcard expansions
SVG_FILES ?= $(wildcard *.svg)

if RENDER_SVG
.PHONY: png
png: $(SVG_FILES:.svg=.png)
endif

%: force
	@$(MAKE) -f $(top_srcdir)/Makefile $@

force: ;
