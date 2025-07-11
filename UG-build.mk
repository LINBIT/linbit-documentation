#
# UG-build.mk
#
# Makefile should include this file and UG-build-adoc.mk if English document,
# or UG-build-po.mk if localized document.
#

# If adding new UGs in the future, maintain the naming convention:
# xxxxxx-user-guide.adoc for the UG's IN- variable below.
IN_UG=drbd-user-guide.adoc
IN_LS=linstor-user-guide.adoc
IN_VSAN=vsan-user-guide.adoc
IN_UNDERSTANDING_GW=linstorgw-user-guide.adoc
OUTDIR=output
OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html
OUTDIRHTMLIMAGES=$(OUTDIRHTML)/images
OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize
IMGDIR=../../images
# Set the FONTDIR variable, only if not already set, e.g. within a $lang/Makefile
FONTDIR ?= ../../linbit-fonts
THEMESDIR=../../themes
STYLESDIR=../../styles
OUTHTML_UG=$(addsuffix .html,$(basename $(IN_UG)))
OUTHTML_LS=$(addsuffix .html,$(basename $(IN_LS)))
OUTHTML_VSAN=$(addsuffix .html,$(basename $(IN_VSAN)))
OUTHTML_UNDERSTANDING_GW=$(addsuffix .html,$(basename $(IN_UNDERSTANDING_GW)))
# The -WEBDEVS variables below should result in file names in the form:
# xxxxxxx-user-guide-without-css.html, e.g.,
# vsan-user-guide-without-css.html. This is the HTML file that will be
# included in each UG's ZIP file after running the UGx-html-finalize `make`
# target. The PHP script that is part of the GitLab "preview" phase of the UG
# building process relies on this naming convention.
OUTHTML_UG_WEBDEVS=$(addsuffix -without-css.html,$(basename $(IN_UG)))
OUTHTML_LS_WEBDEVS=$(addsuffix -without-css.html,$(basename $(IN_LS)))
OUTHTML_VSAN_WEBDEVS=$(addsuffix -without-css.html,$(basename $(IN_VSAN)))
OUTHTML_UNDERSTANDING_GW_WEBDEVS=$(addsuffix -without-css.html,$(basename $(IN_UNDERSTANDING_GW)))
OUTPDF_UG=$(addsuffix .pdf,$(basename $(IN_UG)))
OUTPDF_LS=$(addsuffix .pdf,$(basename $(IN_LS)))
OUTPDF_VSAN=$(addsuffix .pdf,$(basename $(IN_VSAN)))
OUTPDF_UNDERSTANDING_GW=$(addsuffix .pdf,$(basename $(IN_UNDERSTANDING_GW)))

# for HTML
SVGS=$(addprefix ../../, $(SVGSUSED))

# output svgs from svgs
OUTSVGSSVGS=$(patsubst $(IMGDIR)/%.svg,$(OUTDIRHTMLIMAGES)/%.svg, $(SVGS))

PNGS=$(addprefix ../../, $(PNGSUSED))
# output pngs from pngs
OUTPNGSPNGS=$(patsubst $(IMGDIR)/%.png,$(OUTDIRHTMLIMAGES)/%.png, $(PNGS))

OUTADOCS=$(addprefix $(OUTDIRHTML)/, $(SRC))

# HTML
$(OUTDIRHTMLIMAGES): $(IMGDIR)
	mkdir $@ || true

$(OUTDIRHTMLIMAGES)/%.svg: $(IMGDIR)/%.svg
	cp $< $@

$(OUTDIRHTMLIMAGES)/%.png: $(IMGDIR)/%.png
	cp $< $@

$(OUTDIRHTML)/%.adoc: %.adoc
#	sed 's/\(^image::.*\)\.svg\(.*\)/\1.png\2/g' $< > $@
	echo mkdir -p $@/$(shell dirname $<)
	cp $< $@

$(OUTDIRHTML)/$(OUTHTML_UG): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTSVGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(IN_UG)

$(OUTDIRHTML)/$(OUTHTML_LS): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTSVGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	if test -f $(OUTDIRHTML)/$(IN_LS); then \
		asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(IN_LS); \
	else \
		echo "LINSTOR guide not found"; \
	fi

$(OUTDIRHTML)/$(OUTHTML_VSAN): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTSVGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	if test -f $(OUTDIRHTML)/$(IN_VSAN); then \
		asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_VSAN) $(OUTDIRHTML)/$(IN_VSAN); \
	else \
		echo "VSAN guide not found"; \
	fi

$(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTSVGSSVGS) $(OUTPNGSPNGS) $(OUTADOCS)
	if test -f $(OUTDIRHTML)/$(IN_UNDERSTANDING_GW); then \
		asciidoctor $(ASCIIDOCTOR_ADD_OPTIONS) -n -d book -a toc=left -a linkcss -a sectanchors=yes $(OPTS) -o ./$(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW) $(OUTDIRHTML)/$(IN_UNDERSTANDING_GW); \
	else \
		echo "Understanding LINSTOR Gateway guide not found"; \
	fi

html: $(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(OUTHTML_VSAN) $(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW)
	@echo "Generated web pages in $$(pwd)/$(OUTDIRHTML)"
	@echo "Execute 'make html-finalize' to prepare upload"

html-finalize: html
	rm -rf $(OUTDIRHTMLFINAL) && mkdir $(OUTDIRHTMLFINAL)
	mv $(OUTDIRHTML)/$(OUTHTML_UG) $(OUTDIRHTML)/$(OUTHTML_UG_WEBDEVS)
	td=$$(mktemp -d) && \
	cp -r $(OUTDIRHTML)/$(OUTHTML_UG_WEBDEVS) $(OUTDIRHTMLIMAGES) $$td && \
	(cd $$td && zip drbd.zip $(OUTHTML_UG_WEBDEVS) images/*.*) && mv $$td/drbd.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"
	if test -f $(OUTDIRHTML)/$(OUTHTML_LS); then \
		mv $(OUTDIRHTML)/$(OUTHTML_LS) $(OUTDIRHTML)/$(OUTHTML_LS_WEBDEVS) && \
		td=$$(mktemp -d) && \
		cp $(OUTDIRHTML)/$(OUTHTML_LS_WEBDEVS) "$$td"/$(OUTHTML_LS_WEBDEVS) && cp -r $(OUTDIRHTMLIMAGES) $$td && \
		(cd $$td && zip linstor.zip $(OUTHTML_LS_WEBDEVS) images/*.*) && mv $$td/linstor.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"; \
	fi
	if test -f $(OUTDIRHTML)/$(OUTHTML_VSAN); then \
		mv $(OUTDIRHTML)/$(OUTHTML_VSAN) $(OUTDIRHTML)/$(OUTHTML_VSAN_WEBDEVS) && \
		td=$$(mktemp -d) && \
		cp $(OUTDIRHTML)/$(OUTHTML_VSAN_WEBDEVS) "$$td"/$(OUTHTML_VSAN_WEBDEVS) && cp -r $(OUTDIRHTMLIMAGES) $$td && \
		(cd $$td && zip vsan.zip $(OUTHTML_VSAN_WEBDEVS) images/*.*) && mv $$td/vsan.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"; \
	fi
	if test -f $(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW); then \
		mv $(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW) $(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW_WEBDEVS) && \
		td=$$(mktemp -d) && \
		cp $(OUTDIRHTML)/$(OUTHTML_UNDERSTANDING_GW_WEBDEVS) "$$td"/$(OUTHTML_UNDERSTANDING_GW_WEBDEVS) && cp -r $(OUTDIRHTMLIMAGES) $$td && \
		(cd $$td && zip linstorgateway.zip $(OUTHTML_UNDERSTANDING_GW_WEBDEVS) images/*.*) && mv $$td/linstorgateway.zip $(OUTDIRHTMLFINAL) && rm -rf "$$td"; \
	fi

# PDF
./images: $(IMAGEDIR)
	ln -s $(IMGDIR)

$(OUTDIRPDF)/$(OUTPDF_UG): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="--theme $(THEMESDIR)/pdf-$(lang)-theme.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
	asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_UG)

$(OUTDIRPDF)/$(OUTPDF_LS): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="--theme $(THEMESDIR)/pdf-$(lang)-theme.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
		if test -f $(IN_LS); then asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_LS); fi

$(OUTDIRPDF)/$(OUTPDF_VSAN): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="--theme $(THEMESDIR)/pdf-$(lang)-theme.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
		if test -f $(IN_VSAN); then asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_VSAN); fi

$(OUTDIRPDF)/$(OUTPDF_UNDERSTANDING_GW): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ] && [ "$(lang)" != "cn" ] && \
		! echo "$(OPTS)" | grep -qFw 'de-brand'; then \
		INTERN="--theme $(THEMESDIR)/pdf-$(lang)-theme.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
		if test -f $(IN_UNDERSTANDING_GW); then asciidoctor-pdf $(ASCIIDOCTOR_ADD_OPTIONS) -d book $$INTERN $(OPTS) -o $@ $(IN_UNDERSTANDING_GW); fi

pdf: ./images $(OUTDIRPDF)/$(OUTPDF_UG) $(OUTDIRPDF)/$(OUTPDF_LS) $(OUTDIRPDF)/$(OUTPDF_VSAN) $(OUTDIRPDF)/$(OUTPDF_UNDERSTANDING_GW)
	@echo "Generated $$(pwd)/$(OUTDIRPDF)/{$(OUTPDF_UG),$(OUTPDF_LS),$(OUTPDF_VSAN),$(OUTPDF_UNDERSTANDING_GW)}"

pdf-finalize: pdf
	rm -rf $(OUTDIRPDFFINAL) && mkdir $(OUTDIRPDFFINAL)
	cp $(OUTDIRPDF)/*.pdf $(OUTDIRPDFFINAL) && \
		D=$$(basename $$PWD)-$$(date +%F) && \
		for f in $(OUTDIRPDFFINAL)/*.pdf; do \
			mv $$f $(OUTDIRPDFFINAL)/$$(basename $$f .pdf)-$$D.pdf; \
		done

CLEAN_FILES += \
	$(OUTDIRHTML)/*.adoc $(OUTDIRHTML)/*.css $(OUTDIRHTML)/*.html \
	$(OUTDIRHTMLIMAGES)/* $(OUTDIRPDF)/* $(OUTDIREPUB) \
	$(OUTDIRHTMLFINAL) $(OUTDIRPDFFINAL) $(OUTDIREPUBFINAL)

clean:
	rm -rf $(CLEAN_FILES) \
	unlink ../../UG8.4/*/images \
	unlink ../../UG9/*/images
