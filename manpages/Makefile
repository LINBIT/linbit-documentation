DRBD ?= ../../drbd-8

SYMLINKS := drbd.xml drbd.conf.xml drbdsetup.xml drbdadm.xml drbdmeta.xml drbddisk.xml

all: symlinks

$(SYMLINKS):
	ln -s $(DRBD)/documentation/$@

symlinks: $(SYMLINKS)

clean-symlinks:
	rm -f $(SYMLINKS)

clean: clean-symlinks

.PHONY: all symlinks clean-symlinks clean
