all: html

html: images developers-guide.html

pdf: images developers-guide.pdf

images:

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all html pdf images
