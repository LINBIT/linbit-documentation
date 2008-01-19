all: html pdf

html: developers-guide.html

pdf: developers-guide.pdf

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all html pdf
