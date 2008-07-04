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

TOPDIR ?= $(PWD)

# Path to the DRBD source tree
DRBD ?= ../drbd-8

# Sub-directories to descend into if doing recursive make
SUBDIRS ?= users-guide images

# Some useful wildcard expansions
XML_FILES := $(wildcard *.xml)
MML_FILES := $(wildcard *.mml)
SVG_FILES := $(wildcard *.svg)

# Paths to Norm Walsh's DocBook XSL stylesheets.  
# Fetching these from the web on every run is probably dead slow, so
# make sure you have a local copy of these stylesheets installed, and
# XML catalogs set up correctly. On Debian/Ubuntu systems, this is a
# simple matter of "apt-get install docbook-xsl".
STYLESHEET_PREFIX ?= http://docbook.sourceforge.net/release/xsl/current
HTML_STYLESHEET ?= $(STYLESHEET_PREFIX)/xhtml/docbook.xsl
CHUNKED_HTML_STYLESHEET ?= $(STYLESHEET_PREFIX)/xhtml/chunk.xsl

# The subdirectory to use for "chunked" (multiple page) HTML output.
CHUNKED_HTML_SUBDIR ?= html/

TITLEPAGE_STYLESHEET ?= $(STYLESHEET_PREFIX)/template/titlepage.xsl

all: html

# Multiple-page HTML
html: howto-collection.xml images
	mkdir -p $(CHUNKED_HTML_SUBDIR)
	cp -r images $(CHUNKED_HTML_SUBDIR)
	cp $(wildcard *.css) $(CHUNKED_HTML_SUBDIR)
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.png)) $(CHUNKED_HTML_SUBDIR)
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.svg)) $(CHUNKED_HTML_SUBDIR)
	xsltproc \
	--param generate.index 0 \
	--param admon.graphics 1 \
	--param use.id.as.filename 1 \
	--stringparam admon.graphics.path images/ \
	--stringparam admon.graphics.extension .png \
	--stringparam ulink.target offsite-link \
	--stringparam html.stylesheet drbd-howto-collection.css \
	--stringparam graphic.default.extension png \
	--stringparam rootid users-guide \
	--stringparam base.dir $(CHUNKED_HTML_SUBDIR) \
	--xinclude $(CHUNKED_HTML_STYLESHEET) $(TOPDIR)/howto-collection.xml

# Single-page HTML
%.html: 
	xsltproc -o $@ \
	--param generate.index 0 \
	--param admon.graphics 1 \
	--stringparam admon.graphics.path images/ \
	--stringparam admon.graphics.extension .png \
	--stringparam ulink.target offsite-link \
	--stringparam html.stylesheet drbd-howto-collection.css \
	--stringparam graphic.default.extension png \
	--stringparam rootid $* \
	--xinclude $(HTML_STYLESHEET) $(TOPDIR)/howto-collection.xml

# Generated images: SVG from MathML
# (needed for HTML output, and PDF if using FOP)
%.svg: %.mml
	mathmlsvg --font-size=24 $< || echo "Warning: failed to generate $@ from $<, skipping this formula."

# Generated images: PNG from SVG
# (needed for HTML output)
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

images: vector-images raster-images

raster-images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i raster-images; done

vector-images:
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i vector-images; done

copy-css: 
	cp $(foreach dir,$(SUBDIRS),$(wildcard $(dir)/*.css)) .

# Cleanup targets
clean-html:
	rm -f $(XML_FILES:.xml=.html) 

clean-svg:
	rm -f $(MML_FILES:.mml=.svg) 

clean-png:
	rm -f $(SVG_FILES:.svg=.png) 
	rm -f $(SVG_FILES:.svg=-large.png) 
	rm -f $(SVG_FILES:.svg=-small.png) 

clean: 
	@ set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i clean; done
	rm -rf $(CHUNKED_HTML_SUBDIR)

.PHONY: all html chunked-html clean-png clean-svg clean-html clean raster-images vector-images images
