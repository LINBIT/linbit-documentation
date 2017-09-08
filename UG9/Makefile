IN=drbd-users-guide.adoc
OUTDIR=output
OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html
OUTDIRHTMLIMAGES=$(OUTDIRHTML)/images
OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize
IMGDIR=../images
FONTDIR=../linbit-fonts
OUTHTML=$(addsuffix .html,$(basename $(IN)))
OUTHTMLWEBDEVS=drbd-users-guide-without-css.html
OUTPDF=$(addsuffix .pdf,$(basename $(IN)))

SRC=$(wildcard *.adoc)
# for html
SVGSUSED=$(shell sed -n -e 's/^image::\(.*\.svg\)\(.*\)/\1/p' *.adoc)
SVGS=$(addprefix ../, $(SVGSUSED))
OUTPNGS=$(patsubst $(IMGDIR)/%.svg,$(OUTDIRHTMLIMAGES)/%.png, $(SVGS))
OUTADOCS=$(addprefix $(OUTDIRHTML)/, $(SRC))

%.adoc:
	;

# HTML
$(OUTDIRHTMLIMAGES): $(IMGDIR)
	mkdir $@ || true

$(OUTDIRHTMLIMAGES)/%.png: $(IMGDIR)/%.svg
	inkscape --file=$< --export-dpi=90 --export-area-drawing --export-png=./$@

$(OUTDIRHTML)/%.adoc: %.adoc
	sed 's/\(^image::.*\)\.svg\(.*\)/\1.png\2/g' $< > $@

$(OUTDIRHTML)/$(OUTHTML): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGS) $(OUTADOCS)
	asciidoctor -n -d book -a toc=left -a linkcss -o ./$(OUTDIRHTML)/$(OUTHTML) $(OUTDIRHTML)/$(IN)

html: $(OUTDIRHTML)/$(OUTHTML)
	@echo "Generated web page in $$(pwd)/$(OUTDIRHTML)"
	@echo "execute 'make html-finalize' to prepare upload"

html-finalize: html
	rm -rf $(OUTDIRHTMLFINAL) && mkdir $(OUTDIRHTMLFINAL) && touch $(OUTDIRHTMLFINAL)/.empty
	mv $(OUTDIRHTML)/$(OUTHTML) $(OUTDIRHTML)/$(OUTHTMLWEBDEVS)
	rm -f $(OUTDIRHTML)/*.adoc
	tar -czvf $(OUTDIRHTMLFINAL)/$$(basename $$PWD)-$$(date +%F).tar.gz $(OUTDIRHTML)

# PDF
./images: $(IMAGEDIR)
	ln -s $(IMGDIR)

$(OUTDIRPDF)/$(OUTPDF): $(SRC) $(SVGSUSED)
	if [ -d $(FONTDIR) ]; then INTERN="-a pdf-style=../stylesheets/pdf-style.yml -a pdf-fontsdir=$(FONTDIR)"; else \
		INTERN=""; fi && \
	asciidoctor-pdf -d book $$INTERN -o $@ $(IN)

pdf: ./images $(OUTDIRPDF)/$(OUTPDF)
	@echo "Generated $$(pwd)/$(OUTDIRPDF)/$(OUTPDF)"

pdf-finalize: pdf
	rm -rf $(OUTDIRPDFFINAL) && mkdir $(OUTDIRPDFFINAL) && touch $(OUTDIRPDFFINAL)/.empty
	cp $(OUTDIRPDF)/*.pdf $(OUTDIRPDFFINAL) && \
		D=$$(basename $$PWD)-$$(date +%F) && \
		cd $(OUTDIRPDFFINAL) && \
		mv $(OUTPDF) $${D}.pdf

clean:
	rm -rf $(OUTDIRHTML)/* $(OUTDIRHTMLFINAL)/* $(OUTDIRPDF)/* $(OUTDIRPDFFINAL)/*
