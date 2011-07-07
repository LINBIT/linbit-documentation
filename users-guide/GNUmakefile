DRBD_MANPAGE_SOURCES = $(wildcard $(DRBD)/documentation/*.xml)
DRBD_MANPAGE_SYMLINKS = $(subst $(DRBD)/documentation/, , $(DRBD_MANPAGE_SOURCES))
MISSING_VARIABLE = Please set the DRBD variable pointing to your drbd checkout.

$(DRBD_MANPAGE_SYMLINKS):
ifndef DRBD
	$(warning $(MISSING_VARIABLE))
else
	ln -s $(DRBD)/documentation/$@ .
endif

.PHONY: drbd-symlinks
drbd-symlinks: $(DRBD_MANPAGE_SYMLINKS)
ifndef DRBD
	$(warning $(MISSING_VARIABLE))
endif

.PHONY: clean-drbd-symlinks
clean-drbd-symlinks:
ifndef DRBD
	$(error $(MISSING_VARIABLE))
else
	rm $(DRBD_MANPAGE_SYMLINKS) -f
endif

%:
	@$(MAKE) -f Makefile $@
