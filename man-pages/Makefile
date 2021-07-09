OUTDIR=output

OUTDIRPDF=$(OUTDIR)-pdf
OUTDIRHTML=$(OUTDIR)-html

OUTDIRPDFFINAL=$(OUTDIRPDF)-finalize
OUTDIRHTMLFINAL=$(OUTDIRHTML)-finalize

ifeq ($(DRBD_UTILS),)
$(error "point DRBD_UTILS to a compiled checkout INCLUDING GENERATED man pages of drbd-utils")
else
MANDIR=$(DRBD_UTILS)/documentation
endif

ifneq ($(lang),en)
DRBD_UTILS_LANG=$(lang)
endif

MANDIR_v9=$(MANDIR)/$(DRBD_UTILS_LANG)/v9
MANDIR_v84=$(MANDIR)/$(DRBD_UTILS_LANG)/v84

MANPAGES_v9_5=$(wildcard $(MANDIR_v9)/*.5)
MANPAGES_v9_7=$(wildcard $(MANDIR_v9)/*.7)
MANPAGES_v9_8=$(wildcard $(MANDIR_v9)/*.8)
MANPAGES_v9=$(MANPAGES_v9_5) $(MANPAGES_v9_7) $(MANPAGES_v9_8)

MANPAGES_v84_5=$(wildcard $(MANDIR_v84)/*.5)
MANPAGES_v84_8=$(wildcard $(MANDIR_v84)/*.8)
MANPAGES_v84=$(MANPAGES_v84_5) $(MANPAGES_v84_8)

OUTMANS_v9_5=$(patsubst $(MANDIR_v9)/%.5,$(OUTDIRHTML)/v9/%.5.html, $(MANPAGES_v9_5))
OUTMANS_v9_7=$(patsubst $(MANDIR_v9)/%.7,$(OUTDIRHTML)/v9/%.7.html, $(MANPAGES_v9_7))
OUTMANS_v9_8=$(patsubst $(MANDIR_v9)/%.8,$(OUTDIRHTML)/v9/%.8.html, $(MANPAGES_v9_8))

OUTMANS_v84_5=$(patsubst $(MANDIR_v84)/%.5,$(OUTDIRHTML)/v84/%.5.html, $(MANPAGES_v84_5))
OUTMANS_v84_8=$(patsubst $(MANDIR_v84)/%.8,$(OUTDIRHTML)/v84/%.8.html, $(MANPAGES_v84_8))

OUTMANS=$(OUTMANS_v9_5) $(OUTMANS_v9_7) $(OUTMANS_v9_8) $(OUTMANS_v84_5) $(OUTMANS_v84_8)

define run-mandoc =
	cat $< | mandoc -Thtml -Ostyle=mandoc.css 1> $@
	mps=""; \
	echo $@ | grep -q 84 && mps="$(MANPAGES_v84)" || mps="$(MANPAGES_v9)"; \
	for mp in $$mps; do \
		last=$$(echo -n $$mp | tail -c 1); \
		bn=$$(basename $$(basename $$(basename $$mp .5) .8) .7); \
		sed -i "s/<b>$$bn<\/b>/<b><a href=\"$$bn.$$last.html\">$$bn<\/a><\/b>/g" $@; \
	done;
endef

$(OUTDIRHTML)/v9/%.5.html: $(MANDIR_v9)/%.5
	$(run-mandoc)

$(OUTDIRHTML)/v9/%.7.html: $(MANDIR_v9)/%.7
	$(run-mandoc)

$(OUTDIRHTML)/v9/%.8.html: $(MANDIR_v9)/%.8
	$(run-mandoc)

$(OUTDIRHTML)/v84/%.5.html: $(MANDIR_v84)/%.5
	$(run-mandoc)

$(OUTDIRHTML)/v84/%.8.html: $(MANDIR_v84)/%.8
	$(run-mandoc)

define run-index =
	mps=""; \
	desc=""; \
	echo $@ | grep -q v84; \
	if [ "$$?" =  "1" ]; then \
		mps="$(MANPAGES_v9)"; desc="9.0"; \
	else \
		mps="$(MANPAGES_v84)"; desc="8.4"; \
	fi; \
	echo "<html>" > $@; \
	echo "<head>" >> $@; \
	echo '<link rel="stylesheet" href="mandoc.css" type="text/css" media="all"/>' >> $@; \
	echo "</head>" >> $@; \
	echo "<h1>DRBD $${desc} Manual Pages</h1>" >> $@; \
	for mp in $$mps; do \
		bn=$$(basename $$mp); \
		echo "<a href=$${bn}.html>$$bn</a>" >> $@; \
	done; \
	echo "</html>" >> $@
endef

.PHONY: $(OUTDIRHTML)/v84/index.html
$(OUTDIRHTML)/v84/index.html:
	$(run-index)

.PHONY: $(OUTDIRHTML)/v9/index.html
$(OUTDIRHTML)/v9/index.html:
	$(run-index)

.PHONY: dirs
dirs:
	mkdir -p $(OUTDIRHTML)/v84/ || true
	mkdir -p $(OUTDIRHTML)/v9/ || true

.PHONY: style
style: dirs
	# brr, nasty hack
	cp -f mandoc.css $(OUTDIRHTML)/v84/
	cp -f mandoc.css $(OUTDIRHTML)/v9/

html: style $(OUTMANS) $(OUTDIRHTML)/v84/index.html $(OUTDIRHTML)/v9/index.html
	@echo "Generated web page in $$(pwd)/$(OUTDIRHTML)"
	@echo "execute 'make html-finalize' to prepare upload"

html-finalize: html
	rm -rf $(OUTDIRHTMLFINAL) && mkdir $(OUTDIRHTMLFINAL) && touch $(OUTDIRHTMLFINAL)/.empty
	for d in v84 v9; do (cd $(OUTDIRHTML)/$$d; zip ../../$(OUTDIRHTMLFINAL)/man-pages-$$d.zip ./*.html); done

pdf:
	$(error "pdf generation is not supported")

pdf-finalize: pdf

clean:
	rm -rf $(OUTDIRHTML)/* $(OUTDIRHTMLFINAL)/*
