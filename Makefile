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
SUBDIRS ?= users-guide

XML_FILES := $(wildcard *.xml)
MML_FILES := $(wildcard *.mml)
SVG_FILES := $(wildcard *.svg)

# Paths to Norm Walsh's DocBook XSL stylesheets.  
# Fetching these from the web on every run is probably dead slow, so
# make sure you have a local copy of these stylesheets installed, and
# XML catalogs set up correctly. On Debian/Ubuntu systems, this is a
# simple matter of "apt-get install docbook-xsl".
stylesheet_prefix ?= http://docbook.sourceforge.net/release/xsl/current
html_stylesheet ?= $(stylesheet_prefix)/xhtml/docbook.xsl
chunked_html_stylesheet ?= $(stylesheet_prefix)/xhtml/chunk.xsl
fo_stylesheet ?= stylesheets/fo.xsl
titlepage_stylesheet ?= $(stylesheet_prefix)/template/titlepage.xsl

all: html chunked-html

html: copy-images howto-collection.html

chunked-html: howto-collection.xml images
	mkdir -p html-multiple-pages/
	cp -r images html-multiple-pages/
	cp $(wildcard *.css) html-multiple-pages/
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) html-multiple-pages/
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.svg)) html-multiple-pages/
	xsltproc -o html-multiple-pages/ \
	--param admon.graphics 1 \
	--stringparam admon.graphics.path images/ \
	--stringparam admon.graphics.extension .png \
	--stringparam ulink.target offsite-link \
	--stringparam html.stylesheet drbd-howto-collection.css \
	--stringparam graphic.default.extension png \
	--xinclude $(chunked_html_stylesheet) $<

pdf: copy-images howto-collection.pdf

%.html: %.xml
	xsltproc -o $@ \
	--param admon.graphics 1 \
	--stringparam admon.graphics.path images/ \
	--stringparam admon.graphics.extension .png \
	--stringparam ulink.target offsite-link \
	--stringparam html.stylesheet drbd-howto-collection.css \
	--stringparam graphic.default.extension png \
	--xinclude $(html_stylesheet) $<

%.fo: %.xml stylesheets/fo-titlepage.xsl
	xsltproc -o $@ \
	--stringparam paper.type A4 \
	--stringparam title.font.family serif \
	--stringparam insert.link.page.number yes \
	--stringparam insert.xref.page.number yes \
	--stringparam graphic.default.extension svg \
	--param section.autolabel 1 \
	--param section.autolabel.max.depth 2 \
	--param section.label.includes.component.label 1 \
	--param use.extensions 1 \
	--param fop1.extensions 1 \
	--param admon.graphics 1 \
	--stringparam admon.graphics.path images/ \
	--stringparam admon.graphics.extension .svg \
	--xinclude $(fo_stylesheet) $<

%-titlepage.xsl: %-titlepage.xml
	xsltproc -o $@ \
	--xinclude $(titlepage_stylesheet) $<

%.svg: %.mml
	mathmlsvg --font-size=24 $<

%.png: %.svg
	rsvg $< $@

%-small.png: %.svg
	rsvg -x 0.5 -y 0.5 $< $@

%-large.png: %.svg
	rsvg -x 2 -y 2 $< $@

copy-images: copy-raster-images copy-vector-images

copy-raster-images: raster-images
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) .

copy-vector-images: vector-images
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.svg)) .

copy-css: 
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.css)) .

images: vector-images raster-images

raster-images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i raster-images; done

vector-images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i vector-images; done

%.pdf: %.fo
	fop $< -pdf $@

%.ps: %.fo
	fop $< -ps $@

clean-html:
	rm -f $(XML_FILES:.xml=.html) 

clean-fo:
	rm -f $(XML_FILES:.xml=.fo) 

clean-ps:
	rm -f $(XML_FILES:.xml=.ps)

clean-pdf:
	rm -f $(XML_FILES:.xml=.pdf)

clean-svg:
	rm -f $(MML_FILES:.mml=.svg) 

clean-png:
	rm -f $(SVG_FILES:.svg=.png) 
	rm -f $(SVG_FILES:.svg=-large.png) 
	rm -f $(SVG_FILES:.svg=-small.png) 

clean-xsl:
	$(MAKE) -C stylesheets clean

clean: clean-xsl clean-png clean-svg clean-html clean-fo clean-ps clean-pdf
	rm -rf html-multiple-pages/

.PHONY: all html chunked-html pdf clean-png clean-svg clean-html clean-fo clean-ps clean-pdf clean raster-images vector-images images
