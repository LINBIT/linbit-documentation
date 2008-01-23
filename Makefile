#
# DRBD howto collection Makefile
#
# This is the top-level Makefile. When creating a subdirectory for a
# new howto, create a new Makefile in that directory, referring back
# to this one. Like so:
#
# %: force
# 	@$(MAKE) -f ../Makefile $@
# force: ;
#
# That target should go after all other targets you define in your
# lower-level Makefile. Refer the Makefile in the "users-guide"
# subdirectory as an example.

# Path to the DRBD source tree
DRBD ?= ../drbd-8

# Sub-directories to descend into if doing recursive make
SUBDIRS ?= users-guide developers-guide

# Paths to Norm Walsh's DocBook XSL stylesheets.  
# Fetching these from the web on every run is probably dead slow, so
# make sure you have a local copy of these stylesheets installed, and
# XML catalogs set up correctly. On Debian/Ubuntu systems, this is a
# simple matter of "apt-get install docbook-xsl".
stylesheet_prefix ?= http://docbook.sourceforge.net/release/xsl/current
html_stylesheet ?= $(stylesheet_prefix)/xhtml/docbook.xsl
chunked_html_stylesheet ?= $(stylesheet_prefix)/xhtml/chunk.xsl
fo_stylesheet ?= $(stylesheet_prefix)/fo/docbook.xsl

all: html chunked-html

html: howto-collection.html copy-images

chunked-html: howto-collection.xml images
	mkdir -p html-multiple-pages/
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) html-multiple-pages/
	xsltproc -o html-multiple-pages/ --xinclude $(chunked_html_stylesheet) $<

pdf: howto-collection.pdf copy-images

valid: *.xml
	xmllint --noout --valid --xinclude *.xml

%.html: %.xml
	xsltproc -o $@ --xinclude $(html_stylesheet) $<

%.fo: %.xml
	xsltproc -o $@ --stringparam paper.type A4 --xinclude $(fo_stylesheet) $<

%.svg: %.mml
	mathmlsvg --font-size=24 $<

%.png: %.svg
	rsvg $< $@

copy-images: images
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) .

images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i images; done

# PDF and PostScript rendering depends on xmlroff, which is not (yet)
# included in Debian stable nor a released Ubuntu version. For now,
# build from source, get the lenny/sid package, or wait for Ubuntu
# Hardy. :-)
%.pdf: %.fo
	xmlroff -o $@ --format=pdf $<

%.ps: %.fo
	xmlroff -o $@ --format=postscript $<

clean:
	rm -rf html-multiple-pages/
	rm -f *.fo
	rm -f *.html
	rm -f *.pdf
	rm -f *.ps
	rm -f *.png

.PHONY: all html chunked-html pdf clean
