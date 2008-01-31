all: html

html: raster-images users-guide.html

pdf: vector-images users-guide.pdf

raster-images: metadata-size-exact.png metadata-size-approx.png al-extents.png al-extents-example.png drbd-in-kernel.png lvm.png drbd-plus-stacking.png

vector-images: metadata-size-exact.svg metadata-size-approx.svg al-extents.svg al-extents-example.svg

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all raster-images vector-images html fo pdf
