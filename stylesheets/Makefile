all: xsl

xsl: fo-titlepage.xsl

clean:
	rm -f fo-titlepage.xsl

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all xsl
