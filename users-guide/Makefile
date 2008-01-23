all: html

html: users-guide.html

pdf: users-guide.pdf

images: metadata-size-exact.png metadata-size-approx.png

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all images html fo pdf
