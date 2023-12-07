#
# UG-build-po.mk
#
# Makefile in localized document directory should include this file and UG-build.mk
#

SRC=$(shell ls ../en/*.adoc|sed -e 's;../en/;;')

SVGSUSED=$(shell sed -n -e 's/^image::\(.*\.svg\)\(.*\)/\1/p' ../en/*.adoc)
PNGSUSED=$(shell sed -n -e 's/^image::\(.*\.png\)\(.*\)/\1/p' ../en/*.adoc)

CLEAN_FILES = *.adoc

#
# drbd-users-guide.adoc needs to be patched to add localized strings.
#

patch-drbd-ug:
	patch -p0 < drbd-users-guide.adoc-$(lang).patch
