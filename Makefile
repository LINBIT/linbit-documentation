define run-in-docker =
	docker run -it --rm -v $$(pwd):/home/devin/linbit-documentation linbit-documentation /bin/sh -c 'cd /home/devin/linbit-documentation && make $(patsubst %-docker,%,$@)'
endef

.PHONY: README.html-docker
README.html: README.adoc
	asciidoctor -n -o $@ $<

README.html-docker:
	$(run-in-docker)

# UG 9
.PHONY: UG9-pdf UG9-pdf-docker UG9-html UG9-html-docker
UG9-pdf:
	make -C UG9 pdf-finalize

UG9-pdf-docker:
	$(run-in-docker)

UG9-html:
	make -C UG9 html-finalize

UG9-html-docker:
	$(run-in-docker)

# UG 8.4
.PHONY: UG8.4-pdf UG8.4-pdf-docker UG8.4-html UG8.4-html-docker
UG8.4-pdf:
	make -C UG8.4 pdf-finalize

UG8.4-pdf-docker:
	$(run-in-docker)

UG8.4-html:
	make -C UG8.4 html-finalize

UG8.4-html-docker:
	$(run-in-docker)

## targets you can only use if you cloned the according *private* project
# tech guides
.PHONY: tech-guides-pdf tech-guides-pdf-docker
tech-guides-pdf:
	make -C tech-guides pdf-finalize

tech-guides-pdf-docker:
	$(run-in-docker)
