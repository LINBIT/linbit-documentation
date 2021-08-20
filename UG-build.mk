#
# UG-build.mk
#
# Makefile should include this file and UG-build-adoc.mk if English document,
# or UG-build-po.mk if localized document.
#

IN_UG=drbd-users-guide.adoc
IN_LS=linstor-users-guide.adoc
IN_VSAN=vsan-users-guide.adoc
OUTDIR=output
OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html
OUTDIRHTMLIMAGES=$(OUTDIRHTML)/images
OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize
IMGDIR=../../images
FONTDIR ?= ../../linbit-fonts
OUTHTML_UG=$(addsuffix .html,$(basename $(IN_UG)))
OUTHTML_LS=$(addsuffix .html,$(basename $(IN_LS)))
OUTHTML_VSAN=$(addsuffix .html,$(basename $(IN_VSAN)))
OUTHTML_UG_WEBDEVS=drbd-users-guide-without-css.html
OUTHTML_LS_WEBDEVS=linstor-users-guide-without-css.html
OUTHTML_VSAN_WEBDEVS=vsan-users-guide-without-css.html
OUTPDF_UG=$(addsuffix .pdf,$(basename $(IN_UG)))
OUTPDF_LS=$(addsuffix .pdf,$(basename $(IN_LS)))
OUTPDF_VSAN=$(addsuffix .pdf,$(basename $(IN_VSAN)))

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
	inkscape --file=$< --export-dpi=90 --export-area-drawing --export-png=./$@ || inkscape $< --export-dpi=90 --export-area-drawing -o ./$@

$(OUTDIRHTMLIMAGES)/%.png: $(IMGDIR)/%.png
	cp $< $@

$(OUTDIRHTML)/%.adoc: %.adoc
	sed 's/\(^image::.*\)\.svg\(.*\)/\1.png\2/g' $< > $@

$(OUTDIRHTML)/$(OUTHTML_UG): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(IN_UG)

$(OUTDIRHTML)/$(OUTHTML_LS): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	if test -f $(OUTDIRHTML)/$(IN_LS); then \
		asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(IN_LS); \
	else \
		echo "LINSTOR guide not found"; \
	fi

$(OUTDIRHTML)/$(OUTHTML_VSAN): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	if test -f $(OUTDIRHTML)/$(IN_VSAN); then \
		asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_VSAN) $(OUTDIRHTML)/$(IN_VSAN); \
	else \
		echo "VSAN guide not found"; \
	fi

html: $(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(OUTHTML_VSAN)
	@echo "Generated web pages in $$(pwd)/$(OUTDIRHTML)"
	@echo "execute 'make html-finalize' to prepare upload"

html-finalize: html
	rm -rf $(OUTDIRHTMLFINAL) && mkdir $(OUTDIRHTMLFINAL)
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
	if test -f $(OUTDIRHTML)/$(OUTHTML_VSAN); then \
		mv $(OUTDIRHTML)/$(OUTHTML_VSAN) $(OUTDIRHTML)/$(OUTHTML_VSAN_WEBDEVS) && \
		td=$$(mktemp -d) && \
			cp $(OUTDIRHTML)/$(OUTHTML_VSAN_WEBDEVS) "$$td"/$(OUTHTML_UG_WEBDEVS) && cp -r $(OUTDIRHTMLIMAGES) $$td && \
			(cd $$td && zip vsan.zip $(OUTHTML_UG_WEBDEVS) images/*.png) && mv $$td/vsan.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"; \
	fi

# PDF
./images: $(IMAGEDIR)
	ln -s $(IMGDIR)

$(OUTDIRPDF)/$(OUTPDF_UG): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "cn" ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="-a pdf-style=../../stylesheets/pdf-style-$(lang).yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
	asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_UG)

$(OUTDIRPDF)/$(OUTPDF_LS): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "cn" ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="-a pdf-style=../../stylesheets/pdf-style-$(lang).yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
		if test -f $(IN_LS); then asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_LS); fi

$(OUTDIRPDF)/$(OUTPDF_VSAN): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "cn" ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="-a pdf-style=../../stylesheets/pdf-style-$(lang).yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
		if test -f $(IN_VSAN); then asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_VSAN); fi

pdf: ./images $(OUTDIRPDF)/$(OUTPDF_UG) $(OUTDIRPDF)/$(OUTPDF_LS) $(OUTDIRPDF)/$(OUTPDF_VSAN)
	@echo "Generated $$(pwd)/$(OUTDIRPDF)/{$(OUTPDF_UG),$(OUTPDF_LS),$(OUTPDF_VSAN)}"

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
