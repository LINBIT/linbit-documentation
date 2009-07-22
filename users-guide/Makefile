VECTOR_IMAGES := metadata-size-exact.svg metadata-size-approx.svg al-extents.svg al-extents-example.svg resync-time.svg syncer-rate-example1.svg syncer-rate-example2.svg

RASTER_IMAGES := metadata-size-exact.png metadata-size-approx.png al-extents.png al-extents-example.png resync-time.png syncer-rate-example1.png syncer-rate-example2.png drbd-in-kernel.png lvm.png gi-changes-newgen.png gi-changes-syncstart.png gi-changes-synccomplete.png drbd-resource-stacking.png drbd-resource-stacking-pacemaker.png

SYMLINKS := xinclude-not-found.xml todo.xml stylesheets images drbd-howto-collection.css

RSYNC_OPTIONS := --verbose --times --recursive --compress --copy-links

all: html

html: builddate symlinks raster-images users-guide.html

raster-images: $(RASTER_IMAGES) 

vector-images: $(VECTOR_IMAGES)

clean-symlinks:
	rm -f $(SYMLINKS)

clean: clean-svg clean-png clean-html clean-symlinks clean-builddate

$(SYMLINKS):
	ln -s ../$@

symlinks: $(SYMLINKS)

upload: html
	rsync --exclude '*.svg' --exclude 'Makefile' --exclude '*~' --exclude '.gitignore' $(RSYNC_OPTIONS) images *.css *.png *.html $(RSYNC_TARGET)

%: force
	@$(MAKE) -f ../Makefile $@
force: ;


.PHONY: all raster-images vector-images clean-symlinks symlinks clean html upload
