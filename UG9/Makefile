IN=drbd-users-guide.adoc
OUTDIR=output
OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html
OUTDIRHTMLIMAGES=$(OUTDIRHTML)/images
OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize
IMGDIR=../images
OUTHTML=$(addsuffix .html,$(basename $(IN)))
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
	cp $< $@
	sed -i 's/\(^image::.*\)\.svg\(.*\)/\1.png\2/g' $@

$(OUTDIRHTML)/$(OUTHTML): $(OUTDIRHTMLIMAGES) $(SRC) $(OUTPNGS) $(OUTADOCS)
	asciidoctor -n -d book -a toc=left -a linkcss -o ./$(OUTDIRHTML)/$(OUTHTML) $(OUTDIRHTML)/$(IN)

html: $(OUTDIRHTML)/$(OUTHTML)
	@echo "Generated web page in $$(pwd)/$(OUTDIRHTML)"
	@echo "execute 'make html-finalize' to prepare upload"

html-finalize: html
	rm -rf $(OUTDIRHTMLFINAL) && mkdir $(OUTDIRHTMLFINAL)
	rm -f $(OUTADOCS) $(OUTDIRHTML)/*.css
	tar -czvf $(OUTDIRHTMLFINAL)/UG9-$$(date +%F).tar.gz $(OUTDIRHTML)

# PDF
./images: $(IMAGEDIR)
	ln -s $(IMGDIR)

$(OUTDIRPDF)/$(OUTPDF): $(SRC)
	asciidoctor-pdf -a pdf-style=../stylesheets/pdf-style.yml -d book -a pdf-fontsdir=../fonts -o $@ $(IN)

pdf: ./images $(OUTDIRPDF)/$(OUTPDF)
	@echo "Generated $$(pwd)/$(OUTDIRPDF)/$(OUTPDF)"

pdf-finalize: pdf
	rm -rf $(OUTDIRPDFFINAL) && mkdir $(OUTDIRPDFFINAL)
	cp $(OUTDIRPDF)/*.pdf $(OUTDIRPDFFINAL)

clean:
	rm -rf $(OUTDIRHTML)/* $(OUTDIRHTMLFINAL)/* $(OUTDIRPDF)/* $(OUTDIRPDFFINAL)/*
