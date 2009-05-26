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
PROFILING_HTML_STYLESHEET ?= $(STYLESHEET_PREFIX)/xhtml/profile-docbook.xsl
CHUNKED_HTML_STYLESHEET ?= $(STYLESHEET_PREFIX)/xhtml/chunk.xsl
CHUNKED_PROFILING_HTML_STYLESHEET ?= $(STYLESHEET_PREFIX)/xhtml/profile-chunk.xsl
TITLEPAGE_STYLESHEET ?= $(STYLESHEET_PREFIX)/template/titlepage.xsl

# For HTML output, define the name of the frame where 
# <ulink> URLs should open
ULINK_TARGET ?= offsite-link

# Set profiling options if set in environment.
ifneq ($(ARCH),)
XSLTPROC_PROFILING_OPTIONS += --stringparam profile.arch $(ARCH)
endif
ifneq ($(CONDITION),)
XSLTPROC_PROFILING_OPTIONS += --stringparam profile.condition $(CONDITION)
endif
ifneq ($(USERLEVEL),)
XSLTPROC_PROFILING_OPTIONS += --stringparam profile.userlevel $(USERLEVEL)
endif
ifneq ($(VENDOR),)
XSLTPROC_PROFILING_OPTIONS += --stringparam profile.vendor $(VENDOR)
endif
# For "status", use a slightly different logic. Unless set otherwise,
# always assume "current".
STATUS ?= current
XSLTPROC_PROFILING_OPTIONS += --stringparam profile.status $(STATUS)

# xsltproc options for HTML output
XSLTPROC_HTML_OPTIONS ?= --xinclude \
 $(XSLTPROC_PROFILING_OPTIONS) \
 --param use.id.as.filename 1 \
 --param generate.index 0 \
 --param admon.graphics 1 \
 --stringparam admon.graphics.path images/ \
 --stringparam admon.graphics.extension .png \
 --stringparam ulink.target $(ULINK_TARGET) \
 --stringparam html.stylesheet drbd-howto-collection.css \
 --stringparam graphic.default.extension png

all: html

clean:
	@ $(MAKE) -C manpages clean
	@ $(MAKE) -C users-guide clean

html: manpages
	@ $(MAKE) -C users-guide html

# Multiple-page HTML
%.html: %.xml
	xsltproc \
	$(XSLTPROC_HTML_OPTIONS) \
	--stringparam root.filename $* \
	$(CHUNKED_PROFILING_HTML_STYLESHEET) $< 

# Generated images: SVG from MathML
# (needed for HTML output, and PDF if using FOP)
# The ugly sed hack is because batik (used by FOP) complains about
# 'svg version="1"', while 'svg version="1.0"' is OK.
%.svg: %.mml
	mathmlsvg --font-size=24 $< 
	sed -i -e 's/<svg version="1"/<svg version="1.0"/' $@

# Generated images: PNG from SVG
# (needed for HTML output)
%.png: %.svg
	rsvg $< $@

%-small.png: %.svg
	rsvg -x 0.5 -y 0.5 $< $@

%-large.png: %.svg
	rsvg -x 2 -y 2 $< $@

builddate: clean-builddate
	env LC_ALL=C date +"%B %d, %Y" > $@	

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
	rm -f $(MML_FILES:.mml=.png) 

clean-tempfiles:
	rm -f *~

clean-builddate:
	rm -f builddate

.PHONY: all html manpages chunked-html clean-png clean-svg clean-html clean raster-images vector-images images
