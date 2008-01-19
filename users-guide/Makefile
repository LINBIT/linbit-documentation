all: html pdf

html: users-guide.html

pdf: users-guide.pdf

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all html fo pdf
