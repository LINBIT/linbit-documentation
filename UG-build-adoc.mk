#
# UG-build-adoc.mk
#
# Makefile in English document should include this file and UG-build.mk
#

# Set SRC to a space separated list of all AsciiDoc files in the source directory
SRC=$(wildcard *.adoc)
SVGSUSED=$(shell sed -n -e 's/^image::\(.*\.svg\)\(.*\)/\1/p' *.adoc)
PNGSUSED=$(shell sed -n -e 's/^image::\(.*\.png\)\(.*\)/\1/p' *.adoc)

POTFILES=$(subst .adoc,.adoc.pot,$(SRC))

CLEAN_FILES = *.pot

%.adoc:
	;

pot: $(POTFILES)
