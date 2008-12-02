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
DISTDIR ?= dist

# Path to the DRBD source tree
DRBD ?= $(abspath ../drbd-8)

# Some useful wildcard expansions
XML_FILES := $(wildcard *.xml)
HTML_FILES := $(wildcard *.html)
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

TITLEPAGE_STYLESHEET ?= $(STYLESHEET_PREFIX)/template/titlepage.xsl

all: html

clean:
	@ $(MAKE) -C manpages clean
	@ $(MAKE) -C users-guide clean

html: manpages
	@ $(MAKE) -C users-guide html

# Multiple-page HTML
%.html: %.xml
	xsltproc \
	--param use.id.as.filename 1 \
	--param generate.index 0 \
	--param admon.graphics 1 \
	--stringparam admon.graphics.path images/ \
	--stringparam admon.graphics.extension .png \
	--stringparam ulink.target offsite-link \
	--stringparam html.stylesheet drbd-howto-collection.css \
	--stringparam graphic.default.extension png \
	--stringparam root.filename $* \
	--xinclude \
	$(CHUNKED_HTML_STYLESHEET) $< 

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

manpages:
	@ set -e; $(MAKE) -C manpages

# Cleanup targets
clean-html:
	rm -f $(HTML_FILES)

clean-svg:
	rm -f $(MML_FILES:.mml=.svg) 

clean-png:
	rm -f $(SVG_FILES:.svg=.png) 
	rm -f $(SVG_FILES:.svg=-large.png) 
	rm -f $(SVG_FILES:.svg=-small.png) 

clean-tempfiles:
	rm -f *~

.PHONY: all html manpages chunked-html clean-png clean-svg clean-html clean raster-images vector-images images
