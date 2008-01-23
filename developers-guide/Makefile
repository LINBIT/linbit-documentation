all: html

html: images developers-guide.html

pdf: images developers-guide.pdf

raster-images:

vector-images:

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all html pdf raster-images vector-images images
