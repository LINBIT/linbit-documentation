# you can override on command line
lang = en

define run-in-docker =
	docker run -it --rm -v $$(pwd):/home/makedoc/linbit-documentation linbit-documentation /bin/sh -c 'cd ~/linbit-documentation && make $(patsubst %-docker,%,$@) lang=$(lang)'
endef

.PHONY: README.html-docker
README.html: README.adoc
	asciidoctor -n -o $@ $<

README.html-docker:
	$(run-in-docker)

# UG 9
.PHONY: UG9-pdf-finalize UG9-pdf-finalize-docker UG9-html-finalize UG9-html-finalize-docker
UG9-pdf-finalize:
	make -C UG9 pdf-finalize

UG9-pdf-finalize-docker:
	$(run-in-docker)

UG9-html-finalize:
	make -C UG9 html-finalize lang=$(lang)

UG9-html-finalize-docker:
	$(run-in-docker)

# UG 8.4
.PHONY: UG8.4-pdf-finalize UG8.4-pdf-finalize-docker UG8.4-html-finalize UG8.4-html-finalize-docker
UG8.4-pdf-finalize:
	make -C UG8.4 pdf-finalize

UG8.4-pdf-finalize-docker:
	$(run-in-docker)

UG8.4-html-finalize:
	make -C UG8.4 html-finalize lang=$(lang)

UG8.4-html-finalize-docker:
	$(run-in-docker)

## targets you can only use if you cloned the according *private* project
# tech guides
.PHONY: tech-guides-pdf-finalize tech-guides-pdf-finalize-docker
tech-guides-pdf-finalize:
	make -C tech-guides pdf-finalize

tech-guides-pdf-finalize-docker:
	$(run-in-docker)
