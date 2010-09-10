VECTOR_IMAGES := 

RASTER_IMAGES := 

SYMLINKS := xinclude-not-found.xml todo.xml stylesheets images drbd-howto-collection.css

RSYNC_OPTIONS := --verbose --times --recursive --compress --copy-links

all: html

html: builddate symlinks raster-images

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
