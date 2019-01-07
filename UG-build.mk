#
# UG-build.mk
#
# Makefile should include this file and UG-build-adoc.mk if English document,
# or UG-build-po.mk if localized document.
#

IN=drbd-users-guide.adoc
OUTDIR=output
OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html
OUTDIRHTMLIMAGES=$(OUTDIRHTML)/images
OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize
IMGDIR=../../images
FONTDIR=../../linbit-fonts
OUTHTML=$(addsuffix .html,$(basename $(IN)))
OUTHTMLWEBDEVS=drbd-users-guide-without-css.html
OUTPDF=$(addsuffix .pdf,$(basename $(IN)))

# for html
SVGS=$(addprefix ../../, $(SVGSUSED))
# output pngs from svgs
OUTPNGSSVGS=$(patsubst $(IMGDIR)/%.svg,$(OUTDIRHTMLIMAGES)/%.png, $(SVGS))

PNGS=$(addprefix ../../, $(PNGSUSED))
# output pngs from pngs
OUTPNGSPNGS=$(patsubst $(IMGDIR)/%.png,$(OUTDIRHTMLIMAGES)/%.png, $(PNGS))

OUTADOCS=$(addprefix $(OUTDIRHTML)/, $(SRC))

# HTML
$(OUTDIRHTMLIMAGES): $(IMGDIR)
	mkdir $@ || true

$(OUTDIRHTMLIMAGES)/%.png: $(IMGDIR)/%.svg
	inkscape --file=$< --export-dpi=90 --export-area-drawing --export-png=./$@

$(OUTDIRHTMLIMAGES)/%.png: $(IMGDIR)/%.png
	cp $< $@

$(OUTDIRHTML)/%.adoc: %.adoc
	sed 's/\(^image::.*\)\.svg\(.*\)/\1.png\2/g' $< > $@

$(OUTDIRHTML)/$(OUTHTML): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -o ./$(OUTDIRHTML)/$(OUTHTML) $(OUTDIRHTML)/$(IN)

html: $(OUTDIRHTML)/$(OUTHTML)
	@echo "Generated web page in $$(pwd)/$(OUTDIRHTML)"
	@echo "execute 'make html-finalize' to prepare upload"

html-finalize: html
	mv $(OUTDIRHTML)/$(OUTHTML) $(OUTDIRHTML)/$(OUTHTMLWEBDEVS)
	rm -f $(OUTDIRHTML)/*.adoc
	rm -rf $(OUTDIRHTMLFINAL) && mkdir $(OUTDIRHTMLFINAL)
	tar -czvf $(OUTDIRHTMLFINAL)/$$(basename $$(dirname $$PWD))-$$(basename $$PWD)-$$(date +%F).tar.gz $(OUTDIRHTML)

# PDF
./images: $(IMAGEDIR)
	ln -s $(IMGDIR)

$(OUTDIRPDF)/$(OUTPDF): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "ja" ]; then \
		INTERN="-a pdf-style=../../stylesheets/pdf-style.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
	asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN -o $@ $(IN)

pdf: ./images $(OUTDIRPDF)/$(OUTPDF)
	@echo "Generated $$(pwd)/$(OUTDIRPDF)/$(OUTPDF)"

pdf-finalize: pdf
	rm -rf $(OUTDIRPDFFINAL) && mkdir $(OUTDIRPDFFINAL)
	cp $(OUTDIRPDF)/*.pdf $(OUTDIRPDFFINAL) && \
		D=$$(basename $$PWD)-$$(date +%F) && \
		cd $(OUTDIRPDFFINAL) && \
		mv $(OUTPDF) $${D}.pdf

CLEAN_FILES += \
	$(OUTDIRHTML)/*.adoc $(OUTDIRHTML)/*.css $(OUTDIRHTML)/*.html \
	$(OUTDIRHTMLIMAGES)/* $(OUTDIRPDF)/*  \
	$(OUTDIRHTMLFINAL) $(OUTDIRPDFFINAL)

clean:
	rm -rf $(CLEAN_FILES)
