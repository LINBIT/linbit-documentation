all: html

html: images users-guide.html

pdf: images users-guide.pdf

raster-images: metadata-size-exact.png metadata-size-approx.png

vector-images: metadata-size-exact.svg metadata-size-approx.svg

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all raster-images vector-images html fo pdf
