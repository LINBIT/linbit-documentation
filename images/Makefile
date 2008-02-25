all: raster-images

raster-images: note.png warning.png tip.png caution.png important.png bottom-left.png bottom-right.png top-left.png top-right.png bottom-left-small.png bottom-right-small.png top-left-small.png top-right-small.png linbit-logo-rotated-subdued.png 

vector-images:

clean: clean-png

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all raster-images vector-images clean
