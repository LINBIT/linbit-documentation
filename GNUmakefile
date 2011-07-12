MAKEDOC_SYMLINK_TARGETS = $(MAKEDOC)/Makefile.am $(MAKEDOC)/configure.ac.stub $(MAKEDOC)/autogen.sh
MAKEDOC_SYMLINKS = $(subst $(MAKEDOC)/, , $(MAKEDOC_SYMLINK_TARGETS))
MISSING_VARIABLE = Please set the MAKEDOC variable pointing to your makedoc checkout.

.PHONY: makedoc-symlinks
makedoc-symlinks: $(MAKEDOC_SYMLINKS)
ifndef MAKEDOC
	$(warning $(MISSING_VARIABLE))
endif
	$(info Now run ./autogen.sh)

.PHONY: clean-makedoc-symlinks
clean-makedoc-symlinks:
ifndef MAKEDOC
	$(error $(MISSING_VARIABLE))
else
	rm $(MAKEDOC_SYMLINKS) -f
endif

$(MAKEDOC_SYMLINKS):
ifndef MAKEDOC
	$(warning $(MISSING_VARIABLE))
else
	ln -s $(MAKEDOC)/$@ .
endif

%:
	@$(MAKE) -f Makefile $@

