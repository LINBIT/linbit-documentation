all: html

html: images users-guide.html

pdf: images users-guide.pdf

images: metadata-size-exact.png metadata-size-approx.png

%: force
	@$(MAKE) -f ../Makefile $@
force: ;

.PHONY: all images html fo pdf
