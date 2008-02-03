all: html

html: images developers-guide.html

pdf: images developers-guide.pdf

raster-images:

vector-images:

clean: clean-svg clean-png clean-pdf clean-fo clean-html clean-pdf clean-ps

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all html pdf raster-images vector-images clean
