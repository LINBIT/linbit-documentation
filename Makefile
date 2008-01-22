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

# Paths to Norm Walsh's DocBook XSL stylesheets. 
# FIXME: These paths are likely to work only on Debian or Ubuntu
# systems.
stylesheet_prefix ?= /usr/share/xml/docbook/stylesheet/nwalsh
html_stylesheet ?= $(stylesheet_prefix)/xhtml/docbook.xsl
chunked_html_stylesheet ?= $(stylesheet_prefix)/xhtml/chunk.xsl
fo_stylesheet ?= $(stylesheet_prefix)/fo/docbook.xsl

all: html chunked-html

html: howto-collection.html

chunked-html: howto-collection.xml
	xsltproc -o html-multiple-pages/ --xinclude $(chunked_html_stylesheet) $<

pdf: howto-collection.pdf

valid: *.xml
	xmllint --noout --valid --xinclude *.xml

%.html: %.xml
	xsltproc -o $@ --xinclude $(html_stylesheet) $<

%.fo: %.xml
	xsltproc -o $@ --stringparam paper.type A4 --xinclude $(fo_stylesheet) $<

%.dep: %.xml
	xsltproc -o $@ --stringparam top $< depend.xsl $<

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

.PHONY: all html chunked-html pdf clean
