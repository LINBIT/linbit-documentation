#
# UG-build-adoc.mk
#
# Makefile in English document should include this file and UG-build.mk
#

SRC=$(wildcard *.adoc)
SVGSUSED=$(shell sed -n -e 's/^image::\(.*\.svg\)\(.*\)/\1/p' *.adoc)
PNGSUSED=$(shell sed -n -e 's/^image::\(.*\.png\)\(.*\)/\1/p' *.adoc)

POTFILES=$(subst .adoc,.pot,$(SRC))

CLEAN_FILES = *.pot

%.adoc:
	;

%.pot: %.adoc
	po4a-gettextize -f asciidoc -M utf-8 -m $< -p $@

pot: $(POTFILES)
