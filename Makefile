# you can override on command line
lang = en

define run-in-docker =
	docker run --rm -v $$(pwd):/home/makedoc/linbit-documentation linbit-documentation /bin/sh -c 'cd ~/linbit-documentation && make $(patsubst %-docker,%,$@) lang=$(lang)'
endef

.PHONY: README.html-docker
README.html: README.adoc
	asciidoctor -n -o $@ $<

README.html-docker: dockerimage
	$(run-in-docker)

#
# po4a v0.54 is required to make build ja adoc files.
#
define dockerfile=
FROM debian:buster
MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>
RUN groupadd --gid $(shell id -g) makedoc
RUN useradd -u $(shell id -u) -g $(shell id -g) makedoc
RUN apt-get update && apt-get install -y make inkscape ruby po4a patch
RUN gem install --pre asciidoctor-pdf
RUN gem install --pre asciidoctor-pdf-cjk
USER makedoc
endef

export dockerfile
Dockerfile:
	@echo "$$dockerfile" > $@

.PHONY: dockerimage
dockerimage: Dockerfile
	if ! docker images --format={{.Repository}}:{{.Tag}} | grep -q 'linbit-documentation:latest'; then \
		docker build -t linbit-documentation . ; \
	fi

# UG 9
.PHONY: UG9-pdf-finalize UG9-pdf-finalize-docker UG9-html-finalize UG9-html-finalize-docker UG9-pot UG9-pot-docker
UG9-pdf-finalize:
	make -C UG9 pdf-finalize lang=$(lang)

UG9-pdf-finalize-docker: dockerimage
	$(run-in-docker)

UG9-html-finalize:
	make -C UG9 html-finalize lang=$(lang)

UG9-html-finalize-docker: dockerimage
	$(run-in-docker)

UG9-pot:
	make -C UG9 pot lang=en

UG9-pot-docker: dockerimage
	$(run-in-docker)

# UG 8.4
.PHONY: UG8.4-pdf-finalize UG8.4-pdf-finalize-docker UG8.4-html-finalize UG8.4-html-finalize-docker UG8.4-pot UG8.4-pot-docker
UG8.4-pdf-finalize:
	make -C UG8.4 pdf-finalize lang=$(lang)

UG8.4-pdf-finalize-docker: dockerimage
	$(run-in-docker)

UG8.4-html-finalize:
	make -C UG8.4 html-finalize lang=$(lang)

UG8.4-html-finalize-docker: dockerimage
	$(run-in-docker)

UG8.4-pot:
	make -C UG8.4 pot lang=en

UG8.4-pot-docker: dockerimage
	$(run-in-docker)

## targets you can only use if you cloned the according *private* project
# tech guides
.PHONY: tech-guides-pdf-finalize tech-guides-pdf-finalize-docker
tech-guides-pdf-finalize:
	make -C tech-guides pdf-finalize

tech-guides-pdf-finalize-docker: dockerimage
	$(run-in-docker)
