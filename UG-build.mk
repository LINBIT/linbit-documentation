#
# UG-build.mk
#
# Makefile should include this file and UG-build-adoc.mk if English document,
# or UG-build-po.mk if localized document.
#

IN_UG=drbd-users-guide.adoc
IN_LS=linstor-users-guide.adoc
OUTDIR=output
OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html
OUTDIRHTMLIMAGES=$(OUTDIRHTML)/images
OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize
IMGDIR=../../images
FONTDIR=../../linbit-fonts
OUTHTML_UG=$(addsuffix .html,$(basename $(IN_UG)))
OUTHTML_LS=$(addsuffix .html,$(basename $(IN_LS)))
OUTHTML_UG_WEBDEVS=drbd-users-guide-without-css.html
OUTHTML_LS_WEBDEVS=linstor-users-guide-without-css.html
OUTPDF_UG=$(addsuffix .pdf,$(basename $(IN_UG)))
OUTPDF_LS=$(addsuffix .pdf,$(basename $(IN_LS)))

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

$(OUTDIRHTML)/$(OUTHTML_UG): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -o ./$(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(IN_UG)

$(OUTDIRHTML)/$(OUTHTML_LS): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	if test -f $(OUTDIRHTML)/$(IN_LS); then \
		asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -o ./$(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(IN_LS); \
	else \
		echo "LINSTOR guide not found"; \
	fi

html: $(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(OUTHTML_LS)
	@echo "Generated web pages in $$(pwd)/$(OUTDIRHTML)"
	@echo "execute 'make html-finalize' to prepare upload"

html-finalize: html
	mv $(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(OUTHTML_UG_WEBDEVS)
	td=$$(mktemp -d) && \
		cp -r $(OUTDIRHTML)/$(OUTHTML_UG_WEBDEVS) $(OUTDIRHTMLIMAGES) $$td && \
		(cd $$td && zip drbd.zip $(OUTHTML_UG_WEBDEVS) images/*.png) && mv $$td/drbd.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"
	if test -f $(OUTDIRHTML)/$(OUTHTML_LS); then \
		mv $(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(OUTHTML_LS_WEBDEVS) && \
		td=$$(mktemp -d) && \
			cp $(OUTDIRHTML)/$(OUTHTML_LS_WEBDEVS) "$$td"/$(OUTHTML_UG_WEBDEVS) && cp -r $(OUTDIRHTMLIMAGES) $$td && \
			(cd $$td && zip linstor.zip $(OUTHTML_UG_WEBDEVS) images/*.png) && mv $$td/linstor.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"; \
	fi

# PDF
./images: $(IMAGEDIR)
	ln -s $(IMGDIR)

$(OUTDIRPDF)/$(OUTPDF_UG): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "ja" ] && [ "$(lang)" != "cn" ]; then \
		INTERN="-a pdf-style=../../stylesheets/pdf-style.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
	asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN -o $@ $(IN_UG)

$(OUTDIRPDF)/$(OUTPDF_LS): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "ja" ] && [ "$(lang)" != "cn" ]; then \
		INTERN="-a pdf-style=../../stylesheets/pdf-style.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
		if test -f $(IN_LS); then asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN -o $@ $(IN_LS); fi

pdf: ./images $(OUTDIRPDF)/$(OUTPDF_UG) $(OUTDIRPDF)/$(OUTPDF_LS)
	@echo "Generated $$(pwd)/$(OUTDIRPDF)/{$(OUTPDF_UG),$(OUTPDF_LS)}"

pdf-finalize: pdf
	rm -rf $(OUTDIRPDFFINAL) && mkdir $(OUTDIRPDFFINAL)
	cp $(OUTDIRPDF)/*.pdf $(OUTDIRPDFFINAL) && \
		D=$$(basename $$PWD)-$$(date +%F) && \
		for f in $(OUTDIRPDFFINAL)/*.pdf; do \
			mv $$f $(OUTDIRPDFFINAL)/$$(basename $$f .pdf)-$$D.pdf; \
		done

CLEAN_FILES += \
	$(OUTDIRHTML)/*.adoc $(OUTDIRHTML)/*.css $(OUTDIRHTML)/*.html \
	$(OUTDIRHTMLIMAGES)/* $(OUTDIRPDF)/*  \
	$(OUTDIRHTMLFINAL) $(OUTDIRPDFFINAL)

clean:
	rm -rf $(CLEAN_FILES)
