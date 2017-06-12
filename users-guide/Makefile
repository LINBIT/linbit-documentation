IN=drbd-users-guide.txt
OUTDIR=output
OUTHTML=$(addsuffix .html,$(basename $(IN)))
OUTPDF=$(addsuffix .pdf,$(basename $(IN)))

PNG=$(addprefix output/,$(addsuffix .png,$(basename $(wildcard *.svg))))
SRC=$(wildcard *.txt)

$(OUTDIR)/%.png: %.svg
	inkscape --file=$< --export-dpi=90 --export-area-drawing --export-png=./$@

%.txt:
	;

$(OUTDIR)/$(OUTHTML): $(IN) $(SRC) $(PNG)
	asciidoctor -n -d book -a toc=left -o ./$(OUTDIR)/$(OUTHTML) $(IN)

$(OUTDIR)/$(OUTPDF): $(IN) $(SRC)
	cp -r *.txt *.svg $(OUTDIR)
	cd $(OUTDIR) && \
	#sed -i 's/\(^image::.*\)\.png\(.*\)/\1.svg\2/g' ./*.txt  && \
	sed -i 's/\(^image::.*\)\.png\(.*\)/\1.svg[]/g' ./*.txt  && \
	asciidoctor-pdf -a pdf-style=../../stylesheets/pdf-style.yml -d book -a pdf-fontsdir=../../fonts -o $(OUTPDF) $(IN)

html: $(OUTDIR)/$(OUTHTML)

pdf: $(OUTDIR)/$(OUTPDF)
