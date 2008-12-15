DRBD ?= ../../drbd-8

SGML_SOURCES := drbd.sgml drbd.conf.sgml drbdsetup.sgml drbdadm.sgml drbdmeta.sgml drbddisk.sgml
XML_SOURCES := $(SGML_SOURCES:.sgml=.xml) 

all: xml

clean:
	rm -f $(XML_SOURCES)

xml: $(XML_SOURCES)

%.xml: $(DRBD)/documentation/%.sgml
	sgml2xml -x no-nl-in-tag -x lower -x empty $<  | xmllint --format --output $@ -

.PHONY: all clean xml
