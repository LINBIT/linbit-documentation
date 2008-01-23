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

html: copy-images howto-collection.html

chunked-html: howto-collection.xml images
	mkdir -p html-multiple-pages/
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) html-multiple-pages/
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.svg)) html-multiple-pages/
	xsltproc -o html-multiple-pages/ --xinclude $(chunked_html_stylesheet) $<

pdf: copy-images howto-collection.pdf

valid: *.xml
	xmllint --noout --valid --xinclude *.xml

%.html: %.xml
	xsltproc -o $@ --xinclude $(html_stylesheet) $<

%.fo: %.xml
	xsltproc -o $@ --stringparam paper.type A4 \
	--stringparam title.font.family serif \
	--stringparam insert.link.page.number yes \
	--stringparam insert.xref.page.number yes \
	--param fop1.extensions 1 \
	--param use.extensions 1 \
	--xinclude $(fo_stylesheet) $<

%.svg: %.mml
	mathmlsvg --font-size=24 $<

%.png: %.svg
	rsvg $< $@

copy-images: copy-raster-images copy-vector-images

copy-raster-images: raster-images
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) .

copy-vector-images: vector-images
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.svg)) .

images: vector-images raster-images

raster-images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i raster-images; done

vector-images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i vector-images; done

%.pdf: %.fo
	fop $< -pdf $@

%.ps: %.fo
	fop $< -ps $@

clean:
	rm -rf html-multiple-pages/
	rm -f *.fo
	rm -f *.html
	rm -f *.pdf
	rm -f *.ps
	rm -f *.png

.PHONY: all html chunked-html pdf clean raster-images vector-images images
