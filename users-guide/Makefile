VECTOR_IMAGES := metadata-size-exact.svg metadata-size-approx.svg al-extents.svg al-extents-example.svg resync-time.svg syncer-rate-example1.svg syncer-rate-example2.svg

RASTER_IMAGES := metadata-size-exact.png metadata-size-approx.png al-extents.png al-extents-example.png resync-time.png syncer-rate-example1.png syncer-rate-example2.png drbd-in-kernel.png lvm.png gi-changes-newgen.png gi-changes-syncstart.png gi-changes-synccomplete.png

all: html

html: raster-images users-guide.html

raster-images: $(RASTER_IMAGES) 

vector-images: $(VECTOR_IMAGES)

clean: clean-svg clean-png clean-html

%.xml: %.sgml
	sgml2xml -x no-nl-in-tag -x lower -x empty $<  | xmllint --format --output $@ -

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all raster-images vector-images clean html
