#
# UG-build-po.mk
#
# Makefile in localized document should include this file and UG-build.mk
#

SRC=$(shell ls ../en/*.adoc|sed -e 's;../en/;;')

SVGSUSED=$(shell sed -n -e 's/^image::\(.*\.svg\)\(.*\)/\1/p' ../en/*.adoc)
PNGSUSED=$(shell sed -n -e 's/^image::\(.*\.png\)\(.*\)/\1/p' ../en/*.adoc)

CLEAN_FILES = *.adoc

#
# drbd-users-guide.adoc needs to be patched to add localized strings.
#
drbd-users-guide.adoc: drbd-users-guide.po
	po4a-translate -f asciidoc -M utf-8 -L utf-8 --keep 0 -m ../en/$@ -p $< -l $@
	patch -p0 < drbd-users-guide.adoc-$(lang).patch

#
# Create .adoc from .po.
# If .po file is not found (new file), it will be created by English adoc file.
#
%.adoc: %.po
	po4a-translate -f asciidoc -M utf-8 -L utf-8 --keep 0 -m ../en/$@ -p $< -l $@

%.po:
	po4a-gettextize -f asciidoc -M utf-8 -m ../en/$*.adoc -p $@
