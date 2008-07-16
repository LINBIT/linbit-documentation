VECTOR_IMAGES := metadata-size-exact.svg metadata-size-approx.svg al-extents.svg al-extents-example.svg resync-time.svg syncer-rate-example1.svg syncer-rate-example2.svg

RASTER_IMAGES := metadata-size-exact.png metadata-size-approx.png al-extents.png al-extents-example.png resync-time.png syncer-rate-example1.png syncer-rate-example2.png drbd-in-kernel.png lvm.png gi-changes-newgen.png gi-changes-syncstart.png gi-changes-synccomplete.png

SYMLINKS := xinclude-not-found.xml todo.xml stylesheets images drbd-howto-collection.css

all: html

html: symlinks raster-images users-guide.html

raster-images: $(RASTER_IMAGES) 

vector-images: $(VECTOR_IMAGES)

clean-symlinks:
	rm -f $(SYMLINKS)

clean: clean-svg clean-png clean-html clean-symlinks

$(SYMLINKS):
	ln -s ../$@

symlinks: $(SYMLINKS)

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all raster-images vector-images clean-symlinks symlinks clean html


